package database

import (
	"db_sync/internal/lib/code"

	"github.com/golang/protobuf/ptypes/timestamp"
)

type Weather struct {
	FcstDate   string               `json:"FcstDate"`
	NX         int64                `json:"NX"`
	NY         int64                `json:"NY"`
	Name       string               `json:"Name"`
	AvgTempera float64              `json:"AvgTempera"`
	Wash       code.Wash            `json:"Wash"`
	Sky        code.Sky             `json:"Sky"`
	Wind       float64              `json:"Wind"`
	TTL        *timestamp.Timestamp `json:"TTL"`
}
