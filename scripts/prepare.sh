#!/bin/sh

CSV_FILE="manifests/jenkins-operator.${OPERATOR_VERSION}.clusterserviceversion.yaml"
SRC_FILE=template/jenkins-operator.version.clusterserviceversion.yaml
echo "Manifest file will be: $CSV_FILE"

sed "s|OPERATOR_VERSION|${OPERATOR_VERSION}|g" $SRC_FILE   | \
sed "s|OPERATOR_REPOSITORY|${OPERATOR_REPOSITORY}|g"       | \
sed "s|OPERATOR_IMAGE_NAME|${OPERATOR_IMAGE_NAME}|g"       | \
sed "s|OPERATOR_IMAGE_VERSION|${OPERATOR_IMAGE_VERSION}|g"  > $CSV_FILE 

