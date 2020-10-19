FROM quay.io/operator-framework/upstream-registry-builder as builder

# 0.0.0 points to the templated manifests for CI
ARG OPERATOR_VERSION_NEXT=0.0.0
ARG REG_URL=quay.io/redhat-developer/openshift-jenkins-operator

RUN mkdir -p /tmp/manifests
COPY manifests/openshift-jenkins-operator/"${OPERATOR_VERSION_NEXT}" /tmp/manifests/

# Replace template vars when in CI
RUN find /tmp/manifests/ -type f -exec sed -i "s|IMAGE_REGISTRY/OPERATOR_IMAGE:IMAGE_TAG|${REG_URL}:${OPERATOR_VERSION_NEXT}|g" {} \; || :

# Build index database
RUN pwd
RUN ls -laR /tmp/manifests
RUN /bin/initializer -m /tmp/manifests -o ./index.db

FROM quay.io/operator-framework/upstream-opm-builder

COPY --from=builder ./index.db /database/index.db

EXPOSE 50051
ENTRYPOINT ["/bin/opm"]
CMD ["registry", "serve", "--database", "/database/index.db"]

LABEL operators.operatorframework.io.index.database.v1=/database/index.db