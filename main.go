package main

import (
	database "db_sync/internal/db"
	"db_sync/internal/lib/calculate"
	"db_sync/internal/lib/code/grid"
	"db_sync/internal/lib/code/weather"
	"db_sync/internal/lib/weather_API"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/golang/protobuf/ptypes/timestamp"
)

func main() {
	database.InitClient()

	loc, _ := time.LoadLocation("Asia/Seoul")

	timeLayout := "20060102"
	trueTime := time.Now().In(loc)
	trueDate := trueTime.Format(timeLayout)
	callDate := trueTime.AddDate(0, 0, -1).Format(timeLayout)
	endDate := trueTime.AddDate(0, 0, 3).Format(timeLayout)

	ttlTime := trueTime.AddDate(0, 0, 1).Add(time.Hour * 3).Format(timeLayout)
	ttl := createTTL(ttlTime, loc)

	var rDate = regDate{ttl: ttl, callDate: callDate, trueDate: trueDate, endDate: endDate}
	var errorFCST = dataReg(grid.RepresentativeGrids, rDate)

	if len(errorFCST) == 0 {
		log.Printf("모든 데이터 갱신 성공")
	} else {
		log.Printf("API 호출 실패건수 %d이 있으므로 재호출 시도...", len(errorFCST))
		errorFCST = dataReg(grid.RepresentativeGrids, rDate)

		if len(errorFCST) != 0 {
			log.Fatalf("실패된 요청을 재요청했으나, %d의 건이 재실패되었습니다. 서버 상태를 확인해주세요", len(errorFCST))
		}
	}
}

type ErrorFCST struct {
	baseTime string
	nx       int
	ny       int
}

type regDate struct {
	ttl      *timestamp.Timestamp
	callDate string
	trueDate string
	endDate  string
}

// dataReg 주어진 grid를 토대로 API를 호출하고, 이를 db에 등록합니다.
func dataReg(grid []grid.RepresentativeGrid, date regDate) []ErrorFCST {
	var errorFCST []ErrorFCST

	for _, info := range grid {
		nx := info.Nx
		ny := info.Ny

		fcstItem := weather_API.VillageFcstInfo(date.callDate, "2300", nx, ny)

		if fcstItem == nil {
			errorFCST = append(errorFCST, ErrorFCST{baseTime: "2300", nx: nx, ny: ny})
			log.Printf("%s 지역 데이터 불러오기 실패.", info.Name)
			continue
		}

		regData(date.ttl, fcstItem, info)

		log.Printf("%s 지역 %s로부터 %s까지 데이터 등록 성공", info.Name, date.trueDate, date.endDate)
	}

	return errorFCST
}

// regData fcstItem을 기반으로 데이터를 db에 등록합니다.
func regData(ttl *timestamp.Timestamp, fcstItem map[string]map[weather.Category][]weather_API.VillageFcstItem, info grid.RepresentativeGrid) {
	dbData := createDBData(ttl, fcstItem, info)

	for _, data := range dbData {
		database.RegDBData(data)
	}
}

/*
createDBData fcst 의 데이터를 활용하여, DB에 등록할 데이터를 생성합니다.
```

		"20210101" : {
			NX:         60,
				NY:         127,
				Name:       "부산",
				AvgTempera: 18.0,
				Wash:       "좋음",
				Wind:       3.0,
				TTL:        nil,
	}

```
*/
func createDBData(ttl *timestamp.Timestamp, fcstItem map[string]map[weather.Category][]weather_API.VillageFcstItem, grid grid.RepresentativeGrid) map[string]*database.Weather {
	var syncData = make(map[string]*database.Weather)

	lastTMN := 0.0
	lastTMX := 0.0

	for key, item := range fcstItem {
		var dbData = database.Weather{
			FcstDate:   key,
			NX:         grid.Nx,
			NY:         grid.Ny,
			Name:       grid.Name,
			AvgTempera: 0.0,
			Wash:       "",
			Sky:        weather.SUNNY,
			Wind:       0.0,
			TTL:        ttl,
		}

		// 각 두개의 데이터는 최하, 최고의 데이터를 하나씩만 소유하고 있으므로, 0 배열 밖에 존재하지 않음.
		// 가장 먼 날짜, 4일 후의 날짜에서는 최하,최고 날씨가 관측되지 않음. 그러므로 조건 처리.
		if item[weather.TMN] != nil {
			lastTMN, _ = strconv.ParseFloat(item[weather.TMN][0].FcstValue, 64)
		}

		if item[weather.TMX] != nil {
			lastTMX, _ = strconv.ParseFloat(item[weather.TMX][0].FcstValue, 64)
		}

		dbData.AvgTempera = (lastTMN + lastTMX) / 2
		dbData.Wash = wash(item)
		dbData.Sky = weather.Sky(simpleAVG(item[weather.SKY]))
		dbData.Wind = calculate.WindAvg(item[weather.WSD])

		syncData[key] = &dbData
	}

	return syncData
}

// wash 빨래지수를 도출해내기 위한 함수입니다.
func wash(fcstItem map[weather.Category][]weather_API.VillageFcstItem) weather.Wash {
	// fcstDate 하루 온도 구하기
	avgREH := simpleAVG(fcstItem[weather.REH])
	avgTemp := float64(weather.TMN[0]+weather.TMX[0]) / 2
	avgWind := calculate.WindAvg(fcstItem[weather.WSD])
	avgSky := weather.Sky(simpleAVG(fcstItem[weather.SKY]))
	avgPTY := weather.Pty(simpleAVG(fcstItem[weather.PTY]))

	return calculate.WashEval(int8(avgREH), avgTemp, avgWind, avgSky, avgPTY)
}

func simpleAVG(data []weather_API.VillageFcstItem) int64 {
	var total float64
	for _, item := range data {
		val, _ := strconv.ParseFloat(item.FcstValue, 64)
		total += val
	}

	return int64(int(total) / len(data))
}

func createTTL(date string, loc *time.Location) *timestamp.Timestamp {
	t, err := time.ParseInLocation("20060102", date, loc)
	if err != nil {
		log.Fatal("Failed to parse date:", err)
	}

	return &timestamp.Timestamp{
		Seconds: t.Unix(),
		Nanos:   int32(t.Nanosecond()),
	}
}

func init() {
	if len(os.Args) > 1 && strings.ToLower(os.Args[1]) == "dev" {
		err := os.Setenv("DEV", "true")
		if err != nil {
			log.Fatalf("Failed to set DEV environment variable")
		}
	}
}
