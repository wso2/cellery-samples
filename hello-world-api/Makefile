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
CELLERY_ORG ?= wso2cellery
CELLERY_VERSION ?= 0.2.1

SAMPLE := hello-world-api
CELL := hello-world-api
COMPONENT := hello-service

all: clean build docker

.PHONY: clean
clean:
	cd components/$(COMPONENT); \
	rm -f hello-service

.PHONY: check-style
check-style:
	cd components/$(COMPONENT); \
	test -z "$$(goimports -l . | tee /dev/stderr)"

.PHONY: build
build:
	cd components/$(COMPONENT); \
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o build/hello-service hello-service.go

.PHONY: docker
docker:
	cd components/$(COMPONENT); \
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG} .

.PHONY: docker-push
docker-push:
	cd components/$(COMPONENT); \
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}

.PHONY: cellery-build
cellery-build:
	cellery build $(CELL).bal $(CELLERY_ORG)/$(CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-push
cellery-push:
	cellery push $(CELLERY_ORG)/$(CELL)-cell:$(CELLERY_VERSION) -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)
