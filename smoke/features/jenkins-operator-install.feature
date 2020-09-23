Feature: Install jenkins operator

  As a user of Jenkins Operator
      I want to install a jenkins instance & trigger my jobs 
        

  Background:
    Given Project [TEST_NAMESPACE] is used

  Scenario: Install jenkins instance
    Given we jenkins operator is installed
    When we create the jenkins instance using jenkins.yaml
    Then We check for the jenkins-example pod status
    And We check for the route