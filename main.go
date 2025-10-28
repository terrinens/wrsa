package main

import (
	database "db_sync/internal/db"
	"db_sync/internal/lib/calculate"
	"db_sync/internal/lib/code"
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
	callDate := trueTime.AddDate(0, 0, -1).Format(timeLayout)
	endDate := trueTime.AddDate(0, 0, 4).Format(timeLayout)

	fcstItem := weather_API.VillageFcstInfo(callDate, "2300")
	log.Printf("%s로부터 %s까지 데이터 불러오기 성공", callDate, endDate)

	ttlTime := trueTime.AddDate(0, 0, 1).Format(timeLayout)
	ttl := createTTL(ttlTime, loc)
	dbData := createDBData(callDate, ttl, fcstItem)

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
func createDBData(callDate string, ttl *timestamp.Timestamp, fcstItem map[string]map[code.Category][]weather_API.VillageFcstItem) map[string]*database.Weather {
	var syncData = make(map[string]*database.Weather)

	lastTMN := 0.0
	lastTMX := 0.0

	for key, item := range fcstItem {
		var dbData = database.Weather{
			FcstDate:   callDate,
			NX:         60,
			NY:         127,
			Name:       "서울",
			AvgTempera: 0.0,
			Wash:       "",
			Wind:       0.0,
			TTL:        ttl,
		}

		// 각 두개의 데이터는 최하, 최고의 데이터를 하나씩만 소유하고 있으므로, 0 배열 밖에 존재하지 않음.
		// 가장 먼 날짜, 4일 후의 날짜에서는 최하,최고 날씨가 관측되지 않음. 그러므로 조건 처리.
		if item[code.TMN] != nil {
			lastTMN, _ = strconv.ParseFloat(item[code.TMN][0].FcstValue, 64)
		}

		if item[code.TMX] != nil {
			lastTMX, _ = strconv.ParseFloat(item[code.TMX][0].FcstValue, 64)
		}

		dbData.AvgTempera = (lastTMN + lastTMX) / 2
		dbData.Wash = string(wash(item))
		dbData.Wind = calculate.WindAvg(item[code.WSD])

		syncData[key] = &dbData
	}

	return syncData
}

// wash 빨래지수를 도출해내기 위한 함수입니다.
func wash(fcstItem map[code.Category][]weather_API.VillageFcstItem) code.Wash {
	// fcstDate 하루 온도 구하기
	avgREH := simpleAVG(fcstItem[code.REH])
	avgTemp := float64(code.TMN[0]+code.TMX[0]) / 2
	avgWind := calculate.WindAvg(fcstItem[code.WSD])
	avgSky := code.Sky(simpleAVG(fcstItem[code.SKY]))
	avgPTY := code.Pty(simpleAVG(fcstItem[code.PTY]))

	return calculate.WashEval(int8(avgREH), avgTemp, avgWind, avgSky, avgPTY)
}

func init() {
	if len(os.Args) > 1 && strings.ToLower(os.Args[1]) == "dev" {
		err := os.Setenv("DEV", "true")
		if err != nil {
			log.Fatalf("Failed to set DEV environment variable")
		}
	}
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
