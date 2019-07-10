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

SAMPLE := pet-store
PET_BE_CELL := pet-be
CELLS := $(PET_BE_CELL)
PET_BE_COMPONENTS := order

CELL_CLEAN_TARGETS := $(addprefix clean-tests., $(CELLS))
CELL_CHECK_STYLE_TARGETS := $(addprefix check-style-tests., $(CELLS))
CELL_DOCKER_TARGETS := $(addprefix docker-tests., $(CELLS))
CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push-tests., $(CELLS))

PET_BE_CELL_CLEAN_TARGETS := $(addprefix clean-tests.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_BE_CELL_CHECK_STYLE_TARGETS := $(addprefix check-style-tests.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_BE_CELL_DOCKER_TARGETS := $(addprefix docker-tests.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_BE_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push-tests.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))

COMPONENT_CLEAN_TARGETS := $(PET_BE_CELL_CLEAN_TARGETS)
COMPONENT_CHECK_STYLE_TARGETS := $(PET_BE_CELL_CHECK_STYLE_TARGETS)
COMPONENT_DOCKER_TARGETS := $(PET_BE_CELL_DOCKER_TARGETS)
COMPONENT_DOCKER_PUSH_TARGETS := $(PET_BE_CELL_DOCKER_PUSH_TARGETS)

all: clean-tests check-style-tests docker-tests

.PHONY: clean-tests
clean-tests: $(CELL_CLEAN_TARGETS)

.PHONY: check-style-tests
check-style-tests: $(CELL_CHECK_STYLE_TARGETS)

.PHONY: docker-tests
docker-tests: $(CELL_DOCKER_TARGETS)

.PHONY: docker-push-tests
docker-push-tests: $(CELL_DOCKER_PUSH_TARGETS)

## Cell level targets
.PHONY: $(CELL_CLEAN_TARGETS)
$(CELL_CLEAN_TARGETS):
	$(eval CELL=$(patsubst clean-tests.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix clean-tests.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_CHECK_STYLE_TARGETS)
$(CELL_CHECK_STYLE_TARGETS):
	$(eval CELL=$(patsubst check-style-tests.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix check-style-tests.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_DOCKER_TARGETS)
$(CELL_DOCKER_TARGETS):
	$(eval CELL=$(patsubst docker-tests.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix docker-tests.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_DOCKER_PUSH_TARGETS)
$(CELL_DOCKER_PUSH_TARGETS):
	$(eval CELL=$(patsubst docker-push-tests.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix docker-push-tests.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

## Component Level Targets

.PHONY: $(PET_BE_CELL_CLEAN_TARGETS)
$(PET_BE_CELL_CLEAN_TARGETS):
	$(eval COMPONENT=$(patsubst clean-tests.$(PET_BE_CELL).%,%,$@))
	cd $(PET_BE_CELL)/$(COMPONENT); \
	mvn clean

.PHONY: $(PET_BE_CELL_CHECK_STYLE_TARGETS)
$(PET_BE_CELL_CHECK_STYLE_TARGETS):
	$(eval COMPONENT=$(patsubst check-style-tests.$(PET_BE_CELL).%,%,$@))
	cd  $(PET_BE_CELL)/$(COMPONENT); \
	mvn validate

.PHONY: $(PET_BE_CELL_DOCKER_TARGETS)
$(PET_BE_CELL_DOCKER_TARGETS):
	$(eval COMPONENT=$(patsubst docker-tests.$(PET_BE_CELL).%,%,$@))
	docker build --build-arg MODULE=$(COMPONENT) -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT)-tests:${DOCKER_IMAGE_TAG} ./$(PET_BE_CELL)

.PHONY: $(PET_BE_CELL_DOCKER_PUSH_TARGETS)
$(PET_BE_CELL_DOCKER_PUSH_TARGETS):
	$(eval COMPONENT=$(patsubst docker-push-tests.$(PET_BE_CELL).%,%,$@))
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT)-tests:${DOCKER_IMAGE_TAG}
