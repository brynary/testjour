Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Run passing features
    When I run `testjour run passing.feature`
    Then it should pass with "."
    And testjour.log should include "passing.feature"
    
  Scenario: Run failing features
    When I run `testjour run failing.feature`
    Then it should fail with "F"
    And testjour.log should include "failing.feature"
    
  Scenario: Run undefined features
    When I run `testjour run undefined.feature`
    Then it should pass with "U"
    And testjour.log should include "undefined.feature"
  
  Scenario: Distribute runs
    When I run `testjour run --profile=slow`
    Then it should pass with ".."
    And it should run in less than 6 seconds