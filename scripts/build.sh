#!/bin/sh

operator-sdk bundle create --package ${OPERATOR_IMAGE_NAME} \
                           --directory ./manifests ${OPERATOR_REPOSITORY}/${OPERATOR_IMAGE_NAME}-bundle:${OPERATOR_VERSION}
docker push ${OPERATOR_REPOSITORY}/${OPERATOR_IMAGE_NAME}-bundle:${OPERATOR_VERSION}
opm index add --bundles  ${OPERATOR_REPOSITORY}/${OPERATOR_IMAGE_NAME}-bundle:${OPERATOR_VERSION} \
              --tag ${OPERATOR_REPOSITORY}/${OPERATOR_IMAGE_NAME}-index:${OPERATOR_VERSION} \
              --build-tool=docker
docker push ${OPERATOR_REPOSITORY}/${OPERATOR_IMAGE_NAME}-index:${OPERATOR_VERSION}

