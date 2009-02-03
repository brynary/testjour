Feature: testjour CLI

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Print version information

    When I run testjour --version
    Then it should pass with "testjour 0.3"
  