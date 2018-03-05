python = python2.7
SHELL=/bin/bash

CODE_SERVICES= SERVICE1 SERVICE2

# path to revision file in format latest=x.y.z , other properties ignored
REVISION_FILE := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))/version.txt
HELPER := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))/make_helper.sh $(REVISION_FILE)

# built images by ansible container will be ROLENAME-servicename
ROLE_NAME=SPECIFY

# version as per version.txt
ROLE_VERSION=$(shell source $(HELPER) ; resolveLatest)

# version as per detection, kind of auth:0.0.1-da955a4-raw
CURRENT_IMAGE_VERSION := $(shell source $(HELPER) ; getVersion)

EFFECTIVE_IMAGE_VERSION := $(ROLE_VERSION)

REGISTRY_HOST=docker.io
USERNAME=SPECIFY

all: clean_build

clean_build: clean initialize build

build:  p-env/bin/ansible-container
	@echo p-env/bin/ansible-container --debug --project-name $(ROLE_NAME) build --roles-path ./roles/ -- -vvv
	@p-env/bin/ansible-container --debug --project-name $(ROLE_NAME) build --roles-path ./roles/ -- -vvv
	@echo "Application docker image was build"

run:  p-env/bin/ansible-container
	@echo p-env/bin/ansible-container --debug --project-name $(ROLE_NAME) run --roles-path ./roles/ -- -vvv
	@p-env/bin/ansible-container --debug --project-name $(ROLE_NAME) run --roles-path ./roles/ -- -vvv
	@echo "Application environment was started"

stop:   p-env/bin/ansible-container
	@echo p-env/bin/ansible-container --debug --project-name $(ROLE_NAME) stop
	@p-env/bin/ansible-container --debug --project-name $(ROLE_NAME) stop
	@echo "Application environment was stopped"

p-env/bin/pip: p-env/bin/python
	p-env/bin/pip install -r requirements.txt

p-env/bin/python:
	virtualenv -p $(python) --no-site-packages p-env
	@touch $@

p-env/bin/ansible-container: p-env/bin/pip
	@touch $@

clean:
	@rm -rf .Python p-env roles

initialize:
	@init_quick.sh

tag:
	@$(foreach CODESERVICE,$(CODE_SERVICES), \
	echo docker tag $(ROLE_NAME)-$(CODESERVICE):latest $(USERNAME)/dockerables:$(CODESERVICE).$(EFFECTIVE_IMAGE_VERSION) ; \
	docker tag $(ROLE_NAME)-$(CODESERVICE):latest $(USERNAME)/dockerables:$(CODESERVICE).$(EFFECTIVE_IMAGE_VERSION) ; \
	echo docker tag $(ROLE_NAME)-$(CODESERVICE):latest $(USERNAME)/dockerables:$(CODESERVICE).latest ; \
	docker tag $(ROLE_NAME)-$(CODESERVICE):latest $(USERNAME)/dockerables:$(CODESERVICE).latest ; \
	)

push:
	@$(foreach CODESERVICE,$(CODE_SERVICES), \
	echo docker push $(USERNAME)/dockerables:$(CODESERVICE).$(EFFECTIVE_IMAGE_VERSION) ; \
	docker push $(USERNAME)/dockerables:$(CODESERVICE).$(EFFECTIVE_IMAGE_VERSION) ; \
	echo docker push $(USERNAME)/dockerables:$(CODESERVICE).latest ; \
	docker push $(USERNAME)/dockerables:$(CODESERVICE).latest ; \
	)

sh-conductor:
	until [ "`/usr/bin/docker inspect -f {{.State.Running}} $(ROLE_NAME)_conductor`"=="true" ]; do \
	sleep 0.1; \
        echo "Waiting for $(ROLE_NAME)..." \
	done; \
	docker exec -it $(ROLE_NAME)_conductor /bin/sh

.PHONY: all clean initialize build run stop
