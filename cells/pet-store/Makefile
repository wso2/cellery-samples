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
ADVANCED_CELL := advanced/
CELLS := $(PET_BE_CELL) $(PET_FE_CELL) $(ADVANCED_CELL)
PET_BE_COMPONENTS := catalog customers orders controller
PET_FE_COMPONENTS := portal

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

.PHONY: cellery-build.$(PET_BE_CELL)
cellery-build.$(PET_BE_CELL):
	@rm -rf $(PET_BE_CELL)/$(RESOURCES_DIR)
	cp -rf $(RESOURCES_DIR) $(PET_BE_CELL)/$(RESOURCES_DIR)
	cd  $(PET_BE_CELL); \
	cellery build $(PET_BE_CELL).bal $(CELLERY_ORG)/$(PET_BE_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(PET_FE_CELL)
cellery-build.$(PET_FE_CELL):
	cd  $(PET_FE_CELL); \
	cellery build $(PET_FE_CELL).bal $(CELLERY_ORG)/$(PET_FE_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(ADVANCED_CELL)
cellery-build.$(ADVANCED_CELL):
	cd  $(ADVANCED_CELL); \
	$(MAKE) cellery-build

.PHONY: cellery-push.$(PET_BE_CELL)
cellery-push.$(PET_BE_CELL):
	cd  $(PET_BE_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_BE_CELL)-cell:$(CELLERY_VERSION) -u $(CELLERY_USER) -p $(CELLERY_USER_PASS) -k

.PHONY: cellery-push.$(PET_FE_CELL)
cellery-push.$(PET_FE_CELL):
	cd  $(PET_FE_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_FE_CELL)-cell:$(CELLERY_VERSION) -u $(CELLERY_USER) -p $(CELLERY_USER_PASS) -k

.PHONY: cellery-push.$(ADVANCED_CELL)
cellery-push.$(ADVANCED_CELL):
	cd  $(ADVANCED_CELL); \
	$(MAKE) cellery-push
