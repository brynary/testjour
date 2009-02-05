Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Run passing steps
    When I run `testjour passing.feature`
    Then it should pass with "1 steps passed"
    And testjour.log should include "passing.feature"
    
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
    
  Scenario: Distribute runs
    When I run `testjour failing.feature passing.feature`
    Then it should fail with "1 steps passed"
    And the output should contain "FAIL"
    And the output should contain "1 steps failed"
    And it should run on 2 slaves