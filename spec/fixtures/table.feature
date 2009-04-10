Feature: Table

  Scenario Outline: Table scenarios

    Given table value "<value>"

    Examples:
      | value |
      | foo   |
      | bar   |
      | baz   |
      
  Scenario Outline: Table scenarios (multiple columns)

    Given table value "<value>"
    Then the result "<result>"

    Examples:
      | value | result |
      | foo   | foo    |
      | bar   | bar    |
      | baz   | baz    |