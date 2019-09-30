#!/usr/bin/env bash

GO111MODULE=on GOOS=linux GOARCH=amd64 go build -o todos -x main.go
docker build -f ./docker/todos/Dockerfile . -t wso2cellery/samples-todoapp-todos:latest
docker push wso2cellery/samples-todoapp-todos:latest

docker build -f ./docker/mysql/Dockerfile ./docker/mysql/ -t wso2cellery/samples-todoapp-mysql:latest
docker push wso2cellery/samples-todoapp-mysql:latest

rm todos
