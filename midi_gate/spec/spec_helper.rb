require 'arp_gate'
require 'chord_gate'
require 'gate_shared_examples'

#
# call note handler for the main track
#
def note(note_args)
  subject.note *note_args
end
alias n note

#
# call sidechain note handler for the gate track
#
def gate(gate_args)
  subject.gate *gate_args
end
alias g gate

#
# verify output occurs in any order, then clear output for the next expectation
#
def should_output *expected_output
  output.should =~ [*expected_output]
  output.clear
end

#
# verify output occurs in the exact order, then clear output for the next expectation
#
def should_output_in_order *expected_output
  output.should == [*expected_output]
  output.clear
end

#
# verify that no output has occurred
#
def should_not_output 
  output.should be_empty
end
