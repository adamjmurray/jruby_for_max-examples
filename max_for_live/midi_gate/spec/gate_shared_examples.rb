# Tests for behavior that is consistent between MonoMidiGate and PolyMidiGate

shared_examples_for "a midi gate" do
  
  it "should not play a note when a note is held, but the gate is not turned on" do
    note note_on
    should_not_output
  end
  
  it "should not play a note when a gate is turned on, but no note is held" do
    gate gate_on
    should_not_output
  end
  
  it "should play a note when I hold the note, then turn on the gate" do
    note note_on
    gate gate_on
    should_output note_on
  end
  
  it "should play a note when I turn on the gate, then hold the note" do
    gate gate_on
    note note_on
    should_output note_on
  end

  it "should end a note when I turn off the gate (note on, then gate on)" do
    note note_on
    gate gate_on
    output.clear    
    gate gate_off
    should_output note_off
  end
  
  it "should end a note when I turn off the gate (gate on, then note on)" do
    gate gate_on
    note note_on
    output.clear    
    gate gate_off
    should_output note_off
  end
  
  it "should end a note when I stop holding the note (note on, then gate on)" do
    note note_on
    gate gate_on
    output.clear    
    note note_off
    should_output note_off
  end

  it "should end a note when I stop holding the note (gate on, then note on)" do
    gate gate_on
    note note_on
    output.clear    
    note note_off
    should_output note_off
  end
    
  it "should sustain a single note when I turn on the gate multiple times" do
    note note_on
    gate gate_on
    gate gate_on
    should_output note_on
  end
  
  it "should scale the note velocity by the gate velocity" do
    subject.note 60, 100
    subject.gate 0, 50
    output.should == [[60, 100*50/127]]
  end
  
  it "should send note offs for all playing notes when reset() is called" do
    note root_on
    note third_on
    gate gate0_on
    gate gate1_on
    output.clear 
       
    subject.reset    
    should_output root_off, third_off
  end

  it "should reset state when reset() is called" do
    note note_on
    gate gate_on
    subject.reset
    output.clear
    
    note third_on
    gate gate1_on
    gate gate1_off
    should_output_in_order third_on, third_off
  end
  
end