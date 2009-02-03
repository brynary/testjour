Feature: Run Features

  In order to write software quicker
  As a software engineer
  I want to run my Cucumber features in parallel
  
  Scenario: Run passing steps
    When I run `testjour run passing.feature`
    Then it should pass with "."
    And testjour.log should include "passing.feature"
    
  Scenario: Run files from a profile
    When I run `testjour run --profile=failing`
    Then it should fail with "F"
    And testjour.log should include "failing.feature"
    
  Scenario: Run failing steps
    When I run `testjour run failing.feature`
    Then it should fail with "F"
    And testjour.log should include "failing.feature"
    
  Scenario: Run undefined steps
    When I run `testjour run -r support/env.rb undefined.feature`
    Then it should pass with "U"
    And testjour.log should include "undefined.feature"
    
  Scenario: Run pending steps
    When I run `testjour run -r support/env.rb -r step_definitions undefined.feature`
    Then it should pass with "P"
    And testjour.log should include "undefined.feature"
  
  Scenario: Distribute runs
    When I run `testjour run -r step_definitions slow`
    Then it should pass with ".."
    And it should run in less than 6 seconds