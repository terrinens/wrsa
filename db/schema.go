package db

import (
	"github.com/golang/protobuf/ptypes/timestamp"
)

type Weather struct {
	FcstDate   string               `json:"FcstDate"`
	NX         int                  `json:"NX"`
	NY         int                  `json:"NY"`
	Name       string               `json:"Name"`
	AvgTempera float64              `json:"AvgTempera"`
	Wash       string               `json:"Wash"`
	Sky        int                  `json:"Sky"`
	Wind       float64              `json:"Wind"`
	TTL        *timestamp.Timestamp `json:"TTL"`
}
