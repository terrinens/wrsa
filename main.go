package main

import (
	database "db_sync/internal/db"
	"log"
	"os"
	"strings"
	"time"
)

func main() {

	database.InitClient()

	now := time.Now()
	kor, err := time.LoadLocation("UTF+9")
	if err != nil {
		log.Fatal("시간 변경 실패 : " + err.Error())
		return
	}

	_ = now.In(kor)
}

func init() {
	if len(os.Args) > 1 && strings.ToLower(os.Args[1]) == "dev" {
		err := os.Setenv("DEV", "true")
		if err != nil {
			log.Fatalf("Failed to set DEV environment variable")
		}
	}
}
