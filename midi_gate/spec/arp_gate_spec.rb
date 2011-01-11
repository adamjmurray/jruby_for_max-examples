require 'spec_helper'

describe ArpGate do

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
  
  let(:root_gate_on)  { gate0_on }
  let(:root_gate_off)  { gate0_off }
  
  subject { ArpGate.new { |*args| output << args } }

  it_should_behave_like "a midi gate"
  
  context "one gate, 2 notes" do    
    context "gate on first" do
      before(:each) do
        g root_gate_on
      end
      it "should hold a matching note" do # how to explain the modular arithmetic logic succinctly?
        n root_on
        n third_on
        should_output root_on
      end
      it "should change notes if the new note matches" do # how to explain the modular arithmetic logic succinctly?
        n third_on        
        n root_on
        should_output_in_order third_on, third_off, root_on
      end      
    end
  end
  
  context "repeated single gate" do
    it "should turn one note on and off" do
      n root_on
      n third_on
      n fifth_on
      g gate_on
      should_output root_on
      g gate_off
      should_output root_off
      g gate_on
      should_output root_on
      g gate_off
      should_output root_off
    end    
  end

  it "should argpeggiate a chord when I hold a chord, then turn the gates on" do
    n root_on
    n third_on
    n fifth_on
    g gate0_on
    should_output root_on

    output.clear
    g gate1_on
    should_output third_on

    output.clear
    g gate2_on
    should_output fifth_on

    output.clear
    g gate1_off
    should_output third_off

    output.clear
    g gate2_off
    should_output fifth_off
  end

  it "should play notes when I turn on multiple gates, then hold down notes" do
    g gate0_on
    g gate1_on
    should_not_output

    n root_on
    should_output root_on

    output.clear
    n third_on
    should_output third_on

    output.clear
    g gate0_off
    should_output root_off
  end

end
