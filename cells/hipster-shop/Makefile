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

SAMPLE := hipster-store
ADS_CELL := ads
CART_CELL := cart
CHECKOUT_CELL := checkout
PRODUCTS_CELL := products
FRONT_END_CELL := front-end
CELLS := $(ADS_CELL) $(CART_CELL) $(PRODUCTS_CELL) $(CHECKOUT_CELL)  $(FRONT_END_CELL)

CELL_CELLERY_BUILD_TARGETS := $(addprefix cellery-build., $(CELLS))
CELL_CELLERY_PUSH_TARGETS := $(addprefix cellery-push., $(CELLS))

all: cellery-build

.PHONY: cellery-build
cellery-build: $(CELL_CELLERY_BUILD_TARGETS)

.PHONY: cellery-push
cellery-push: $(CELL_CELLERY_PUSH_TARGETS)

.PHONY: cellery-build.$(ADS_CELL)
cellery-build.$(ADS_CELL):
	cd  $(ADS_CELL); \
	cellery build $(ADS_CELL).bal $(CELLERY_ORG)/$(ADS_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(CART_CELL)
cellery-build.$(CART_CELL):
	cd  $(CART_CELL); \
	cellery build $(CART_CELL).bal $(CELLERY_ORG)/$(CART_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(CHECKOUT_CELL)
cellery-build.$(CHECKOUT_CELL):
	cd  $(CHECKOUT_CELL); \
	cellery build $(CHECKOUT_CELL).bal $(CELLERY_ORG)/$(CHECKOUT_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(PRODUCTS_CELL)
cellery-build.$(PRODUCTS_CELL):
	cd  $(PRODUCTS_CELL); \
	cellery build $(PRODUCTS_CELL).bal $(CELLERY_ORG)/$(PRODUCTS_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-build.$(FRONT_END_CELL)
cellery-build.$(FRONT_END_CELL):
	cd  $(FRONT_END_CELL); \
	cellery build $(FRONT_END_CELL).bal $(CELLERY_ORG)/$(FRONT_END_CELL)-cell:$(CELLERY_VERSION)

.PHONY: cellery-push.$(ADS_CELL)
cellery-push.$(ADS_CELL):
	cd  $(ADS_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(ADS_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(CART_CELL)
cellery-push.$(CART_CELL):
	cd  $(CART_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(CART_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(CHECKOUT_CELL)
cellery-push.$(CHECKOUT_CELL):
	cd  $(CHECKOUT_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(CHECKOUT_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(PRODUCTS_CELL)
cellery-push.$(PRODUCTS_CELL):
	cd  $(PRODUCTS_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(PRODUCTS_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)

.PHONY: cellery-push.$(FRONT_END_CELL)
cellery-push.$(FRONT_END_CELL):
	cd  $(FRONT_END_CELL); \
	cellery push $(if $(CELLERY_REGISTRY),$(CELLERY_REGISTRY)/)$(CELLERY_ORG)/$(FRONT_END_CELL)-cell:$(CELLERY_VERSION)  -u $(CELLERY_USER) -p $(CELLERY_USER_PASS)
