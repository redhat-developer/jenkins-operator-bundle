#!/bin/sh

docker build --build-arg OPERATOR_VERSION_NEXT=${OPERATOR_VERSION} -f openshift-ci/index.Dockerfile -t ${OPERATOR_REPOSITORY}/${OPERATOR_INDEX_IMAGE}:${OPERATOR_INDEX_VERSION} .
