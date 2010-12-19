require 'spec_helper'

describe MonoMidiGate do

  let(:output) { Array.new }
  let(:note_on) { [60, 100] }
  let(:note_off) { [60, 0] }
  let(:third_on) { [62, 100] }
  let(:third_off) { [62, 0] }
  let(:fifth_on) { [64, 100] }
  let(:fifth_off) { [64, 0] }
  let(:gate_on) { [0, 127] }
  let(:gate_off) { [0, 0] }
  let(:second_gate_on) { [1, 127] }
  let(:second_gate_off) { [1, 0] }
  subject { MonoMidiGate.new { |*args| output << args } }

  it "should play a note when I hold a note, then turn on the gate" do
    subject.note *note_on
    subject.gate *gate_on
    output.should == [note_on]
  end

  it "should play a note when I turn on the gate, then hold a note" do
    subject.gate *gate_on
    subject.note *note_on
    output.should == [note_on]
  end

  it "should end a note when I turn off the gate" do
    subject.note *note_on
    subject.gate *gate_on
    subject.gate *gate_off
    output.should == [note_on, note_off]
  end

  it "should end a note when I stop holding the note" do
    subject.note *note_on
    subject.gate *gate_on
    subject.note *note_off
    output.should == [note_on, note_off]
  end

  it "should sustain a single note when I turn on the gate multiple times" do
    subject.note *note_on
    subject.gate *gate_on
    subject.gate *gate_on
    output.should == [note_on]
  end

  it "should not send a note off until the last gate off when I've turned on the gate multiple times (LIFO order)" do
    subject.note *note_on
    subject.gate *gate_on
    subject.gate *second_gate_on
    subject.gate *second_gate_off
    output.should == [note_on]
  end

  it "should not send a note off until the last gate off when I've turned on the gate multiple times (FIFO order)" do
    subject.note *note_on
    subject.gate *gate_on
    subject.gate *second_gate_on
    subject.gate *gate_off
    output.should == [note_on]
  end

  it "should send a note off at the last gate off when I've turned on the gate multiple times (LIFO order)" do
    subject.note *note_on
    subject.gate *gate_on
    subject.gate *second_gate_on
    subject.gate *second_gate_off
    subject.gate *gate_off
    output.should == [note_on, note_off]
  end

  it "should send a note off at the last gate off when I've turned on the gate multiple times (FIFO order)" do
    subject.note *note_on
    subject.gate *gate_on
    subject.gate *second_gate_on
    subject.gate *gate_off
    subject.gate *second_gate_off
    output.should == [note_on, note_off]
  end

  it "should scale the note velocity by the gate velocity" do
    subject.note 60,100
    subject.gate 0,50
    output.should == [[60, 100*50/127]]
  end

  it "should reset state when reset() is called" do
    subject.note *note_on
    subject.gate *gate_on
    output.clear
    subject.reset
    subject.note *note_on
    subject.gate *second_gate_on
    subject.gate *second_gate_off
    output.should == [note_on, note_off]    
  end

  it "should play all notes in a held chord when turning on the gate" do
    subject.note *note_on
    subject.note *third_on
    subject.note *fifth_on
    subject.gate *gate_on
    output.should =~ [note_on,third_on,fifth_on]
  end

  it "should play each note when playing a chord while the gate is turned on" do
    subject.gate *gate_on
    subject.note *note_on
    subject.note *third_on
    subject.note *fifth_on
    output.should == [note_on,third_on,fifth_on]    
  end

  it "should stop playing all notes in a held chord when turning on the gate" do
    subject.note *note_on
    subject.note *third_on
    subject.note *fifth_on
    subject.gate *gate_on
    output.clear

    subject.gate *gate_off
    output.should =~ [note_off,third_off,fifth_off]
  end

  it "should stop playing each note in a chord as they are released while the gate is turned on" do
    subject.note *note_on
    subject.note *third_on
    subject.note *fifth_on
    subject.gate *gate_on
    output.clear

    subject.note *note_off
    subject.note *third_off
    subject.note *fifth_off        
    output.should == [note_off,third_off,fifth_off]
  end

end