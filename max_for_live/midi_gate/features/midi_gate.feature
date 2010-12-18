Feature: Gating of Notes

  Scenario: Hold a note, then turn on the gate
    When I play "C4"
    And  I gate "60"
    Then I should hear "C4"

  Scenario: Turn on gate, then play a note
    When I gate "60"
    And  I play "C4"
    Then I should hear "C4"
