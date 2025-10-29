package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"example.com/gcf/db"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	db.InitClient()
	InitRouter()

	log.Println("Server starting on port " + port)
	err := http.ListenAndServe(":"+port, nil)
	if err != nil {
		log.Fatalf("Error starting server: %s", err)
	}

	functions.HTTP("weatherData", weatherData)
}

func init() {
	if len(os.Args) > 1 && strings.ToLower(os.Args[1]) == "dev" {
		err := os.Setenv("DEV", "true")
		if err != nil {
			log.Fatalf("Failed to set DEV environment variable")
		}
	}
}
