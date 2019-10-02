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
DOCKER_IMAGE_TAG ?= latest-dev
CELLERY_ORG ?= wso2cellery
CELLERY_VERSION ?= latest-dev

SRC_DIR := src
CELLS_DIR := cells
COMPOSITES_DIR := composites
TESTS_DIR := tests
SAMPLES_SRC := pet-store hello-world hello-world-api todo-api
SAMPLES_CELLS := pet-store hello-world hello-world-api hipster-shop todo-service
SAMPLES_COMPOSITES := pet-store todo-service hello-world
SAMPLES_TESTS := pet-store

CLEAN_TARGETS := $(addprefix clean., $(SAMPLES_SRC))
CHECK_STYLE_TARGETS := $(addprefix check-style., $(SAMPLES_SRC))
BUILD_TARGETS := $(addprefix build., $(SAMPLES_SRC))
DOCKER_TARGETS := $(addprefix docker., $(SAMPLES_SRC))
DOCKER_PUSH_TARGETS := $(addprefix docker-push., $(SAMPLES_SRC))
CELLERY_BUILD_CELL_TARGETS := $(addprefix cellery-build., $(SAMPLES_CELLS))
CELLERY_BUILD_COMPOSITE_TARGETS := $(addprefix cellery-composite-build., $(SAMPLES_COMPOSITES))
CELLERY_PUSH_CELL_TARGETS := $(addprefix cellery-push., $(SAMPLES_CELLS))
CELLERY_PUSH_COMPOSITES_TARGETS := $(addprefix cellery-composite-push., $(SAMPLES_COMPOSITES))
TEST_CLEAN_TARGETS := $(addprefix clean-tests., $(SAMPLES_TESTS))
TEST_CHECK_STYLE_TARGETS := $(addprefix check-style-tests., $(SAMPLES_TESTS))
TEST_DOCKER_TARGETS := $(addprefix docker-tests., $(SAMPLES_TESTS))
TEST_DOCKER_PUSH_TARGETS := $(addprefix docker-push-tests., $(SAMPLES_TESTS))


all: clean build docker clean-tests check-style-tests docker-tests

.PHONY: clean
clean: $(CLEAN_TARGETS)

.PHONY: clean-tests
clean-tests: $(TEST_CLEAN_TARGETS)

.PHONY: check-style
check-style: $(CHECK_STYLE_TARGETS)

.PHONY: check-style-tests
check-style-tests: $(TEST_CHECK_STYLE_TARGETS)

.PHONY: build
build: $(BUILD_TARGETS)

.PHONY: docker
docker: $(DOCKER_TARGETS)

.PHONY: docker-tests
docker-tests: $(TEST_DOCKER_TARGETS)

.PHONY: docker-push
docker-push: $(DOCKER_PUSH_TARGETS)

.PHONY: docker-push-tests
docker-push-tests: $(TEST_DOCKER_PUSH_TARGETS)

.PHONY: cellery-build
cellery-build: $(CELLERY_BUILD_CELL_TARGETS) $(CELLERY_BUILD_COMPOSITE_TARGETS)

.PHONY: cellery-push
cellery-push: $(CELLERY_PUSH_CELL_TARGETS) $(CELLERY_PUSH_COMPOSITES_TARGETS)

## Sample Level Targets

.PHONY: $(CLEAN_TARGETS)
$(CLEAN_TARGETS):
	$(eval SAMPLE=$(patsubst clean.%,%,$@))
	@cd $(SRC_DIR)/$(SAMPLE); \
	$(MAKE) clean

.PHONY: $(TEST_CLEAN_TARGETS)
$(TEST_CLEAN_TARGETS):
	$(eval SAMPLE=$(patsubst clean-tests.%,%,$@))
	@cd $(TESTS_DIR)/$(SAMPLE); \
	$(MAKE) clean-tests

.PHONY: $(CHECK_STYLE_TARGETS)
$(CHECK_STYLE_TARGETS):
	$(eval SAMPLE=$(patsubst check-style.%,%,$@))
	@cd $(SRC_DIR)/$(SAMPLE); \
	$(MAKE) check-style

.PHONY: $(TEST_CHECK_STYLE_TARGETS)
$(TEST_CHECK_STYLE_TARGETS):
	$(eval SAMPLE=$(patsubst check-style-tests.%,%,$@))
	@cd $(TESTS_DIR)/$(SAMPLE); \
	$(MAKE) check-style-tests

.PHONY: $(BUILD_TARGETS)
$(BUILD_TARGETS):
	$(eval SAMPLE=$(patsubst build.%,%,$@))
	@cd $(SRC_DIR)/$(SAMPLE); \
	$(MAKE) build

.PHONY: $(DOCKER_TARGETS)
$(DOCKER_TARGETS):
	$(eval SAMPLE=$(patsubst docker.%,%,$@))
	@cd $(SRC_DIR)/$(SAMPLE); \
	DOCKER_REPO=$(DOCKER_REPO) DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) $(MAKE) docker

.PHONY: $(TEST_DOCKER_TARGETS)
$(TEST_DOCKER_TARGETS):
	$(eval SAMPLE=$(patsubst docker-tests.%,%,$@))
	@cd $(TESTS_DIR)/$(SAMPLE); \
	DOCKER_REPO=$(DOCKER_REPO) DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) $(MAKE) docker-tests

.PHONY: $(DOCKER_PUSH_TARGETS)
$(DOCKER_PUSH_TARGETS):
	$(eval SAMPLE=$(patsubst docker-push.%,%,$@))
	@cd $(SRC_DIR)/$(SAMPLE); \
	DOCKER_REPO=$(DOCKER_REPO) DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) $(MAKE) docker-push

.PHONY: $(TEST_DOCKER_PUSH_TARGETS)
$(TEST_DOCKER_PUSH_TARGETS):
	$(eval SAMPLE=$(patsubst docker-push-tests.%,%,$@))
	@cd $(TESTS_DIR)/$(SAMPLE); \
	DOCKER_REPO=$(DOCKER_REPO) DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) $(MAKE) docker-push-tests

.PHONY: $(CELLERY_BUILD_CELL_TARGETS)
$(CELLERY_BUILD_CELL_TARGETS):
	$(eval SAMPLE=$(patsubst cellery-build.%,%,$@))
	@cd $(CELLS_DIR)/$(SAMPLE); \
	CELLERY_ORG=$(CELLERY_ORG) CELLERY_VERSION=$(CELLERY_VERSION) $(MAKE) cellery-build

.PHONY: $(CELLERY_BUILD_COMPOSITE_TARGETS)
$(CELLERY_BUILD_COMPOSITE_TARGETS):
	$(eval SAMPLE=$(patsubst cellery-composite-build.%,%,$@))
	@cd $(COMPOSITES_DIR)/$(SAMPLE); \
	CELLERY_ORG=$(CELLERY_ORG) CELLERY_VERSION=$(CELLERY_VERSION) $(MAKE) cellery-build

.PHONY: $(CELLERY_PUSH_CELL_TARGETS)
$(CELLERY_PUSH_CELL_TARGETS):
	$(eval SAMPLE=$(patsubst cellery-push.%,%,$@))
	@cd $(CELLS_DIR)/$(SAMPLE); \
	CELLERY_REGISTRY=$(CELLERY_REGISTRY) CELLERY_ORG=$(CELLERY_ORG) CELLERY_VERSION=$(CELLERY_VERSION) \
	CELLERY_USER=$(CELLERY_USER) CELLERY_USER_PASS=$(CELLERY_USER_PASS) \
	$(MAKE) cellery-push

.PHONY: $(CELLERY_PUSH_COMPOSITES_TARGETS)
$(CELLERY_PUSH_COMPOSITES_TARGETS):
	$(eval SAMPLE=$(patsubst cellery-composite-push.%,%,$@))
	@cd $(COMPOSITES_DIR)/$(SAMPLE); \
	CELLERY_REGISTRY=$(CELLERY_REGISTRY) CELLERY_ORG=$(CELLERY_ORG) CELLERY_VERSION=$(CELLERY_VERSION) \
	CELLERY_USER=$(CELLERY_USER) CELLERY_USER_PASS=$(CELLERY_USER_PASS) \
	$(MAKE) cellery-push
