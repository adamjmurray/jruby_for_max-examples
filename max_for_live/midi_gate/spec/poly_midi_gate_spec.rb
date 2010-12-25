require 'spec_helper'

describe PolyMidiGate do

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
  
  subject { PolyMidiGate.new { |*args| output << args } }

  it_should_behave_like "a midi gate"

  it "should argpeggiate a chord when I hold a chord, then turn the gates on" do
    subject.note *root_on
    subject.note *third_on
    subject.note *fifth_on
    subject.gate *gate0_on
    output.should == [root_on]

    output.clear
    subject.gate *gate1_on
    output.should == [third_on]

    output.clear
    subject.gate *gate2_on
    output.should == [fifth_on]

    output.clear
    subject.gate *gate1_off
    output.should == [third_off]

    output.clear
    subject.gate *gate2_off
    output.should == [fifth_off]
  end

  it "should play notes when I turn on multiple gates, then hold down notes" do
    subject.gate *gate0_on
    subject.gate *gate1_on
    output.should == []

    subject.note *root_on
    output.should == [root_on]

    output.clear
    subject.note *third_on
    output.should == [third_on]

    output.clear
    subject.gate *gate0_off
    output.should == [root_off]

  end

end
