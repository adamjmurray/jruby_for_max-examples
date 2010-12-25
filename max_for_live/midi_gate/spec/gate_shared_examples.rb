# Tests for behavior that is consistent between MonoMidiGate and PolyMidiGate

shared_examples_for "a midi gate" do
  
  it "should not play a note when a note is held, but the gate is not turned on" do
    n note_on
    should_not_output
  end
  
  it "should not play a note when a gate is turned on, but no note is held" do
    g gate_on
    should_not_output
  end
  
  it "should play a note when I hold the note, then turn on the gate" do
    n note_on
    g gate_on
    should_output note_on
  end
  
  it "should play a note when I turn on the gate, then hold the note" do
    g gate_on
    n note_on
    should_output note_on
  end

  it "should end a note when I turn off the gate (note on, then gate on)" do
    n note_on
    g gate_on
    output.clear    
    g gate_off
    should_output note_off
  end
  
  it "should end a note when I turn off the gate (gate on, then note on)" do
    g gate_on
    n note_on
    output.clear    
    g gate_off
    should_output note_off
  end
  
  it "should end a note when I stop holding the note (note on, then gate on)" do
    n note_on
    g gate_on
    output.clear    
    n note_off
    should_output note_off
  end

  it "should end a note when I stop holding the note (gate on, then note on)" do
    g gate_on
    n note_on
    output.clear    
    n note_off
    should_output note_off
  end
    
  it "should sustain a single note when I turn on the gate multiple times" do
    n note_on
    g gate_on
    g gate_on
    should_output note_on
  end
  
  it "should scale the note velocity by the gate velocity" do
    note [60, 100]
    gate [0, 50]
    should_output [60, 100*50/127]
  end
  
  it "should send note offs for all playing notes when reset() is called" do
    n root_on
    n third_on
    g gate0_on
    g gate1_on
    output.clear 
    subject.reset    
    should_output root_off, third_off
  end

  it "should reset state when reset() is called" do
    n note_on
    g gate_on
    subject.reset
    output.clear
    n third_on
    g gate1_on
    g gate1_off
    should_output_in_order third_on, third_off
  end
  
end