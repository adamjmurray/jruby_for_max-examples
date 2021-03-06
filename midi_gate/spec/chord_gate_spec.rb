require 'spec_helper'

describe ChordGate do

  let(:output) { Array.new }
  
  let(:root_on) { [60, 100] }
  let(:root_off) { [60, 0] }
  let(:third_on) { [62, 100] }
  let(:third_off) { [62, 0] }
  let(:fifth_on) { [64, 100] }
  let(:fifth_off) { [64, 0] }
  let(:gate0_on) { [0, 127] }
  let(:gate0_off) { [0, 0] }
  let(:gate1_on) { [1, 127] }
  let(:gate1_off) { [1, 0] }
  let(:gate2_on) { [2, 127] }
  let(:gate2_off) { [2, 0] }

  let(:note_on)  { root_on }
  let(:note_off) { root_off }
  let(:gate_on)  { gate0_on }
  let(:gate_off) { gate0_off }
  
  subject { ChordGate.new { |*args| output << args } }


  it_should_behave_like "a midi gate"

  it "should not send a note off until the last gate off when I've turned on multiple gates (LIFO order)" do
    n note_on
    g gate0_on
    output.clear # assume a note_on
    g gate1_on
    g gate1_off
    should_not_output
  end

  it "should not send a note off until the last gate off when I've turned on multiple gates (FIFO order)" do
    n note_on
    g gate0_on
    output.clear # assume a note_on
    g gate1_on
    g gate0_off
    should_not_output
  end

  it "should send a note off at the last gate off when I've turned on multiple gates (LIFO order)" do
    n note_on
    g gate0_on
    output.clear # assume a note_on
    g gate1_on
    g gate1_off
    g gate0_off
    should_output note_off
  end

  it "should send a note off at the last gate off when I've turned on multiple gates (FIFO order)" do
    n note_on
    g gate0_on
    output.clear # assume a note_on    
    g gate1_on
    g gate0_off
    g gate1_off
    should_output note_off
  end

  it "should not lose track of note on/off state" do
    n note_on
    g gate_on
    should_output note_on

    g gate_off
    should_output note_off

    g gate_on
    should_output note_on

    n note_off
    should_output note_off
    
    g gate_off
    should_not_output

    n note_on
    should_not_output

    g gate_on
    should_output note_on    

    g gate_off
    should_output note_off
  end

  it "should play all notes in a held chord when turning on the gate" do
    n note_on
    n third_on
    n fifth_on
    should_not_output
    g gate_on
    should_output note_on, third_on, fifth_on
  end

  it "should play each note when playing a chord while the gate is turned on" do
    g gate_on
    n note_on
    n third_on
    n fifth_on
    should_output_in_order note_on, third_on, fifth_on
  end

  it "should stop playing all notes in a held chord when turning off the gate (notes on first)" do
    n note_on
    n third_on
    n fifth_on
    g gate_on
    output.clear
    g gate_off
    should_output note_off, third_off, fifth_off
  end

  it "should stop playing all notes in a held chord when turning off the gate (gate on first)" do
    g gate_on
    n note_on
    n third_on
    n fifth_on
    output.clear
    g gate_off
    should_output note_off, third_off, fifth_off
  end

  it "should stop playing each note in a chord as they are released while the gate is turned on" do
    n note_on
    n third_on
    n fifth_on
    g gate_on
    output.clear
    n note_off
    n third_off
    n fifth_off
    should_output_in_order note_off, third_off, fifth_off
  end

  it "should handle polyphony" do
    n note_on
    n third_on
    g gate_on
    should_output note_on, third_on

    g gate_off
    should_output note_off, third_off

    g gate_on
    should_output note_on, third_on

    g gate_off
    should_output note_off, third_off

    n fifth_on
    n note_off
    n third_off
    g gate_on
    should_output fifth_on

    g gate_off
    should_output fifth_off

    n note_on
    n third_on
    g gate_on
    should_output note_on, third_on, fifth_on

    g gate_off
    should_output note_off, third_off, fifth_off
  end

end
