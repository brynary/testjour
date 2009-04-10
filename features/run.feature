Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Run passing steps
    When I run `testjour passing.feature`
    Then it should pass with "1 steps passed"
    And testjour.log should include "passing.feature"
    
  Scenario: Run scenario outline tables
    When I run `testjour table.feature`
    Then it should pass with "9 steps passed"
    And testjour.log should include "table.feature"
    
  Scenario: Run inline tables
    When I run `testjour inline_table.feature`
    Then it should pass with "2 steps passed"
    And testjour.log should include "inline_table.feature"
    
  Scenario: Run files from a profile
    When I run `testjour --profile=failing`
    Then it should fail with "1 steps failed"
    And testjour.log should include "failing.feature"
    
  Scenario: Run failing steps
    When I run `testjour failing.feature`
    Then it should fail with "1 steps failed"
    And the output should contain "FAIL"
    And testjour.log should include "failing.feature"
    
  Scenario: Run undefined steps
    When I run `testjour -r support/env.rb undefined.feature`
    Then it should pass with "1 steps undefined"
    And testjour.log should include "undefined.feature"
    
  Scenario: Run pending steps
    When I run `testjour -r support/env.rb -r step_definitions undefined.feature`
    Then it should pass with "1 steps pending"
    And testjour.log should include "undefined.feature"
    
  Scenario: Parallel runs
    When I run `testjour failing.feature passing.feature`
    Then it should fail with "1 steps passed"
    And the output should contain "FAIL"
    And the output should contain "1 steps failed"
    And it should run on 2 slaves