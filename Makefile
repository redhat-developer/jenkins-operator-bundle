.PHONY: default
default: build ;



export OPERATOR_VERSION = 0.0.0
export OPERATOR_IMAGE_NAME = openshift-jenkins-operator
export OPERATOR_IMAGE_VERSION = 0.0.0
export OPERATOR_REPOSITORY = quay.io/redhat-developer
export OPERATOR_BUNDLE_VERSION = 0.0.0

.PHONY: prepare
prepare:
	@echo "Preparing bundle manifests"
	@./scripts/prepare.sh

.PHONY: build
build: prepare
	@echo "Building bundle"
	@./scripts/build.sh

.PHONY: test-bundle-install  ## Runs smoke tests to verify the bundle install
test-bundle-install:
	@echo "Testing the new operator bundle install" 
	@./scripts/test-bundle-install.sh
