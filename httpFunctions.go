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

	var message []string
	var errCount int

	nx, err := strconv.Atoi(queryNX)
	if err != nil {
		errCount++
		message = append(message, "nx is not a number")
	}

	ny, err := strconv.Atoi(queryNY)
	if err != nil {
		errCount++
		message = append(message, "ny is not a number")
	}

	if errCount > 0 {
		type ErrorResponse struct {
			Errors []string `json:"errors"`
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		err = json.NewEncoder(w).Encode(ErrorResponse{Errors: message})

		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			_, _ = w.Write([]byte("server error"))
		}

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

type resData struct {
	Name       string  `json:"Name"`
	FcstDate   string  `json:"FcstDate"`
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
			FcstDate:   doc.FcstDate,
			AvgTempera: doc.AvgTempera,
			Wash:       doc.Wash,
			Sky:        doc.Sky,
			Wind:       doc.Wind,
		}
		res = append(res, slice)
	}

	return res
}
