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
CELLERY_VERSION ?= 0.6.0

PET_BE_AS_CELL := pet-be-auto-scale
PET_BE_ZS_CELL := pet-be-zero-scale
LOAD_GEN_CELL := load-gen
PET_BE_CELL := pet-be
CELLS := $(PET_BE_AS_CELL) $(PET_BE_ZS_CELL) $(LOAD_GEN_CELL) $(PET_BE_CELL)

RESOURCES_DIR := resources

CELL_CLEAN_TARGETS := $(addprefix clean., $(CELLS))
CELL_CHECK_STYLE_TARGETS := $(addprefix check-style., $(CELLS))
CELL_BUILD_TARGETS := $(addprefix build., $(CELLS))
CELL_DOCKER_TARGETS := $(addprefix docker., $(CELLS))
CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push., $(CELLS))
CELL_CELLERY_BUILD_TARGETS := $(addprefix cellery-build., $(CELLS))
CELL_CELLERY_PUSH_TARGETS := $(addprefix cellery-push., $(CELLS))

all: cellery-build

.PHONY: cellery-build
cellery-build: $(CELL_CELLERY_BUILD_TARGETS)

.PHONY: cellery-push
cellery-push: $(CELL_CELLERY_PUSH_TARGETS)

.PHONY: cellery-build.$(PET_BE_AS_CELL)
cellery-build.$(PET_BE_AS_CELL):
	cellery build $(PET_BE_AS_CELL) $(CELLERY_ORG)/$(PET_BE_AS_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(PET_BE_ZS_CELL)
cellery-build.$(PET_BE_ZS_CELL):
	cellery build $(PET_BE_ZS_CELL) $(CELLERY_ORG)/$(PET_BE_ZS_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(LOAD_GEN_CELL)
cellery-build.$(LOAD_GEN_CELL):
	cd  $(LOAD_GEN_CELL); \
	cellery build $(LOAD_GEN_CELL).bal $(CELLERY_ORG)/$(LOAD_GEN_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(PET_BE_CELL)
cellery-build.$(PET_BE_CELL):
	cellery build $(PET_BE_CELL) $(CELLERY_ORG)/$(PET_BE_CELL)-cell:$(CELLERY_VERSION)v2

.PHONY: cellery-push.$(PET_BE_AS_CELL)
cellery-push.$(PET_BE_AS_CELL):
	cd  $(PET_BE_AS_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_BE_AS_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(PET_BE_ZS_CELL)
cellery-push.$(PET_BE_ZS_CELL):
	cd  $(PET_BE_ZS_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_BE_ZS_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(LOAD_GEN_CELL)
cellery-push.$(LOAD_GEN_CELL):
	cd  $(LOAD_GEN_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(LOAD_GEN_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(PET_BE_CELL)
cellery-push.$(PET_BE_CELL):
	cd  $(PET_BE_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_BE_CELL)-cell:$(CELLERY_VERSION)v2  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)
