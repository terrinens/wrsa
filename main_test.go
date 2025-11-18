package main

import (
	database "db_sync/internal/db"
	"db_sync/internal/lib/code/grid"
	"os"
	"testing"
	"time"
)

func init() {
	_ = os.Setenv("DEV", "true")
	database.InitClient()
}

func _createRdata() regDate {
	loc, _ := time.LoadLocation("Asia/Seoul")

	timeLayout := "20060102"
	trueTime := time.Now().In(loc)
	trueDate := trueTime.Format(timeLayout)
	callDate := trueTime.AddDate(0, 0, -1).Format(timeLayout)
	endDate := trueTime.AddDate(0, 0, 3).Format(timeLayout)

	ttlTime := trueTime.AddDate(0, 0, 1).Add(time.Hour * 3).Format(timeLayout)
	ttl := createTTL(ttlTime, loc)

	return regDate{ttl: ttl, callDate: callDate, trueDate: trueDate, endDate: endDate}
}

func TestFetchWeatherDataConcurrently(t *testing.T) {
	var rDate = _createRdata()
	fetchWeatherDataConcurrently(grid.RepresentativeGrids, rDate)
}

func TestInsertWeatherDataConcurrently(t *testing.T) {
	var rDate = _createRdata()
	data, _ := fetchWeatherDataConcurrently(grid.RepresentativeGrids, rDate)
	insertWeatherDataConcurrently(data)
}
