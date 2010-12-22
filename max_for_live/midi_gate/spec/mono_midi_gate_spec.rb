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

  def note(note_args)
    subject.note *note_args
  end

  def gate(gate_args)
    subject.gate *gate_args
  end

  it "should play a note when I hold a note, then turn on the gate" do
    note note_on
    gate gate_on
    output.should == [note_on]
  end

  it "should play a note when I turn on the gate, then hold a note" do
    gate gate_on
    note note_on
    output.should == [note_on]
  end

  it "should end a note when I turn off the gate" do
    note note_on
    gate gate_on
    gate gate_off
    output.should == [note_on, note_off]
  end

  it "should end a note when I stop holding the note" do
    note note_on
    gate gate_on
    note note_off
    output.should == [note_on, note_off]
  end

  it "should sustain a single note when I turn on the gate multiple times" do
    note note_on
    gate gate_on
    gate gate_on
    output.should == [note_on]
  end

  it "should not send a note off until the last gate off when I've turned on the gate multiple times (LIFO order)" do
    note note_on
    gate gate_on
    gate second_gate_on
    gate second_gate_off
    output.should == [note_on]
  end

  it "should not send a note off until the last gate off when I've turned on the gate multiple times (FIFO order)" do
    note note_on
    gate gate_on
    gate second_gate_on
    gate gate_off
    output.should == [note_on]
  end

  it "should send a note off at the last gate off when I've turned on the gate multiple times (LIFO order)" do
    note note_on
    gate gate_on
    gate second_gate_on
    gate second_gate_off
    gate gate_off
    output.should == [note_on, note_off]
  end

  it "should send a note off at the last gate off when I've turned on the gate multiple times (FIFO order)" do
    note note_on
    gate gate_on
    gate second_gate_on
    gate gate_off
    gate second_gate_off
    output.should == [note_on, note_off]
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

  it "should scale the note velocity by the gate velocity" do
    subject.note 60, 100
    subject.gate 0, 50
    output.should == [[60, 100*50/127]]
  end

  it "should reset state when reset() is called" do
    note note_on
    gate gate_on
    output.clear
    subject.reset
    note note_on
    gate second_gate_on
    gate second_gate_off
    output.should == [note_on, note_off]
  end

  it "should play all notes in a held chord when turning on the gate" do
    note note_on
    note third_on
    note fifth_on
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

  it "should stop playing all notes in a held chord when turning on the gate" do
    note note_on
    note third_on
    note fifth_on
    gate gate_on
    output.clear

    gate gate_off
    output.should =~ [note_off, third_off, fifth_off]
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
    output.should == [note_off, third_off, fifth_off]
  end

end
