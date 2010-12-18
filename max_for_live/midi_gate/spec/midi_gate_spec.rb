require 'spec_helper'

describe MidiGate do

  let(:output) { Array.new }
  subject { MidiGate.new{|*args| output << args } }

  it "should do something" do
    subject.note(1,2)
    subject.gate(1,127)
    output.should == [[1,2]]
  end
end