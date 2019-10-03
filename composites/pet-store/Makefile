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
USE_CASES := all-in-one-composite cell-to-composite composite-to-composite

CELL_CELLERY_BUILD_TARGETS := $(addprefix cellery-build., $(USE_CASES))
CELL_CELLERY_PUSH_TARGETS := $(addprefix cellery-push., $(USE_CASES))

all: cellery-build

.PHONY: cellery-build
cellery-build: $(CELL_CELLERY_BUILD_TARGETS)

.PHONY: cellery-push
cellery-push: $(CELL_CELLERY_PUSH_TARGETS)


.PHONY: $(CELL_CELLERY_BUILD_TARGETS)
$(CELL_CELLERY_BUILD_TARGETS):
	$(eval SAMPLE=$(patsubst cellery-build.%,%,$@))
	cd $(SAMPLE); \
	$(eval BAL_FILES:=$(wildcard $(SAMPLE)/*.bal)) \
    $(foreach file, $(BAL_FILES),  $(call celleryBuild, $(file), $(SAMPLE))) \


.PHONY: cellery-push.$(CELL_CELLERY_PUSH_TARGETS)
cellery-push.$(CELL_CELLERY_PUSH_TARGETS):
	cd  $(USE_CASES); \
	if test -f $(PET_BE_COMP).bal; \
    then cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_BE_COMP):$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS); \
    fi; \
    if test -f $(PET_FE_COMP).bal; \
    then cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_FE_COMP):$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS); \
    fi; \
    if test -f $(PET_FE_CELL).bal; \
    then cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PET_FE_CELL):$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS); \
    fi; \

define celleryBuild
    $(eval BAL_FILE:=$(word 1, $(subst ., ,$(word 2,$(subst /, ,$(1)););)))
    cd $(2); \
    cellery build $(BAL_FILE).bal $(CELLERY_ORG)/$(BAL_FILE):$(CELLERY_VERSION)
endef

define celleryPush
    $(eval BAL_FILE:=$(word 1, $(subst ., ,$(word 2,$(subst /, ,$(1)););)))
    cd $(2); \
    cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(BAL_FILE):$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS);
endef