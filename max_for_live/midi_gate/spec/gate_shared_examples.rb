# Tests for behavior that is consistent between MonoMidiGate and PolyMidiGate

shared_examples_for "a midi gate" do
  
  it "should not play a n when a n is held, but the g is not turned on" do
    n note_on
    should_not_output
  end
  
  it "should not play a n when a g is turned on, but no n is held" do
    g gate_on
    should_not_output
  end
  
  it "should play a n when I hold the note, then turn on the gate" do
    n note_on
    g gate_on
    should_output note_on
  end
  
  it "should play a n when I turn on the gate, then hold the note" do
    g gate_on
    n note_on
    should_output note_on
  end

  it "should end a n when I turn off the g (n on, then g on)" do
    n note_on
    g gate_on
    output.clear    
    g gate_off
    should_output note_off
  end
  
  it "should end a n when I turn off the g (g on, then n on)" do
    g gate_on
    n note_on
    output.clear    
    g gate_off
    should_output note_off
  end
  
  it "should end a n when I stop holding the n (n on, then g on)" do
    n note_on
    g gate_on
    output.clear    
    n note_off
    should_output note_off
  end

  it "should end a n when I stop holding the n (g on, then n on)" do
    g gate_on
    n note_on
    output.clear    
    n note_off
    should_output note_off
  end
    
  it "should sustain a single n when I turn on the g multiple times" do
    n note_on
    g gate_on
    g gate_on
    should_output note_on
  end
  
  it "should scale the n velocity by the g velocity" do
    note [60, 100]
    gate [0, 50]
    should_output [60, 100*50/127]
  end
  
  it "should send n offs for all playing notes when reset() is called" do
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