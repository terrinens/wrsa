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

/*insertWeatherData 새 데이터를 등록합니다. */
func insertWeatherData(data *Weather) bool {
	ref := Client.Collection("weather")
	ctx := context.Background()

	_, _, err := ref.Add(ctx, data)
	if err != nil {
		log.Fatalf("error adding data for %s: %v\n", data.FcstDate, err)
		return false
	}

	return true
}

/*RegisterWeatherData 기존의 Fcst Data, NX, XY와 동일한 필드를 찾고, 동일할 경우에 이를 갱신합니다. 존재하지 않을 경우에는 새롭게 등록합니다.*/
func RegisterWeatherData(data *Weather) bool {
	ref := Client.Collection("weather")
	ctx := context.Background()

	query := ref.
		Where("FcstDate", "==", data.FcstDate).
		Where("NX", "==", data.NX).
		Where("NY", "==", data.NY)

	iter := query.Documents(ctx)
	defer iter.Stop()

	doc, _ := iter.Next()
	if doc == nil {
		return insertWeatherData(data)
	} else {
		_, err := doc.Ref.Set(ctx, data)
		if err != nil {
			log.Fatalf("error updating data for %s: %v\n", data.FcstDate, err)
			return false
		}

		return true
	}
}
