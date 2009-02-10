Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features distributed across hardware
  
  Scenario: Distribute runs
    Given this is pending
    When I run `testjour --no-remote failing.feature passing.feature`
    Then it should fail with "1 steps passed"
    And the output should contain "FAIL"
    And the output should contain "1 steps failed"
    And it should run on 2 remote slaves