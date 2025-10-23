package calculate

import (
	"db_sync/internal/lib/weather_API"
	"strconv"
)

func windAvg(wsd []weather_API.VillageFcstItem) float64 {
	var total float64

	for _, item := range wsd {
		value, _ := strconv.ParseFloat(item.FcstValue, 64)
		total += value
	}

	return total / float64(len(wsd))
}
