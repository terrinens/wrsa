package main

import (
	"encoding/json"
	"net/http"
	"strconv"

	"example.com/gcf/db"
)

func InitRouter() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		weatherData(w, r)
	})
}

func weatherData(w http.ResponseWriter, r *http.Request) {
	queryNX := r.URL.Query().Get("nx")
	queryNY := r.URL.Query().Get("ny")

	nx, err := conversionInt(queryNX, w)
	if !err {
		return
	}

	ny, err := conversionInt(queryNY, w)
	if !err {
		return
	}

	data, success := db.GetData(nx, ny)
	if !success {
		http.Error(w, "데이터 찾지 못하거나 존재하지 않음", http.StatusBadRequest)
		return
	}

	response := dataProcess(data)

	w.Header().Set("Content-Type", "application/json")
	encodeErr := json.NewEncoder(w).Encode(response)

	if encodeErr != nil {
		http.Error(w, "서버에서 데이터 변환 실패.", http.StatusInternalServerError)
	}
}

// query String to Int conversion 실패 할 경우에 응답값을 설정합니다.
func conversionInt(str string, w http.ResponseWriter) (int, bool) {
	num, err := strconv.Atoi(str)
	if err != nil {
		http.Error(w, "Not a number", http.StatusBadRequest)
		return 0, false
	}
	return num, true
}

type resData struct {
	Name       string  `json:"Name"`
	AvgTempera float64 `json:"AvgTempera"`
	Wash       string  `json:"Wash"`
	Sky        int     `json:"Sky"`
	Wind       float64 `json:"Wind"`
}

// dataProcess 필요한 데이터만 가공하여 반환합니다.
func dataProcess(data []*db.Weather) []resData {
	var res []resData

	for _, doc := range data {
		slice := resData{
			Name:       doc.Name,
			AvgTempera: doc.AvgTempera,
			Wash:       doc.Wash,
			Sky:        doc.Sky,
			Wind:       doc.Wind,
		}
		res = append(res, slice)
	}

	return res
}
