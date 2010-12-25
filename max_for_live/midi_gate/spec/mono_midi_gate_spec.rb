require 'spec_helper'

describe MonoMidiGate do

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
  
  subject { MonoMidiGate.new { |*args| output << args } }


  it_should_behave_like "a midi gate"

  it "should not send a note off until the last gate off when I've turned on the gate multiple times (LIFO order)" do
    note note_on
    gate gate0_on
    gate gate1_on
    gate gate1_off
    should_output note_on
  end

  it "should not send a note off until the last gate off when I've turned on the gate multiple times (FIFO order)" do
    note note_on
    gate gate0_on
    gate gate1_on
    gate gate0_off
    should_output note_on
  end

  it "should send a note off at the last gate off when I've turned on the gate multiple times (LIFO order)" do
    note note_on
    gate gate0_on
    gate gate1_on
    gate gate1_off
    gate gate0_off
    should_output_in_order note_on, note_off
  end

  it "should send a note off at the last gate off when I've turned on the gate multiple times (FIFO order)" do
    note note_on
    gate gate0_on
    gate gate1_on
    gate gate0_off
    gate gate1_off
    should_output_in_order note_on, note_off
  end

  it "should not lose track of note on/off state" do
    note note_on
    gate gate_on
    output.should == [note_on]
    output.clear

    gate gate_off
    output.should == [note_off]
    output.clear

    gate gate_on
    output.should == [note_on]
    output.clear

    note note_off
    output.should == [note_off]
    output.clear

    gate gate_off
    output.should == []

    note note_on
    output.should == []

    gate gate_on
    output.should == [note_on]
    output.clear

    gate gate_off
    output.should == [note_off]
    output.clear
  end

  it "should play all notes in a held chord when turning on the gate" do
    note note_on
    note third_on
    note fifth_on
    output.should == []
    gate gate_on
    output.should =~ [note_on, third_on, fifth_on]
  end

  it "should play each note when playing a chord while the gate is turned on" do
    gate gate_on
    note note_on
    note third_on
    note fifth_on
    output.should == [note_on, third_on, fifth_on]
  end

  it "should stop playing all notes in a held chord when turning off the gate (notes on first)" do
    note note_on
    note third_on
    note fifth_on
    gate gate_on
    output.clear

    gate gate_off
    output.should =~ [note_off, third_off, fifth_off]
  end

  it "should stop playing all notes in a held chord when turning off the gate (gate on first)" do
    gate gate_on

    note note_on
      note third_on
      note fifth_on
      output.clear
      gate gate_off
      should_output note_off, third_off, fifth_off
    end

  it "should stop playing each note in a chord as they are released while the gate is turned on" do
    note note_on
    note third_on
    note fifth_on
    gate gate_on
    output.clear
    note note_off
    note third_off
    note fifth_off
    should_output_in_order note_off, third_off, fifth_off
  end

  it "should handle polyphony" do
    note note_on
    note third_on
    gate gate_on
    should_output note_on, third_on

    gate gate_off
    should_output note_off, third_off

    gate gate_on
    should_output note_on, third_on

    gate gate_off
    should_output note_off, third_off

    note fifth_on
    note note_off
    note third_off
    gate gate_on
    should_output fifth_on

    gate gate_off
    should_output fifth_off

    note note_on
    note third_on
    gate gate_on
    should_output note_on, third_on, fifth_on

    gate gate_off
    should_output note_off, third_off, fifth_off
  end

end
