# name of the docker hub repository
NAME=web
REVISION_FILE := $(PWD)/../version.txt

include ../deployment/Makefile

pre-build:
	@echo add steps if any, before docker build $(IMAGE_VERSION)
ifndef NODE_PRESENT
	@echo "node not present"
	source ~/.nvm/nvm.sh && npm install
	source ~/.nvm/nvm.sh && npm run build
else
	npm install
	npm run build
endif
post-build:
	@echo cleanup garbage, if any after docker build
