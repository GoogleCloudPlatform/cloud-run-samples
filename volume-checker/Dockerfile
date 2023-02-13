FROM golang:1.16-alpine

WORKDIR /app

COPY *.go ./

RUN go env -w GO111MODULE=off

RUN go build -o /volume-checker

RUN mkdir /volume

RUN touch /volume/hello.world

EXPOSE 8080

CMD [ "/volume-checker" ]
