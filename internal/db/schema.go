package database

import "github.com/golang/protobuf/ptypes/timestamp"

type weather struct {
	Code       string              `json:"Code"`
	AvgTempera float32             `json:"AvgTempera"`
	Wash       string              `json:"Wash"`
	Wind       string              `json:"Wind"`
	TTL        timestamp.Timestamp `json:"TTL"`
}
