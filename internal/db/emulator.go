package database

import (
	"context"
	"encoding/json"
	"fmt"
	"google.golang.org/api/option"
	"log"
	"os"
	"time"
)

// setEmulators Firestore 에뮬레이터 연결을 위한 설정을 반환합니다.
// firebase.json 에서 호스트/포트를 읽어 FIRESTORE_EMULATOR_HOST 환경변수를 설정합니다.
// 에뮬레이터 실행: firebase emulators:start --only firestore --project demo
// project 이름 자유롭게 변환되어도 좋지만, 반드시 UI를 사용하기 위해 --project 인수에 동일하게 설정되어야 합니다.
func setEmulators() (option.ClientOption, string) {
	log.Printf("Firebase 에뮬레이터 설정 가져오는 중")
	emulatorConfigFile, err := os.ReadFile("firebase.json")
	if err != nil {
		log.Fatalf("Cant find emulator config %s", err.Error())
	}

	var config *emulatorConfig

	if err = json.Unmarshal(emulatorConfigFile, &config); err != nil {
		log.Fatalf("Cant unmarshal emulator config %s", err.Error())
	}

	host := config.Emulators.Firestore.Host
	port := config.Emulators.Firestore.Port

	emulatorHost := fmt.Sprintf("%s:%d", host, port)
	err = os.Setenv("FIRESTORE_EMULATOR_HOST", emulatorHost)

	if err != nil {
		log.Fatalf("Cant set FIRESTORE_EMULATOR_HOST env variable : %s", err.Error())
	}

	return option.WithoutAuthentication(), "demo"
}

// testConnectEmulators 에뮬레이터 환경에서 연결되었는지 확인해보기 위한 함수입니다. 연결에 성공시, 테스트를 위해 사용된 데이터는 삭제됩니다.
func testConnectEmulators() error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	testCollection := "_connection_test"
	testDocID := fmt.Sprintf("test_%d", time.Now().UnixNano())

	log.Println("=== Firestore 연결 테스트 시작 ===")

	// 테스트 종료 시 무조건 삭제 시도
	defer func() {
		deleteCtx, deleteCancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer deleteCancel()

		if _, err := Client.Collection(testCollection).Doc(testDocID).Delete(deleteCtx); err != nil {
			log.Printf("[WARN] 테스트 데이터 삭제 실패 (무시 가능): %v", err)
		} else {
			log.Println("[SUCCESS] 테스트 데이터 삭제 성공")
		}
	}()

	// 1. 쓰기 테스트
	testData := map[string]interface{}{
		"message":   "connection test",
		"timestamp": time.Now().Unix(),
		"success":   true,
		"env":       os.Getenv("DEV"),
	}

	log.Println("[TEST] 쓰기 테스트 중...")
	if _, err := Client.Collection(testCollection).Doc(testDocID).Set(ctx, testData); err != nil {
		log.Printf("[ERROR] Firestore 쓰기 실패: %v", err)
		return fmt.Errorf("write test failed: %w", err)
	}
	log.Println("[SUCCESS] 쓰기 테스트 성공")

	// 2. 읽기 테스트
	log.Println("[TEST] 읽기 테스트 중...")
	doc, err := Client.Collection(testCollection).Doc(testDocID).Get(ctx)
	if err != nil {
		log.Printf("[ERROR] Firestore 읽기 실패: %v", err)
		return fmt.Errorf("read test failed: %w", err)
	}

	var readData map[string]interface{}
	if err := doc.DataTo(&readData); err != nil {
		log.Printf("[ERROR] 데이터 변환 실패: %v", err)
		return fmt.Errorf("data conversion failed: %w", err)
	}
	log.Printf("[SUCCESS] 읽기 테스트 성공: message=%v", readData["message"])

	// 3. 데이터 검증
	if readData["message"] != testData["message"] {
		log.Printf("[ERROR] 데이터 불일치: expected=%v, got=%v", testData["message"], readData["message"])
		return fmt.Errorf("data mismatch")
	}
	log.Println("[SUCCESS] 데이터 검증 성공")

	log.Println("=== Firestore 연결 테스트 완료 ===")
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
