Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel

  Scenario: Run passing steps
    When I run `testjour passing.feature`
    Then it should pass with "1 steps passed"

  Scenario: Run scenario outline tables
    When I run `testjour table.feature`
    Then it should pass with "9 steps passed"

  Scenario: Only run scenarios matching tags
    When I run `testjour --tags @foo passing.feature`
    Then it should pass with no output

  Scenario: Run inline tables
    When I run `testjour inline_table.feature`
    Then it should pass with "2 steps passed"

  Scenario: Run files from a profile
    When I run `testjour -p failing`
    Then it should fail with "1 steps failed"

  Scenario: Run failing steps
    When I run `testjour failing.feature`
    Then it should fail with "1 steps failed"
    And the output should contain "F1) FAIL"

  Scenario: Run undefined steps
    When I run `testjour -r support/env undefined.feature`
    Then it should pass with "1 steps undefined"
    And the output should contain "U1) undefined.feature:4:in `Given undefined'"

  Scenario: Strict mode
    When I run `testjour --strict -r support/env undefined.feature`
    Then it should fail with "1 steps undefined"
    And the output should contain "U1) undefined.feature:4:in `Given undefined'"

  Scenario: Run pending steps
    When I run `testjour -r support/env -r step_definitions undefined.feature`
    Then it should pass with "1 steps pending"

  Scenario: Parallel runs
    When I run `testjour failing.feature passing.feature`
    Then it should fail with "1 steps passed"
    And the output should contain "FAIL"
    And the output should contain "1 steps failed"
    And it should run on 2 slaves
    
  Scenario: Preload application
    Given a file testjour_preload.rb at the root of the project that logs "Hello, world"
    When I run `testjour passing.feature`
    And testjour.log should include "Hello, world"
