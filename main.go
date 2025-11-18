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
	"sync"
	"time"

	"github.com/golang/protobuf/ptypes/timestamp"
)

func main() {
	loc, _ := time.LoadLocation("Asia/Seoul")

	timeLayout := "20060102"
	trueTime := time.Now().In(loc)
	trueDate := trueTime.Format(timeLayout)
	callDate := trueTime.AddDate(0, 0, -1).Format(timeLayout)
	endDate := trueTime.AddDate(0, 0, 3).Format(timeLayout)

	ttlTime := trueTime.AddDate(0, 0, 1).Add(time.Hour * 3).Format(timeLayout)
	ttl := createTTL(ttlTime, loc)

	var rDate = regDate{ttl: ttl, callDate: callDate, trueDate: trueDate, endDate: endDate}
	var data, errorFCST = fetchWeatherDataConcurrently(grid.RepresentativeGrids, rDate)

	if len(errorFCST) != 0 {
		log.Printf("API 호출 실패 건수 %d", len(errorFCST))
		log.Printf("재호출을 시도합니다...")

		var failGrids []grid.RepresentativeGrid
		for _, fcst := range errorFCST {
			findGrid := grid.GetAreaCodeFromGrid(fcst.nx, fcst.ny)
			failGrids = append(failGrids, findGrid)
		}

		newData, errorFCST := fetchWeatherDataConcurrently(failGrids, rDate)

		data = append(data, newData...)

		if errorFCST != nil {
			log.Printf("재호출을 시도 했으나, 여전히 %d건의 API 호출을 실패했습니다. 서버 상태를 확인해주십시오.", len(errorFCST))
		}
	}

	log.Printf("호출된 데이터 건수 %d DB 등록 시도.", len(data))
	insertFails := insertWeatherDataConcurrently(data)

	if len(insertFails) != 0 {
		log.Printf("DB 등록에 실패한 건수 %d", len(insertFails))
		log.Printf("재등록을 시도합니다...")

		insertFails = insertWeatherDataConcurrently(insertFails)
		if insertFails != nil {
			log.Printf("재등록을 시도 했으나, 여전히 %d건의 등록을 실패했습니다. DB 서버 상태를 확인해주십시오.", len(insertFails))
		}
	}

}

type ErrorFCST struct {
	baseTime string
	nx       int
	ny       int
}

// regDate 데이터 등록날짜를 위해 사용하는 모델입니다.
type regDate struct {
	ttl      *timestamp.Timestamp
	callDate string
	trueDate string
	endDate  string
}

// createSemaphore 제한된 환경으로 인해 동시작업을 최대 30으로 제한합니다.
func createSemaphore(maxConcurrent int) chan struct{} {
	routineLimit := min(maxConcurrent, 30)
	return make(chan struct{}, routineLimit)
}

// fetchWeatherDataConcurrently 주어진 grid를 토대로 API를 호출하고, 이의 결과물을 리턴합니다.
func fetchWeatherDataConcurrently(grid []grid.RepresentativeGrid, date regDate) ([]*database.Weather, []ErrorFCST) {
	dataChan := make(chan []*database.Weather, len(grid))
	errorChan := make(chan ErrorFCST, len(grid))

	var wg sync.WaitGroup
	semaphore := createSemaphore(len(grid))

	for _, info := range grid {
		wg.Add(1)

		nx := info.Nx
		ny := info.Ny

		go func() {
			defer wg.Done()
			semaphore <- struct{}{}
			defer func() { <-semaphore }()

			fcstItem := weather_API.VillageFcstInfo(date.callDate, "2300", nx, ny)
			if fcstItem == nil {
				errorChan <- ErrorFCST{baseTime: "2300", nx: nx, ny: ny}
				log.Printf("%s 지역 데이터 불러오기 실패.", info.Name)
				return
			}

			weatherData := createWeatherData(date.ttl, fcstItem, info)
			dataChan <- weatherData

			log.Printf("%s 지역 %s로부터 %s까지 데이터 불러오기 성공", info.Name, date.trueDate, date.endDate)
		}()
	}

	go func() {
		wg.Wait()
		close(errorChan)
		close(dataChan)
	}()

	var data []*database.Weather
	done := make(chan struct{})

	go func() {
		for d := range dataChan {
			data = append(data, d...)
		}
		done <- struct{}{}
	}()

	var errors []ErrorFCST
	for e := range errorChan {
		errors = append(errors, e)
	}

	<-done
	return data, errors
}

// db 동시 삽입할것
func insertWeatherDataConcurrently(data []*database.Weather) []*database.Weather {
	errorChan := make(chan *database.Weather, len(data))

	var wg sync.WaitGroup
	semaphore := createSemaphore(len(data))

	startTime := time.Now()
	totalCount := len(data)

	for _, info := range data {
		wg.Add(1)

		go func() {
			defer wg.Done()
			semaphore <- struct{}{}
			defer func() { <-semaphore }()

			success := database.RegisterWeatherData(info)

			if !success {
				errorChan <- info
				log.Printf("%s : %s 등록 실패", info.Name, info.FcstDate)
			} else {
				log.Printf("%s : %s 등록 성공", info.Name, info.FcstDate)
			}
		}()
	}

	go func() {
		wg.Wait()
		close(errorChan)
	}()

	var errors []*database.Weather
	for e := range errorChan {
		errors = append(errors, e)
	}

	successCount := totalCount - len(errors)
	elapsed := time.Since(startTime)
	log.Printf("총 %d건 중 성공 %d건, 실패 %d건 (소요시간: %v)",
		totalCount, successCount, len(errors), elapsed)
	return errors
}

/*createWeatherData fcst 의 데이터를 활용하여, DB에 등록할 데이터를 생성합니다.*/
func createWeatherData(ttl *timestamp.Timestamp, fcstItem map[string]map[weather.Category][]weather_API.VillageFcstItem, grid grid.RepresentativeGrid) []*database.Weather {
	var syncData []*database.Weather

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

		syncData = append(syncData, &dbData)
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

		err = os.Setenv("FIRESTORE_EMULATOR_HOST", "::1:8480")
	}

	database.InitClient()
}
