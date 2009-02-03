Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Run passing features
    When I run `testjour run passing.feature`
    Then it should pass with "Passed"
    And testjour.log should include "passing.feature"
    
  Scenario: Run failing features
    When I run `testjour run failing.feature`
    Then it should fail with "Failed"
    And testjour.log should include "failing.feature"
  
  Scenario: Distribute runs
    When I run `testjour run --profile=slow`
    Then this is pending
    Then it should run in less than 2 seconds