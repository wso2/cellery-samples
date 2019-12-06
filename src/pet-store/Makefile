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
PET_FE_CELL := pet-fe
LOAD_GEN_CELL := load-gen
CELLS := $(PET_BE_CELL) $(PET_FE_CELL) $(LOAD_GEN_CELL)
PET_BE_COMPONENTS := catalog customers orders controller
PET_FE_COMPONENTS := portal
LOAD_GEN_COMPONENTS := load-gen

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
LOAD_GEN_CELL_CLEAN_TARGETS := $(addprefix clean.$(LOAD_GEN_CELL)., $(LOAD_GEN_COMPONENTS))
LOAD_GEN_CELL_CHECK_STYLE_TARGETS := $(addprefix check-style.$(LOAD_GEN_CELL)., $(LOAD_GEN_COMPONENTS))
LOAD_GEN_CELL_BUILD_TARGETS := $(addprefix build.$(LOAD_GEN_CELL)., $(LOAD_GEN_COMPONENTS))
LOAD_GEN_CELL_DOCKER_TARGETS := $(addprefix docker.$(LOAD_GEN_CELL)., $(LOAD_GEN_COMPONENTS))
LOAD_GEN_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push.$(LOAD_GEN_CELL)., $(LOAD_GEN_COMPONENTS))

RESOURCES_DIR := resources

all: clean build docker

.PHONY: clean
clean: $(CELL_CLEAN_TARGETS)

.PHONY: check-style
check-style: $(CELL_CHECK_STYLE_TARGETS)

.PHONY: build
build: $(CELL_BUILD_TARGETS)

.PHONY: docker
docker: $(CELL_DOCKER_TARGETS)

.PHONY: docker-push
docker-push: $(CELL_DOCKER_PUSH_TARGETS)

## Cell level targets
.PHONY: $(CELL_CLEAN_TARGETS)
$(CELL_CLEAN_TARGETS):
	$(eval CELL=$(patsubst clean.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix clean.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_CHECK_STYLE_TARGETS)
$(CELL_CHECK_STYLE_TARGETS):
	$(eval CELL=$(patsubst check-style.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix check-style.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_BUILD_TARGETS)
$(CELL_BUILD_TARGETS):
	$(eval CELL=$(patsubst build.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix build.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_DOCKER_TARGETS)
$(CELL_DOCKER_TARGETS):
	$(eval CELL=$(patsubst docker.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix docker.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_DOCKER_PUSH_TARGETS)
$(CELL_DOCKER_PUSH_TARGETS):
	$(eval CELL=$(patsubst docker-push.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z-]' '[A-Z_]'))
	@CELL=$(CELL) $(MAKE) $(addprefix docker-push.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

## Component Level Targets

.PHONY: $(PET_BE_CELL_CLEAN_TARGETS)
$(PET_BE_CELL_CLEAN_TARGETS):
	@:

.PHONY: $(PET_FE_CELL_CLEAN_TARGETS)
$(PET_FE_CELL_CLEAN_TARGETS):
	$(eval COMPONENT=$(patsubst clean.$(PET_FE_CELL).%,%,$@))
	cd  $(PET_FE_CELL)/$(COMPONENT); \
	npm ci; \
	npm run clean

.PHONY: $(LOAD_GEN_CELL_CLEAN_TARGETS)
$(LOAD_GEN_CELL_CLEAN_TARGETS):
	@:

.PHONY: $(PET_BE_CELL_CHECK_STYLE_TARGETS)
$(PET_BE_CELL_CHECK_STYLE_TARGETS):
	$(eval COMPONENT=$(patsubst check-style.$(PET_BE_CELL).%,%,$@))
	cd  $(PET_BE_CELL)/$(COMPONENT); \
	npm ci; \
	npm run lint

.PHONY: $(PET_FE_CELL_CHECK_STYLE_TARGETS)
$(PET_FE_CELL_CHECK_STYLE_TARGETS):
	$(eval COMPONENT=$(patsubst check-style.$(PET_FE_CELL).%,%,$@))
	cd  $(PET_FE_CELL)/$(COMPONENT); \
	npm ci; \
	npm run lint

.PHONY: $(LOAD_GEN_CELL_CHECK_STYLE_TARGETS)
$(LOAD_GEN_CELL_CHECK_STYLE_TARGETS):
	@:

.PHONY: $(PET_BE_CELL_BUILD_TARGETS)
$(PET_BE_CELL_BUILD_TARGETS):
	@:

.PHONY: $(PET_FE_CELL_BUILD_TARGETS)
$(PET_FE_CELL_BUILD_TARGETS):
	$(eval COMPONENT=$(patsubst build.$(PET_FE_CELL).%,%,$@))
	cd  $(PET_FE_CELL)/$(COMPONENT); \
	npm ci; \
	npm run build

.PHONY: $(LOAD_GEN_CELL_BUILD_TARGETS)
$(LOAD_GEN_CELL_BUILD_TARGETS):
	@:

.PHONY: $(PET_BE_CELL_DOCKER_TARGETS)
$(PET_BE_CELL_DOCKER_TARGETS):
	$(eval COMPONENT=$(patsubst docker.$(PET_BE_CELL).%,%,$@))
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG} ./$(PET_BE_CELL)/$(COMPONENT)
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}v2 ./$(PET_BE_CELL)/$(COMPONENT)

.PHONY: $(PET_FE_CELL_DOCKER_TARGETS)
$(PET_FE_CELL_DOCKER_TARGETS):
	$(eval COMPONENT=$(patsubst docker.$(PET_FE_CELL).%,%,$@))
	cp -f ../../cells/$(SAMPLE)/$(PET_BE_CELL)/$(RESOURCES_DIR)/pet-store.swagger.json $(PET_FE_CELL)/$(COMPONENT)/$(RESOURCES_DIR)/
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG} ./$(PET_FE_CELL)/$(COMPONENT)

.PHONY: $(LOAD_GEN_CELL_DOCKER_TARGETS)
$(LOAD_GEN_CELL_DOCKER_TARGETS):
	$(eval COMPONENT=$(patsubst docker.$(LOAD_GEN_CELL).%,%,$@))
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG} ./$(LOAD_GEN_CELL)/$(COMPONENT)


.PHONY: $(PET_BE_CELL_DOCKER_PUSH_TARGETS)
$(PET_BE_CELL_DOCKER_PUSH_TARGETS):
	$(eval COMPONENT=$(patsubst docker-push.$(PET_BE_CELL).%,%,$@))
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}v2

.PHONY: $(PET_FE_CELL_DOCKER_PUSH_TARGETS)
$(PET_FE_CELL_DOCKER_PUSH_TARGETS):
	$(eval COMPONENT=$(patsubst docker-push.$(PET_FE_CELL).%,%,$@))
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}

.PHONY: $(LOAD_GEN_CELL_DOCKER_PUSH_TARGETS)
$(LOAD_GEN_CELL_DOCKER_PUSH_TARGETS):
	$(eval COMPONENT=$(patsubst docker-push.$(LOAD_GEN_CELL).%,%,$@))
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}
