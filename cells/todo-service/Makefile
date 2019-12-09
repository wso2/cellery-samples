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
CELLERY_VERSION ?= latest-dev

TODO_CELL := todo
ADVANCED_CELL := advanced/
CELLS := $(TODO_CELL) $(ADVANCED_CELL)

CELL_CELLERY_BUILD_TARGETS := $(addprefix cellery-build., $(CELLS))
CELL_CELLERY_PUSH_TARGETS := $(addprefix cellery-push., $(CELLS))

all: cellery-build

.PHONY: cellery-build
cellery-build: $(CELL_CELLERY_BUILD_TARGETS)

.PHONY: cellery-push
cellery-push: $(CELL_CELLERY_PUSH_TARGETS)

.PHONY: cellery-build.$(TODO_CELL)
cellery-build.$(TODO_CELL):
	cellery build $(TODO_CELL) $(CELLERY_ORG)/$(TODO_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(ADVANCED_CELL)
cellery-build.$(ADVANCED_CELL):
	cd  $(ADVANCED_CELL); \
	$(MAKE) cellery-build

.PHONY: cellery-push.$(TODO_CELL)
cellery-push.$(TODO_CELL):
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(TODO_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(ADVANCED_CELL)
cellery-push.$(ADVANCED_CELL):
	cd  $(ADVANCED_CELL); \
	$(MAKE) cellery-push
	