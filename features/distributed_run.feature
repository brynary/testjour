Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features distributed across hardware
  
  Scenario: Distribute runs
    Given this is pending
    Given Testjour is configured to run on localhost in a temp1 directory
    And Testjour is configured to run on localhost in a temp2 directory
    When I run `testjour failing.feature passing.feature`
    Then it should fail with "1 steps passed"
    And the output should contain "FAIL"
    And the output should contain "1 steps failed"
    And it should run on 2 slaves
    And it should run on 2 remote slaves