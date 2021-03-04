## Operator Bundle for OpenShift Jenkins Operator

Build the Bundle image ( operator + OLM manifests )

```
make build
```

[![Container Image Repository on Quay](https://quay.io/repository/redhat-developer/openshift-jenkins-operator-bundle/status "Container Image Repository on Quay")](https://quay.io/repository/redhat-developer/openshift-jenkins-operator-bundle)

## Test Operator Bundle install for Openshift Jenkins operator

Feature 1: Deploy Jenkins Operator on operator hub using catalog source and new operator bundle format
``` 
As a user of Jenkins Operator
      I want to test if jenkins operator is deployed on operator hub properly
      If we need to install an operator manually using the cli 
        - ensure your catalog source is installed
        - create an OperatorGroup
        - create the Subscription object

  Background:
    Given Project [TEST_NAMESPACE] is used

  Scenario: Deploy Jenkins Operator on operator hub
    Given we have a openshift cluster
    When we create the catalog source using catalog-source.yaml
    Then We create operator group using operator-group.yaml
    And We create subscription using subscriptions.yaml
    Then we check for the csv and csv version
    And we check for the operator group
    And we check for the subscription
    Then we check for the operator pod

```
Feature 2: Install jenkins operator
```
As a user of Jenkins Operator
      I want to install a jenkins instance & trigger my jobs 
        

  Background:
    Given Project [TEST_NAMESPACE] is used

  Scenario: Install jenkins instance
    Given Jenkins operator is installed
    When we create the jenkins instance using jenkins.yaml
    Then We check for the jenkins-simple pod status
    And We check for the route

  Scenario: Deploy sample application on openshift
      Given The jenkins pod is up and runnning
      When The user enters new-app command with sample-pipeline
      Then Trigger the build using oc start-build
      Then nodejs-mongodb-example pod must come up
      And route nodejs-mongodb-example must be created and be accessible
```

## Run the Smoke Test

```
- export KUBECONFIG=<path/to/kubeconfig>
- make smoke
```
[![Container Image Repository on Quay](https://quay.io/repository/redhat-developer/openshift-jenkins-operator-index/status "Operator Index Image Repository on Quay")](https://quay.io/repository/redhat-developer/openshift-jenkins-operator-index)