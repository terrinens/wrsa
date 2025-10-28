package database

import "github.com/golang/protobuf/ptypes/timestamp"

type Weather struct {
	FcstDate   string               `json:"FcstDate"`
	NX         int64                `json:"NX"`
	NY         int64                `json:"NY"`
	Name       string               `json:"Name"`
	AvgTempera float64              `json:"AvgTempera"`
	Wash       string               `json:"Wash"`
	Wind       float64              `json:"Wind"`
	TTL        *timestamp.Timestamp `json:"TTL"`
}
