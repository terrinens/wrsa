package weather_API

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
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

type Category string

const (
	POP Category = "POP" // 강수확률 (%)
	PTY Category = "PTY" // 강수형태 (코드값)
	PCP Category = "PCP" // 1시간 강수량 (범주 1 mm)
	REH Category = "REH" // 습도 (%)
	SNO Category = "SNO" // 1시간 신적설 (범주 1 cm)
	SKY Category = "SKY" // 하늘상태 (코드값)
	TMP Category = "TMP" // 1시간 기온 (℃)
	TMN Category = "TMN" // 일 최저기온 (℃)
	TMX Category = "TMX" // 일 최고기온 (℃)
	UUU Category = "UUU" // 풍속(동서성분) (m/s)
	VVV Category = "VVV" // 풍속(남북성분) (m/s)
	WAV Category = "WAV" // 파고 (M)
	VEC Category = "VEC" // 풍향 (deg)
	WSD Category = "WSD" // 풍속 (m/s)
)

/*
VillageFcstInfo 단기예보 조회 API
시스템 init에서부터 auth key는 주입되어있는것을 전제로 작성된 함수입니다.
nx,ny 는 현재 고정.
baseDate : 20200101
baseTime : 0000
fcstDate : 20200102
*/
func VillageFcstInfo(baseDate string, baseTime string, fcstDate string) map[Category][]VillageFcstItem {
	baseUrl := "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst"
	authKey := "j6VB3Gz5RJmlQdxs-USZOQ"
	params := map[string]string{
		"pageNo":    "1",
		"numOfRows": "1000",
		"dataType":  "JSON",
		"base_date": baseDate,
		"base_time": baseTime,
		"nx":        "55",
		"ny":        "127",
		"authKey":   authKey,
	}

	url := baseUrl + "?"
	for key, value := range params {
		url += key + "=" + value + "&"
	}
	url = url[:len(url)-1]

	result := callAPI(url)
	result = dataFilter(fcstDate, result)

	data := categorySeparation(result)

	return data
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

/*
dataFilter item들중 fcstDate와 동일한 아이템을 필터합니다.
fcstDate 필터할 데이터
*/
func dataFilter(fcstDate string, items []VillageFcstItem) []VillageFcstItem {
	var filtered []VillageFcstItem
	for _, item := range items {
		if item.FcstDate == fcstDate {
			filtered = append(filtered, item)
		}
	}
	return filtered
}

func categorySeparation(items []VillageFcstItem) map[Category][]VillageFcstItem {
	separated := make(map[Category][]VillageFcstItem)

	for _, item := range items {
		category := Category(item.Category)
		separated[category] = append(separated[category], item)
	}

	return separated
}
