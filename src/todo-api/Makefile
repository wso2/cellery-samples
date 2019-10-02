#  Copyright (c) 2019 WSO2 Inc. (http:www.wso2.org) All Rights Reserved.
#
#  WSO2 Inc. licenses this file to you under the Apache License,
#  Version 2.0 (the "License"); you may not use this file except
#  in compliance with the License.
#  You may obtain a copy of the License at
#
#  http:www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.

PROJECT_ROOT := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
GIT_REVISION := $(shell git rev-parse --verify HEAD)
DOCKER_REPO ?= wso2cellery
DOCKER_IMAGE_TAG ?= $(GIT_REVISION)

SAMPLE := todoapp

all: docker

.PHONY: clean
clean:
	@:

.PHONY: check-style
check-style:
	test -z "$$(goimports -l . | tee /dev/stderr)"

.PHONY: build
build:
	GO111MODULE=on GOOS=linux GOARCH=amd64 go build -o todos -x main.go

.PHONY: docker
docker: build
	docker build -f ./docker/todos/Dockerfile . -t ${DOCKER_REPO}/samples-${SAMPLE}-todos:${DOCKER_IMAGE_TAG}
	docker build -f ./docker/mysql/Dockerfile ./docker/mysql/ -t ${DOCKER_REPO}/samples-${SAMPLE}-mysql:${DOCKER_IMAGE_TAG}

.PHONY: docker-push
docker-push: docker
	docker push ${DOCKER_REPO}/samples-todoapp-todos:${DOCKER_IMAGE_TAG}
	docker push ${DOCKER_REPO}/samples-todoapp-mysql:${DOCKER_IMAGE_TAG}
