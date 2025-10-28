package db

import (
	"fmt"
	"log"
	"os"
	"testing"
)

func TestGetData(t *testing.T) {
	data, _ := GetData(66, 103)

	for _, item := range data {
		fmt.Printf("%+v\n", *item)
	}
}

func init() {
	err := os.Setenv("DEV", "true")
	if err != nil {
		log.Fatalf("Failed to set DEV environment variable")
	}
	InitClient()
}
