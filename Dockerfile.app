FROM golang:1.9

WORKDIR /go/src/github.com/emrachid/widgets-spa-server

RUN go get -u github.com/go-swagger/go-swagger/cmd/swagger

COPY . .

RUN go get -d -v ./...
RUN go install -v ./...
RUN swagger generate spec -o ./swagger.json

EXPOSE 80
EXPOSE 8081 

CMD ["widgets-spa-server","root","mysql-secret-pw","127.0.0.1","3306","spa", ":8081"]
