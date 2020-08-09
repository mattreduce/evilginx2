FROM golang:1.14.7-alpine as build

RUN apk add --update \
    git \
  && rm -rf /var/cache/apk/*

WORKDIR /go/src/github.com/kgretzky/evilginx2

COPY go.mod go.sum ./

ENV GO111MODULE on

RUN go mod download

COPY . /go/src/github.com/kgretzky/evilginx2

RUN go build -o ./bin/evilginx main.go

FROM alpine:3.12

RUN apk add --update \
    ca-certificates \
  && rm -rf /var/cache/apk/*

WORKDIR /app

COPY --from=build /go/src/github.com/kgretzky/evilginx2/bin/evilginx /app/evilginx
COPY ./phishlets/*.yaml /app/phishlets/

VOLUME ["/app/phishlets/"]

EXPOSE 443 80 53/udp

ENTRYPOINT ["/app/evilginx"]