package database

import (
	"context"
	"encoding/json"
	"fmt"
	"google.golang.org/api/option"
	"os"
	"time"
)

// setEmulators Firestore 에뮬레이터 연결을 위한 설정을 반환합니다.
// firebase.json 에서 호스트/포트를 읽어 FIRESTORE_EMULATOR_HOST 환경변수를 설정합니다.
// 에뮬레이터 실행: firebase emulators:start --only firestore --project demo
// project 이름 자유롭게 변환되어도 좋지만, 반드시 UI를 사용하기 위해 --project 인수에 동일하게 설정되어야 합니다.
func setEmulators() (option.ClientOption, string) {
	log.Debug("Firebase 에뮬레이터 설정 가져오는 중")
	emulatorConfigFile, err := os.ReadFile("firebase.json")
	if err != nil {
		log.Fatal("firebase.json 설정 파일을 찾을 수 없음", "error", err)
	}

	var config *emulatorConfig

	if err = json.Unmarshal(emulatorConfigFile, &config); err != nil {
		log.Fatal("firebase.json 파싱 실패", "error", err)
	}

	host := config.Emulators.Firestore.Host
	port := config.Emulators.Firestore.Port

	emulatorHost := fmt.Sprintf("%s:%d", host, port)
	err = os.Setenv("FIRESTORE_EMULATOR_HOST", emulatorHost)

	if err != nil {
		log.Fatal("FIRESTORE_EMULATOR_HOST 환경변수 설정 실패", "error", err)
	}

	return option.WithoutAuthentication(), "demo"
}

// testConnectEmulators 에뮬레이터 환경에서 연결되었는지 확인해보기 위한 함수입니다. 연결에 성공시, 테스트를 위해 사용된 데이터는 삭제됩니다.
func testConnectEmulators() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	testCollection := "_connection_test"
	testDocID := fmt.Sprintf("test_%d", time.Now().UnixNano())

	log.Info("=== Firestore 연결 테스트 시작 ===")

	// 테스트 종료 시 무조건 삭제 시도
	defer func() {
		deleteCtx, deleteCancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer deleteCancel()

		if _, err := Client.Collection(testCollection).Doc(testDocID).Delete(deleteCtx); err != nil {
			log.Warn("테스트 데이터 삭제 실패 (무시 가능)", "error", err)
		} else {
			log.Info("테스트 데이터 삭제 성공")
		}
	}()

	// 1. 쓰기 테스트
	testData := map[string]interface{}{
		"message":   "connection test",
		"timestamp": time.Now().Unix(),
		"success":   true,
		"env":       os.Getenv("DEV"),
	}

	log.Info("[TEST] 쓰기 테스트 중...")
	if _, err := Client.Collection(testCollection).Doc(testDocID).Set(ctx, testData); err != nil {
		log.Error("Firestore 쓰기 실패", "error", err)
		return fmt.Errorf("write test failed: %w", err)
	}
	log.Info("쓰기 테스트 성공")

	// 2. 읽기 테스트
	log.Info("[TEST] 읽기 테스트 중...")
	doc, err := Client.Collection(testCollection).Doc(testDocID).Get(ctx)
	if err != nil {
		log.Error("Firestore 읽기 실패", "error", err)
		return fmt.Errorf("read test failed: %w", err)
	}

	var readData map[string]interface{}
	if err := doc.DataTo(&readData); err != nil {
		log.Error("데이터 변환 실패", "error", err)
		return fmt.Errorf("data conversion failed: %w", err)
	}
	log.Info("읽기 테스트 성공", "message", readData["message"])

	// 3. 데이터 검증
	if readData["message"] != testData["message"] {
		log.Error("데이터 불일치", "expected", testData["message"], "got", readData["message"])
		return fmt.Errorf("data mismatch")
	}
	log.Info("데이터 검증 성공")

	log.Info("=== Firestore 연결 테스트 완료 ===")
	return nil
}

type emulatorConfig struct {
	Emulators struct {
		Firestore struct {
			Port int    `json:"port"`
			Host string `json:"host"`
		} `json:"firestore"`
	} `json:"emulators"`
}
