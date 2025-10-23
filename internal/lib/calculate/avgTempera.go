package calculate

import (
	"db_sync/internal/lib/weather_API"
	"strconv"
)

type TempData struct {
	Min string
	Max string
}

/*avg 하루의 데이터를 받고, 평균 온도값을 계산하는 함수입니다.*/
func avg(tmn []weather_API.VillageFcstItem, tmx []weather_API.VillageFcstItem) float64 {
	timeGrouped := make(map[string]TempData)

	for _, t := range tmn {
		timeGrouped[t.FcstTime] = TempData{
			Min: t.FcstValue,
		}
	}

	for _, t := range tmx {
		if data, exists := timeGrouped[t.FcstTime]; exists {
			data.Max = t.FcstValue
			timeGrouped[t.FcstTime] = data
		} else {
			timeGrouped[t.FcstTime] = TempData{
				Max: t.FcstValue,
			}
		}
	}

	var totalTemp float64
	var count int

	// 기존 Fcst Value는 다양성을 위해 String으로 취급하고 있으니, 변환
	for _, data := range timeGrouped {
		_min, _ := strconv.ParseFloat(data.Min, 64)
		_max, _ := strconv.ParseFloat(data.Max, 64)
		if data.Min != "" && data.Max != "" {
			totalTemp += (_min + _max) / 2
			count++
		}
	}

	return totalTemp / float64(count)
}
