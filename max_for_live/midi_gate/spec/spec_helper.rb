require 'mono_midi_gate'
require 'poly_midi_gate'

#
# call note handler for the main track
#
def note(note_args)
  subject.note *note_args
end

#
# call sidechain note handler for the gate track
#
def gate(gate_args)
  subject.gate *gate_args
end

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