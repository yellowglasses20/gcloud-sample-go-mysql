FROM golang:1.14.4-alpine3.12 AS build

ADD . /go/src/sample

WORKDIR /go/src/sample

RUN go build

FROM alpine:3.12

COPY --from=build /go/src/sample/go /usr/local/bin/

CMD ["go"]

