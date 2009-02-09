Feature: MySQL DB creation

  Scenario: Environment variable should be set
    Then ENV['TESTJOUR_DB'] should be set