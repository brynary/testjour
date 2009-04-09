Feature: MySQL databases

  In order to avoid MySQL deadlocks
  As a software engineer
  I want to run my Testjour slaves with separate DBs
  
  Scenario: Create MySQL databases
    When I run `testjour --create-mysql-db mysql_db.feature`
    Then it should pass with "1 steps passed"
    And testjour.log should include "mysqladmin create testjour_runner_"
    And testjour.log should include "mysql_db.feature"
  
  Scenario: Don't create MySQL databases by default
    When I run `testjour mysql_db.feature`
    Then it should fail with "1 steps failed"
    And testjour.log should include "mysql_db.feature"
  