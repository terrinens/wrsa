package database

import (
	"cloud.google.com/go/firestore"
	"context"
	"db_sync/internal/lib/logger"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
	"os"
)

var Client *firestore.Client
var log = logger.New()

/*InitClient 해당 함수는 DB를 초기화하고 글로벌 변수 Client에 결과를 주입합니다.*/
func InitClient() {
	var clientOptions option.ClientOption
	var newAppConfig *firebase.Config = nil

	if os.Getenv("DEV") == "true" {
		log.Info("DEV 환경 : Firestore 에뮬레이터 연결")
		var projectID string
		clientOptions, projectID = setEmulators()
		newAppConfig = &firebase.Config{ProjectID: projectID}
	} else {
		var credentialsFile, err = os.ReadFile("/keys/firestore_key")
		if err != nil {
			log.Fatal("Firestore 인증키 파일 읽기 실패", "error", err)
		}

		clientOptions = option.WithCredentialsJSON(credentialsFile)
	}

	app, err := firebase.NewApp(context.Background(), newAppConfig, clientOptions)
	if err != nil || app == nil {
		log.Fatal("Firebase App 초기화 실패", "error", err)
		return // IDE 사용시 Custom Log 의 동작을 인지하지 못하기에 의도된 동작.
	}

	client, err := app.Firestore(context.Background())
	if err != nil || client == nil {
		log.Fatal("Firestore 클라이언트 생성 실패", "error", err)
	}

	Client = client

	if os.Getenv("DEV") == "true" {
		log.Info("에뮬레이터 연결 테스트...")
		err = testConnectEmulators()
	}
}

/*insertWeatherData 새 데이터를 등록합니다. */
func insertWeatherData(data *Weather) bool {
	ref := Client.Collection("weather")
	ctx := context.Background()

	_, _, err := ref.Add(ctx, data)
	if err != nil {
		log.Fatal("데이터 추가 실패", "날짜", data.FcstDate, "error", err)
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
			log.Fatal("데이터 업데이트 실패", "날짜", data.FcstDate, "error", err)
			return false
		}

		return true
	}
}
