package database

import (
	"context"
	"errors"
	"log"
	"os"
	"testing"

	"google.golang.org/api/iterator"
)

/* !!!!!!!!! 반드시 개발 환경에서만 사용할것. 해당 테스트 문서는 데이터베이스 주입, 삭제 테스틀 하기 위해 만들어진것*/
func TestClear(t *testing.T) {

	ref := Client.Collection("weather")
	ctx := context.Background()
	refs := ref.Documents(ctx)

	for {
		doc, err := refs.Next()

		if errors.Is(err, iterator.Done) {
			break
		}

		if doc.Ref.ID == "base doc" {
			continue
		}

		_, err = doc.Ref.Delete(ctx)
		if err != nil {
			t.Fatal(err)
		}
	}

}

func init() {
	err := os.Setenv("DEV", "true")
	if err != nil {
		log.Fatalf("Failed to set DEV environment variable")
	}
	InitClient()
}
