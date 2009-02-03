Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Run features
    When I run testjour run
    Then this is pending
    And it should pass with "foo"