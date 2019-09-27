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
USE_CASES := cell-and-composite
PET_BE_COMP := pet-be-comp
PET_FE_CELL := pet-fe-comp-cell
PET_FE_COMP := pet-fe-comp

CELL_CELLERY_BUILD_TARGETS := $(addprefix cellery-build., $(USE_CASES))
CELL_CELLERY_PUSH_TARGETS := $(addprefix cellery-push., $(USE_CASES))

all: cellery-build

.PHONY: cellery-build
cellery-build: $(CELL_CELLERY_BUILD_TARGETS)

.PHONY: cellery-push
cellery-push: $(CELL_CELLERY_PUSH_TARGETS)

.PHONY: cellery-build.$(USE_CASES)
cellery-build.$(USE_CASES):
	cd  $(USE_CASES); \
	if test -f $(PET_BE_COMP).bal; \
    then cellery build $(PET_BE_COMP).bal $(CELLERY_ORG)/$(PET_BE_COMP):$(CELLERY_VERSION); \
    fi; \
    if test -f $(PET_FE_COMP).bal; \
    then cellery build $(PET_FE_COMP).bal $(CELLERY_ORG)/$(PET_FE_COMP):$(CELLERY_VERSION); \
    fi; \
    if test -f $(PET_FE_CELL).bal; \
    then cellery build $(PET_FE_CELL).bal $(CELLERY_ORG)/$(PET_FE_CELL):$(CELLERY_VERSION); \
    fi; \

.PHONY: cellery-push.$(USE_CASES)
cellery-push.$(USE_CASES):
	cd  $(PET_BE_CELL); \
	if test -f $(PET_BE_COMP).bal; \
    then cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_BE_COMP):$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS); \
    fi; \
    if test -f $(PET_FE_COMP).bal; \
    then cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_FE_COMP):$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS); \
    fi; \
    if test -f $(PET_FE_CELL).bal; \
    then cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_FE_CELL):$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS); \
    fi; \
