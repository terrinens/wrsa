package calculate

import (
	"db_sync/internal/lib/weather_API"
	"math"
	"strconv"
)

func WindAvg(wsd []weather_API.VillageFcstItem) float64 {
	var total float64

	for _, item := range wsd {
		value, _ := strconv.ParseFloat(item.FcstValue, 64)
		total += value
	}

	average := total / float64(len(wsd))
	precision := 3
	factor := math.Pow(10, float64(precision))
	truncatedAverage := math.Trunc(average*factor) / factor

	return truncatedAverage
}
