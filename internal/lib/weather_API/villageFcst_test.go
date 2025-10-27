package weather_API

import (
	"encoding/json"
	"log"
	"os"
	"testing"
)

var tests = []struct {
	name         string
	mockFilePath string
}{{
	name:         "1차 분리 테스트",
	mockFilePath: "./testdata/getVillageFcst.json",
}}

func x1(mockFilePath string) map[string][]VillageFcstItem {
	fileBytes, err := os.ReadFile(mockFilePath)
	if err != nil {
		log.Fatalf("failed to read file: %v", err)
	}

	var unmarshalData VillageFcstResponse
	err = json.Unmarshal(fileBytes, &unmarshalData)
	if err != nil {
		log.Fatalf("failed to unmarshal file: %v", err)
	}

	return dateSeparation(unmarshalData.Response.Body.Items.Item)
}

func TestDateSeparation(t *testing.T) {
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Logf("날짜별로 분리 테스트")
			dateSep := x1(tt.mockFilePath)
			pretty, _ := json.MarshalIndent(dateSep, "", "\t")
			log.Printf("날짜별 분리 결과: %s", pretty)
		})
	}
}

func TestCategorySeparation(t *testing.T) {
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			dateSpe := x1(tt.mockFilePath)

			t.Logf("카테고리별 분리 테스트")
			categorySep := categorySeparation(dateSpe)
			pretty, _ := json.MarshalIndent(categorySep, "", "\t")
			t.Logf("카테고리별 분리 결과 : %s", pretty)
		})
	}
}
