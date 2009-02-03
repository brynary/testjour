Feature: testjour CLI

  In order to learn how to use Testjour
  As a software engineer
  I want to see Testjour help and version information
  
  Scenario: Print version information

    When I run `testjour --version`
    Then it should pass with "testjour 0.3"
  
  Scenario: Print help information
    When I run `testjour --help`
    Then it should pass with
      """
      testjour help:
      """
      
  Scenario: Reject unknown commands
    When I run `testjour blah`
    Then it should fail with
      """
      testjour: 'blah' is not a valid testjour command. See 'testjour --help'
      """