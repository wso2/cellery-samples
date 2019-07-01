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
CELLERY_ORG ?= wso2cellery
CELLERY_VERSION ?= latest

SAMPLE := pet-store
PET_BE_CELL := pet-be
PET_FE_CELL := pet-fe
CELLS := $(PET_BE_CELL) $(PET_FE_CELL)
PET_BE_COMPONENTS := catalog customers orders controller
PET_FE_COMPONENTS := portal

CELL_CLEAN_TARGETS := $(addprefix clean., $(CELLS))
CELL_CHECK_STYLE_TARGETS := $(addprefix check-style., $(CELLS))
CELL_BUILD_TARGETS := $(addprefix build., $(CELLS))
CELL_DOCKER_TARGETS := $(addprefix docker., $(CELLS))
CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push., $(CELLS))
CELL_CELLERY_BUILD_TARGETS := $(addprefix cellery-build., $(CELLS))
CELL_CELLERY_PUSH_TARGETS := $(addprefix cellery-push., $(CELLS))

PET_BE_CELL_CLEAN_TARGETS := $(addprefix clean.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_BE_CELL_CHECK_STYLE_TARGETS := $(addprefix check-style.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_BE_CELL_BUILD_TARGETS := $(addprefix build.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_BE_CELL_DOCKER_TARGETS := $(addprefix docker.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_BE_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push.$(PET_BE_CELL)., $(PET_BE_COMPONENTS))
PET_FE_CELL_CLEAN_TARGETS := $(addprefix clean.$(PET_FE_CELL)., $(PET_FE_COMPONENTS))
PET_FE_CELL_CHECK_STYLE_TARGETS := $(addprefix check-style.$(PET_FE_CELL)., $(PET_FE_COMPONENTS))
PET_FE_CELL_BUILD_TARGETS := $(addprefix build.$(PET_FE_CELL)., $(PET_FE_COMPONENTS))
PET_FE_CELL_DOCKER_TARGETS := $(addprefix docker.$(PET_FE_CELL)., $(PET_FE_COMPONENTS))
PET_FE_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push.$(PET_FE_CELL)., $(PET_FE_COMPONENTS))

COMPONENT_CLEAN_TARGETS := $(PET_BE_CELL_CLEAN_TARGETS) $(PET_FE_CELL_CLEAN_TARGETS)
COMPONENT_CHECK_STYLE_TARGETS := $(PET_BE_CELL_CHECK_STYLE_TARGETS) $(PET_FE_CELL_CHECK_STYLE_TARGETS)
COMPONENT_BUILD_TARGETS := $(PET_BE_CELL_BUILD_TARGETS) $(PET_FE_CELL_BUILD_TARGETS)
COMPONENT_DOCKER_TARGETS := $(PET_BE_CELL_DOCKER_TARGETS) $(PET_FE_CELL_DOCKER_TARGETS)
COMPONENT_DOCKER_PUSH_TARGETS := $(PET_BE_CELL_DOCKER_PUSH_TARGETS) $(PET_FE_CELL_DOCKER_PUSH_TARGETS)


all: clean build docker

.PHONY: clean
clean:
    @:

.PHONY: check-style
check-style:
    @:

.PHONY: build
build:
    @:

.PHONY: docker
docker:
    @:

.PHONY: docker-push
docker-push:
    @:

.PHONY: cellery-build
cellery-build: $(CELL_CELLERY_BUILD_TARGETS)

.PHONY: cellery-push
cellery-push: $(CELL_CELLERY_PUSH_TARGETS)


## Cell Level Targets

.PHONY: cellery-build.$(PET_BE_CELL)
cellery-build.$(PET_BE_CELL):
	cd  $(PET_BE_CELL); \
	cellery build $(PET_BE_CELL).bal $(CELLERY_ORG)/$(PET_BE_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(PET_FE_CELL)
cellery-build.$(PET_FE_CELL):
	cd  $(PET_FE_CELL); \
	cellery build $(PET_FE_CELL).bal $(CELLERY_ORG)/$(PET_FE_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-push.$(PET_BE_CELL)
cellery-push.$(PET_BE_CELL):
	cd  $(PET_BE_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_BE_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(PET_FE_CELL)
cellery-push.$(PET_FE_CELL):
	cd  $(PET_FE_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_FE_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)
