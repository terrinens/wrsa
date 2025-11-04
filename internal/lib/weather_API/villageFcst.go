package weather_API

import (
	"db_sync/internal/lib/code/weather"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
)

type VillageFcstResponse struct {
	Response struct {
		Header struct {
			ResultCode string `json:"resultCode"`
			ResultMsg  string `json:"resultMsg"`
		} `json:"header"`
		Body struct {
			DataType string `json:"dataType"`
			Items    struct {
				Item []VillageFcstItem `json:"item"`
			} `json:"items"`
			PageNo     int `json:"pageNo"`
			NumOfRows  int `json:"numOfRows"`
			TotalCount int `json:"totalCount"`
		} `json:"body"`
	} `json:"response"`
}

type VillageFcstItem struct {
	BaseDate  string `json:"baseDate"`  // 베이스 날짜
	BaseTime  string `json:"baseTime"`  // 베이스 시간
	Category  string `json:"category"`  // 예보 항목 카테고리
	FcstDate  string `json:"fcstDate"`  // 예보 날짜
	FcstTime  string `json:"fcstTime"`  // 예보 시간
	FcstValue string `json:"fcstValue"` // 예보 값 | 다양성을 위해 String으로 처리하니, 데이터에 따라서 잘 분리해서 사용할것
	Nx        int    `json:"nx"`        // 예보 지점 X좌표
	Ny        int    `json:"ny"`        // 예보 지점 Y좌표
}

/*
VillageFcstInfo 단기예보 조회 API
시스템 init에서부터 auth key는 주입되어있는것을 전제로 작성된 함수입니다.
nx,ny 는 현재 고정.
Fcst Info API는 최대 {baseDate + 1} ~ {baseDate + 4} 데이터를 보장합니다.

반환값 예시
```
baseDate: 20251022

		"20251023": {
	        		"PCP": [
	        			{...}
					]
		"20251024": {...}

```
*/
func VillageFcstInfo(baseDate string, baseTime string, nx int, ny int) map[string]map[weather.Category][]VillageFcstItem {
	url := createUrl(baseDate, baseTime, nx, ny)
	result := callAPI(url)

	if result == nil {
		log.Println("기상청 API 호출에 실패했습니다.")
		return nil
	}

	data := dateSeparation(result)
	return categorySeparation(data)
}

func getAuthKey() string {
	keyLocation := "/weather/weather-api-key"
	content, err := os.ReadFile(keyLocation)
	if err != nil {
		log.Fatal("API key file read failed: " + err.Error())
		return ""
	}
	return strings.TrimSpace(string(content))
}

func createUrl(baseDate string, baseTime string, nx int, ny int) string {
	baseUrl := "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst"
	authKey := getAuthKey()
	params := map[string]string{
		"pageNo":    "1",
		"numOfRows": "1000",
		"dataType":  "JSON",
		"base_date": baseDate,
		"base_time": baseTime,
		"nx":        strconv.Itoa(nx),
		"ny":        strconv.Itoa(ny),
		"authKey":   authKey,
	}

	url := baseUrl + "?"
	for key, value := range params {
		url += key + "=" + value + "&"
	}
	url = url[:len(url)-1]
	return url
}

/*callAPI url에 따른 요청을 불러오고, 응답값에 item들을 추출하여 가져옵니다.*/
func callAPI(url string) []VillageFcstItem {
	resp, err := http.Get(url)
	if err != nil {
		log.Fatal("API 호출 실패 : " + err.Error())
		return nil
	}

	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {
			log.Fatal("Body close 실패")
		}
	}(resp.Body)

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal("응답 읽기 실패 : " + err.Error())
		return nil
	}

	var apiResponse VillageFcstResponse
	err = json.Unmarshal(body, &apiResponse)
	if err != nil {
		log.Fatal("JSON 파싱 실패 : " + err.Error())
		return nil
	}

	if apiResponse.Response.Header.ResultCode != "00" {
		log.Printf("API 오류: %s - %s",
			apiResponse.Response.Header.ResultCode,
			apiResponse.Response.Header.ResultMsg)
		return nil
	}

	return apiResponse.Response.Body.Items.Item
}

func dateSeparation(items []VillageFcstItem) map[string][]VillageFcstItem {
	data := make(map[string][]VillageFcstItem)
	for _, item := range items {
		data[item.FcstDate] = append(data[item.FcstDate], item)
	}
	return data
}

func categorySeparation(data map[string][]VillageFcstItem) map[string]map[weather.Category][]VillageFcstItem {
	newData := make(map[string]map[weather.Category][]VillageFcstItem)

	for key, item := range data {
		separated := make(map[weather.Category][]VillageFcstItem)

		for _, inItems := range item {
			category := weather.Category(inItems.Category)

			separated[category] = append(separated[category], inItems)
		}

		newData[key] = separated
	}

	return newData
}
