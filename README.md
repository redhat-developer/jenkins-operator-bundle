## Re-build and Deploy


1. Build the Bundle image ( operator + OLM manifests )

```
operator-sdk bundle create --directory . quay.io/redhat-developer/jenkins-operator-bundle:v0.0.5
docker push quay.io/redhat-developer/jenkins-operator-bundle:v0.0.5
```

2. Build the Index image

```
opm index add --bundles  quay.io/redhat-developer/jenkins-operator-bundle:v0.0.5 --tag quay.io/redhat-developer/jenkins-operator-index:v0.0.5 --build-tool=docker
docker push quay.io/redhat-developer/jenkins-operator-index:v0.0.5
```

The Index image powers the listing of the Operator on OperatorHub.
