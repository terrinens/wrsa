package database

import (
	"context"
	"log"
	"os"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
)

var Client *firestore.Client

/*InitClient 해당 함수는 DB를 초기화하고 글로벌 변수 Client에 결과를 주입합니다.*/
func InitClient() {
	var clientOptions option.ClientOption

	if os.Getenv("DEV") == "true" {
		clientOptions = option.WithCredentialsFile(os.Getenv("GOOGLE_APPLICATION_CREDENTIALS"))
	} else {
		var credentialsFile, err = os.ReadFile("/keys/firestore_key")

		if err != nil {
			log.Fatalf("Error reading firestore key file: %v", err)
		}

		clientOptions = option.WithCredentialsJSON(credentialsFile)
	}

	app, err := firebase.NewApp(context.Background(), nil, clientOptions)
	if err != nil || app == nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	client, err := app.Firestore(context.Background())
	if err != nil || client == nil {
		log.Fatalf("error getting client: %v\n", err)
	}

	Client = client
}

/*RegDBData 새 데이터를 등록합니다. */
func RegDBData(data *Weather) bool {
	ref := Client.Collection("weather")
	ctx := context.Background()

	_, _, err := ref.Add(ctx, data)
	if err != nil {
		log.Fatalf("error adding data: %v\n", err)
		return false
	}

	log.Printf("data added successfully\n")
	return true
}
