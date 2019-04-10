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
DOCKER_REPO ?= wso2cellery
DOCKER_IMAGE_TAG ?= 0.2.0
CELLERY_ORG ?= wso2cellery
CELLERY_VERSION ?= 0.2.0

SAMPLE := pet-store
BACKEND_CELL := backend
FRONTEND_CELL := frontend
CELLS := $(BACKEND_CELL) $(FRONTEND_CELL)
BACKEND_COMPONENTS := catalog customers orders controller
FRONTEND_COMPONENTS := portal

CELL_CLEAN_TARGETS := $(addprefix clean., $(CELLS))
CELL_CHECK_STYLE_TARGETS := $(addprefix check-style., $(CELLS))
CELL_BUILD_TARGETS := $(addprefix build., $(CELLS))
CELL_DOCKER_TARGETS := $(addprefix docker., $(CELLS))
CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push., $(CELLS))
CELL_CELLERY_BUILD_TARGETS := $(addprefix cellery-build., $(CELLS))

BACKEND_CELL_CLEAN_TARGETS := $(addprefix clean.$(BACKEND_CELL)., $(BACKEND_COMPONENTS))
BACKEND_CELL_CHECK_STYLE_TARGETS := $(addprefix check-style.$(BACKEND_CELL)., $(BACKEND_COMPONENTS))
BACKEND_CELL_BUILD_TARGETS := $(addprefix build.$(BACKEND_CELL)., $(BACKEND_COMPONENTS))
BACKEND_CELL_DOCKER_TARGETS := $(addprefix docker.$(BACKEND_CELL)., $(BACKEND_COMPONENTS))
BACKEND_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push.$(BACKEND_CELL)., $(BACKEND_COMPONENTS))
FRONTEND_CELL_CLEAN_TARGETS := $(addprefix clean.$(FRONTEND_CELL)., $(FRONTEND_COMPONENTS))
FRONTEND_CELL_CHECK_STYLE_TARGETS := $(addprefix check-style.$(FRONTEND_CELL)., $(FRONTEND_COMPONENTS))
FRONTEND_CELL_BUILD_TARGETS := $(addprefix build.$(FRONTEND_CELL)., $(FRONTEND_COMPONENTS))
FRONTEND_CELL_DOCKER_TARGETS := $(addprefix docker.$(FRONTEND_CELL)., $(FRONTEND_COMPONENTS))
FRONTEND_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push.$(FRONTEND_CELL)., $(FRONTEND_COMPONENTS))

COMPONENT_CLEAN_TARGETS := $(BACKEND_CELL_CLEAN_TARGETS) $(FRONTEND_CELL_CLEAN_TARGETS)
COMPONENT_CHECK_STYLE_TARGETS := $(BACKEND_CELL_CHECK_STYLE_TARGETS) $(FRONTEND_CELL_CHECK_STYLE_TARGETS)
COMPONENT_BUILD_TARGETS := $(BACKEND_CELL_BUILD_TARGETS) $(FRONTEND_CELL_BUILD_TARGETS)
COMPONENT_DOCKER_TARGETS := $(BACKEND_CELL_DOCKER_TARGETS) $(FRONTEND_CELL_DOCKER_TARGETS)
COMPONENT_DOCKER_PUSH_TARGETS := $(BACKEND_CELL_DOCKER_PUSH_TARGETS) $(FRONTEND_CELL_DOCKER_PUSH_TARGETS)


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

.PHONY: cellery-build
cellery-build: $(CELL_CELLERY_BUILD_TARGETS)


## Cell Level Targets

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

.PHONY: cellery-build.$(BACKEND_CELL)
cellery-build.$(BACKEND_CELL):
	cd  $(BACKEND_CELL); \
	cellery build pet-be.bal $(CELLERY_ORG)/pet-be-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(FRONTEND_CELL)
cellery-build.$(FRONTEND_CELL):
	cd  $(FRONTEND_CELL); \
	cellery build pet-fe.bal $(CELLERY_ORG)/pet-fe-cell:$(CELLERY_VERSION)


## Component Level Targets

.PHONY: $(BACKEND_CELL_CLEAN_TARGETS)
$(BACKEND_CELL_CLEAN_TARGETS):
	@:

.PHONY: $(FRONTEND_CELL_CLEAN_TARGETS)
$(FRONTEND_CELL_CLEAN_TARGETS):
	$(eval COMPONENT=$(patsubst clean.$(FRONTEND_CELL).%,%,$@))
	cd  $(FRONTEND_CELL)/components/$(COMPONENT); \
	npm ci; \
	npm run clean

.PHONY: $(BACKEND_CELL_CHECK_STYLE_TARGETS)
$(BACKEND_CELL_CHECK_STYLE_TARGETS):
	$(eval COMPONENT=$(patsubst check-style.$(BACKEND_CELL).%,%,$@))
	cd  $(BACKEND_CELL)/components/$(COMPONENT); \
	npm ci; \
	npm run lint

.PHONY: $(FRONTEND_CELL_CHECK_STYLE_TARGETS)
$(FRONTEND_CELL_CHECK_STYLE_TARGETS):
	$(eval COMPONENT=$(patsubst check-style.$(FRONTEND_CELL).%,%,$@))
	cd  $(FRONTEND_CELL)/components/$(COMPONENT); \
	npm ci; \
	npm run lint

.PHONY: $(BACKEND_CELL_BUILD_TARGETS)
$(BACKEND_CELL_BUILD_TARGETS):
	@:

.PHONY: $(FRONTEND_CELL_BUILD_TARGETS)
$(FRONTEND_CELL_BUILD_TARGETS):
	$(eval COMPONENT=$(patsubst build.$(FRONTEND_CELL).%,%,$@))
	cd  $(FRONTEND_CELL)/components/$(COMPONENT); \
	npm ci; \
	npm run build

.PHONY: $(BACKEND_CELL_DOCKER_TARGETS)
$(BACKEND_CELL_DOCKER_TARGETS):
	$(eval COMPONENT=$(patsubst docker.$(BACKEND_CELL).%,%,$@))
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG} ./$(BACKEND_CELL)/components/$(COMPONENT)

.PHONY: $(FRONTEND_CELL_DOCKER_TARGETS)
$(FRONTEND_CELL_DOCKER_TARGETS):
	$(eval COMPONENT=$(patsubst docker.$(FRONTEND_CELL).%,%,$@))
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG} ./$(FRONTEND_CELL)/components/$(COMPONENT)

.PHONY: $(BACKEND_CELL_DOCKER_PUSH_TARGETS)
$(BACKEND_CELL_DOCKER_PUSH_TARGETS):
	$(eval COMPONENT=$(patsubst docker-push.$(BACKEND_CELL).%,%,$@))
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}

.PHONY: $(FRONTEND_CELL_DOCKER_PUSH_TARGETS)
$(FRONTEND_CELL_DOCKER_PUSH_TARGETS):
	$(eval COMPONENT=$(patsubst docker-push.$(FRONTEND_CELL).%,%,$@))
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}
