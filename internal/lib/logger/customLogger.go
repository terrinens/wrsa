package logger

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"os"
)

type Logger struct {
	*slog.Logger
}

type customHandler struct {
	opts slog.HandlerOptions
	out  io.Writer
}

func (h *customHandler) Enabled(_ context.Context, level slog.Level) bool {
	return level >= h.opts.Level.Level()
}

func (h *customHandler) Handle(_ context.Context, r slog.Record) error {
	// 2025/11/18 18:07:12 LEVEL MSG
	timeStr := r.Time.Format("2006/01/02 15:04:05")
	level := fmt.Sprintf("%-5s", r.Level.String())
	msg := r.Message

	// 기본 포맷
	_, _ = fmt.Fprintf(h.out, "%s %s %s", timeStr, level, msg)

	// 속성(key-value) 출력
	r.Attrs(func(a slog.Attr) bool {
		_, _ = fmt.Fprintf(h.out, " %s=%v", a.Key, a.Value)
		return true
	})

	_, _ = fmt.Fprintln(h.out)
	return nil
}

//goland:noinspection GoUnusedParameter
func (h *customHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return h
}

//goland:noinspection GoUnusedParameter
func (h *customHandler) WithGroup(name string) slog.Handler {
	return h
}

func New() *Logger {
	opts := &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}

	if os.Getenv("DEV") == "true" {
		opts.Level = slog.LevelDebug
	}

	handler := &customHandler{
		opts: *opts,
		out:  os.Stdout,
	}

	return &Logger{
		Logger: slog.New(handler),
	}
}

// Fatal 에러 로그를 발생시키고, 프로그램을 종료합니다. 치명적인 오류에 사용하세요.
func (l *Logger) Fatal(msg string, args ...any) {
	l.Error(msg, args...)
	os.Exit(1)
}
