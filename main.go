package main

import (
	"db_sync/internal/db"
	"log"
	"os"
	"strings"
)

func main() {
	database.InitClient()
}

func init() {
	if len(os.Args) > 1 && strings.ToLower(os.Args[1]) == "dev" {
		err := os.Setenv("DEV", "true")
		if err != nil {
			log.Fatalf("Failed to set DEV environment variable")
		}
	}
}
