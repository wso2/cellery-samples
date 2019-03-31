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
DOCKER_IMAGE_TAG ?= latest

SAMPLE := pet-store
CELLS := backend frontend
BACKEND_COMPONENTS := catalog customers orders controller
FRONTEND_COMPONENTS := portal

CELL_CLEAN_TARGETS := $(addprefix clean., $(CELLS))
CELL_BUILD_TARGETS := $(addprefix build., $(CELLS))
CELL_DOCKER_TARGETS := $(addprefix docker., $(CELLS))
CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push., $(CELLS))

BACKEND_CELL_CLEAN_TARGETS := $(addprefix clean.backend., $(BACKEND_COMPONENTS))
BACKEND_CELL_BUILD_TARGETS := $(addprefix build.backend., $(BACKEND_COMPONENTS))
BACKEND_CELL_DOCKER_TARGETS := $(addprefix docker.backend., $(BACKEND_COMPONENTS))
BACKEND_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push.backend., $(BACKEND_COMPONENTS))
FRONTEND_CELL_CLEAN_TARGETS := $(addprefix clean.frontend., $(FRONTEND_COMPONENTS))
FRONTEND_CELL_BUILD_TARGETS := $(addprefix build.frontend., $(FRONTEND_COMPONENTS))
FRONTEND_CELL_DOCKER_TARGETS := $(addprefix docker.frontend., $(FRONTEND_COMPONENTS))
FRONTEND_CELL_DOCKER_PUSH_TARGETS := $(addprefix docker-push.frontend., $(FRONTEND_COMPONENTS))

COMPONENT_CLEAN_TARGETS := $(BACKEND_CELL_CLEAN_TARGETS) $(FRONTEND_CELL_CLEAN_TARGETS)
COMPONENT_BUILD_TARGETS := $(BACKEND_CELL_BUILD_TARGETS) $(FRONTEND_CELL_BUILD_TARGETS)
COMPONENT_DOCKER_TARGETS := $(BACKEND_CELL_DOCKER_TARGETS) $(FRONTEND_CELL_DOCKER_TARGETS)
COMPONENT_DOCKER_PUSH_TARGETS := $(BACKEND_CELL_DOCKER_PUSH_TARGETS) $(FRONTEND_CELL_DOCKER_PUSH_TARGETS)


all: clean build docker


.PHONY: clean
clean: $(CELL_CLEAN_TARGETS)

.PHONY: build
build: $(CELL_BUILD_TARGETS)

.PHONY: docker
docker: $(CELL_DOCKER_TARGETS)

.PHONY: docker-push
docker-push: $(CELL_DOCKER_PUSH_TARGETS)


## Cell Level Targets

.PHONY: $(CELL_CLEAN_TARGETS)
$(CELL_CLEAN_TARGETS):
	$(eval CELL=$(patsubst clean.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z]' '[A-Z]'))
	@CELL=$(CELL) $(MAKE) $(addprefix clean.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_BUILD_TARGETS)
$(CELL_BUILD_TARGETS):
	$(eval CELL=$(patsubst build.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z]' '[A-Z]'))
	@CELL=$(CELL) $(MAKE) $(addprefix build.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_DOCKER_TARGETS)
$(CELL_DOCKER_TARGETS):
	$(eval CELL=$(patsubst docker.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z]' '[A-Z]'))
	@CELL=$(CELL) $(MAKE) $(addprefix docker.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))

.PHONY: $(CELL_DOCKER_PUSH_TARGETS)
$(CELL_DOCKER_PUSH_TARGETS):
	$(eval CELL=$(patsubst docker-push.%,%,$@))
	$(eval CELL_UPPERCASE=$(shell echo $(CELL) | tr '[a-z]' '[A-Z]'))
	@CELL=$(CELL) $(MAKE) $(addprefix docker-push.$(CELL)., $($(CELL_UPPERCASE)_COMPONENTS))


## Component Level Targets

.PHONY: $(BACKEND_CELL_CLEAN_TARGETS)
$(BACKEND_CELL_CLEAN_TARGETS):
	@:

.PHONY: $(FRONTEND_CELL_CLEAN_TARGETS)
$(FRONTEND_CELL_CLEAN_TARGETS):
	$(eval COMPONENT=$(patsubst clean.frontend.%,%,$@))
	cd  $(CELL)/components/$(COMPONENT); \
	npm install; \
	npm run clean

.PHONY: $(BACKEND_CELL_BUILD_TARGETS)
$(BACKEND_CELL_BUILD_TARGETS):
	@:

.PHONY: $(FRONTEND_CELL_BUILD_TARGETS)
$(FRONTEND_CELL_BUILD_TARGETS):
	$(eval COMPONENT=$(patsubst build.frontend.%,%,$@))
	cd  $(CELL)/components/$(COMPONENT); \
	npm install; \
	npm run build

.PHONY: $(COMPONENT_DOCKER_TARGETS)
$(COMPONENT_DOCKER_TARGETS): $($(shell echo $(CELL) | tr '[a-z]' '[A-Z]')_CELL_BUILD_TARGETS)
	$(eval COMPONENT=$(patsubst docker.$(CELL).%,%,$@))
	docker build -t ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG} ./$(CELL)/components/$(COMPONENT)

.PHONY: $(COMPONENT_DOCKER_PUSH_TARGETS)
$(COMPONENT_DOCKER_PUSH_TARGETS):
	$(eval COMPONENT=$(patsubst docker-push.$(CELL).%,%,$@))
	docker push ${DOCKER_REPO}/samples-$(SAMPLE)-$(COMPONENT):${DOCKER_IMAGE_TAG}
