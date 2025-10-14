FROM golang:1.24.6-alpine AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o /app/app

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/app ./app

ENTRYPOINT ["./app"]