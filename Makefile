include scripts/colors.mk

export OPERATOR_VERSION = 0.0.0
export OPERATOR_IMAGE_NAME = openshift-jenkins-operator
export OPERATOR_IMAGE_VERSION = 0.0.0
export OPERATOR_REPOSITORY = quay.io/redhat-developer
export OPERATOR_BUNDLE_VERSION = 0.0.0
export OPERATOR_INDEX_IMAGE = openshift-jenkins-operator-index
export OPERATOR_INDEX_VERSION = 0.0.0

## This makefile is self documented: To set comment, add ## after the target

help:  ## Display this help message 
	@echo "    ${BLACK}:: ${YELLOW}make${RESET} ${BLACK}::${RESET}"
	@echo "${YELLOW}-------------------------------------------------------------------------------------------------------${RESET}"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(word 1,$(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${TARGET_COLOR}%-30s${RESET} %s\n", $$1, $$2}'

prepare: ## Prepares the bundles manifests by doing the required substitutions
	@echo "Preparing bundle manifests"
	@./scripts/prepare.sh

build: prepare	## Builds the bundle after preparing the masifests
	@echo "Building bundle"
	@./scripts/build.sh

smoke: FORCE ## Runs smoke tests to verify the bundle install
	@echo "Testing the new operator bundle install" 
	@./scripts/test-bundle-install.sh

.PHONY: container-build-index
container-build-index:
	docker build --build-arg OPERATOR_VERSION_NEXT=$(OPERATOR_VERSION) -f openshift-ci/index.Dockerfile -t $(OPERATOR_REPOSITORY)/$(OPERATOR_INDEX_IMAGE):$(OPERATOR_INDEX_VERSION) .

FORCE:
