package main

import (
	"encoding/json"
	"testing"
	"time"

	"example.com/gcf/db"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var commonTTL = timestamppb.New(time.Unix(1761663600, 0))
var data = []*db.Weather{
	{
		FcstDate:   "20251030",
		NX:         66,
		NY:         103,
		Name:       "세종특별자치시",
		AvgTempera: 12.5,
		Wash:       "고려",
		Sky:        2,
		Wind:       0.62,
		TTL:        commonTTL,
	},
	{
		FcstDate:   "20251029",
		NX:         66,
		NY:         103,
		Name:       "세종특별자치시",
		AvgTempera: 11,
		Wash:       "보통",
		Sky:        1,
		Wind:       0.929,
		TTL:        commonTTL,
	},
	{
		FcstDate:   "20251028",
		NX:         66,
		NY:         103,
		Name:       "세종특별자치시",
		AvgTempera: 7,
		Wash:       "보통",
		Sky:        1,
		Wind:       1.225,
		TTL:        commonTTL,
	},
	{
		FcstDate:   "20251031",
		NX:         66,
		NY:         103,
		Name:       "세종특별자치시",
		AvgTempera: 14,
		Wash:       "고려",
		Sky:        3,
		Wind:       0.987,
		TTL:        commonTTL,
	},
	{
		FcstDate:   "20251101",
		NX:         66,
		NY:         103,
		Name:       "세종특별자치시",
		AvgTempera: 14,
		Wash:       "고려",
		Sky:        4,
		Wind:       1,
		TTL:        commonTTL,
	},
}

func TestEncoder(t *testing.T) {
	res := dataProcess(data)
	prettyJSON, err := json.MarshalIndent(res, "", "  ")
	if err != nil {
		t.Fatalf("데이터를 JSON으로 마샬링하는데 실패했습니다: %v", err)
		return
	}

	t.Logf("인코딩된 JSON 데이터:\n%s", prettyJSON)
}
