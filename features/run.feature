Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Run passing features
    When I run `testjour run passing.feature`
    Then it should pass with "Passed"
    
  Scenario: Run failing features
    When I run `testjour run failing.feature`
    Then it should fail with "Failed"
  