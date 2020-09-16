include common.mk

OSFLAG :=
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	OSFLAG = LINUX
endif
ifeq ($(UNAME_S),Darwin)
	OSFLAG = OSX
endif

.PHONY: prepare
prepare:
ifeq ($(OSFLAG), OSX)
	cp template/jenkins-operator.version.clusterserviceversion.yaml manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml	
	sed -i '' 's|OPERATOR_VERSION|$(OPERATOR_VERSION)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
	sed -i '' 's|OPERATOR_REPOSITORY|$(OPERATOR_REPOSITORY)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
	sed -i '' 's|OPERATOR_IMAGE_NAME|$(OPERATOR_IMAGE_NAME)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
	sed -i '' 's|OPERATOR_IMAGE_VERSION|$(OPERATOR_IMAGE_VERSION)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml	
else
	cp template/jenkins-operator.version.clusterserviceversion.yaml manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
	sed -i 's|OPERATOR_VERSION|$(OPERATOR_VERSION)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
	sed -i 's|OPERATOR_REPOSITORY|$(OPERATOR_REPOSITORY)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
	sed -i 's|OPERATOR_IMAGE_NAME|$(OPERATOR_IMAGE_NAME)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
	sed -i 's|OPERATOR_IMAGE_VERSION|$(OPERATOR_IMAGE_VERSION)|g' manifests/jenkins-operator.$(OPERATOR_VERSION).clusterserviceversion.yaml
endif

.PHONY: build
build:
	@echo "+ $@"
	/tmp/go/bin/operator-sdk version
	ls .
	/tmp/go/bin/operator-sdk bundle create --directory . $(OPERATOR_REPOSITORY)/$(OPERATOR_IMAGE_NAME)-bundle:$(OPERATOR_BUNDLE_VERSION)
	docker push $(OPERATOR_REPOSITORY)/$(OPERATOR_IMAGE_NAME)-bundle:$(OPERATOR_BUNDLE_VERSION)
	/tmp/go/bin/opm index add --bundles  $(OPERATOR_REPOSITORY)/$(OPERATOR_IMAGE_NAME)-bundle:$(OPERATOR_BUNDLE_VERSION) --tag $(OPERATOR_REPOSITORY)/$(OPERATOR_IMAGE_NAME)-index:$(OPERATOR_BUNDLE_VERSION) --build-tool=docker
	docker push $(OPERATOR_REPOSITORY)/$(OPERATOR_IMAGE_NAME)-index:$(OPERATOR_BUNDLE_VERSION)