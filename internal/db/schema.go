package database

import (
	"db_sync/internal/lib/code/weather"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type Weather struct {
	FcstDate   string                 `json:"FcstDate"`
	NX         int                    `json:"NX"`
	NY         int                    `json:"NY"`
	Name       string                 `json:"Name"`
	AvgTempera float64                `json:"AvgTempera"`
	Wash       weather.Wash           `json:"Wash"`
	Sky        weather.Sky            `json:"Sky"`
	Wind       float64                `json:"Wind"`
	TTL        *timestamppb.Timestamp `json:"TTL"`
}
