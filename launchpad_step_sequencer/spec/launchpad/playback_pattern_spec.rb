require 'spec_helper'

describe Launchpad::PlaybackPattern do
  
  subject { Launchpad::PlaybackPattern.new }
  
  let(:mute) { Launchpad::PlaybackPattern::MUTE }
  let(:flam) { Launchpad::PlaybackPattern::FLAM }
  let(:skip) { Launchpad::PlaybackPattern::SKIP }
  let(:normal) { Launchpad::PlaybackPattern::NORMAL }
   
  subject { Launchpad::PlaybackPattern.new [normal,mute,flam,normal]*16 } 
      
  describe ".new" do
    it "by default, initializes to a 64-element list containing all NORMAL values" do
      Launchpad::PlaybackPattern.new.to_a.should == Array.new(64,Launchpad::PlaybackPattern::NORMAL)
    end
    
    it "initializes with the given list" do
      subject.to_a.should == [normal,mute,flam,normal]*16
    end
  end
  
  describe "#active_indexes" do
    it "is all indexes in the pattern, when no values are SKIP" do
      subject.active_indexes.should == (0..63).to_a
    end
    
    it "is all indexes in the pattern that are not SKIP values" do
      subject[0] = skip
      subject[63] = skip
      subject.active_indexes.should == (1..62).to_a
    end
    
    it "does not cache stale data when #[]= is used to set a SKIP value" do
      subject.active_indexes.should == (0..63).to_a
      subject[0] = skip
      subject.active_indexes.should == (1..63).to_a
    end
    
    it "does not cache stale data when #[]= is used to remove a SKIP value" do
      subject[0] = skip
      subject.active_indexes.should == (1..63).to_a
      subject[0] = normal
      subject.active_indexes.should == (0..63).to_a
    end    
  end
  
  describe "#active_values" do
    it "is all the non-skip values" do
      pattern = Launchpad::PlaybackPattern.new [normal,mute,skip,flam,normal]
      pattern.active_values.should == [normal,mute,flam,normal]
    end
  end
  
  describe "#active_index?" do
    it "returns true when the value at the index is not a skip" do
      pattern = Launchpad::PlaybackPattern.new [normal,mute,skip,flam,normal]
      [0,1,3,4].each do |index|    
        pattern.active_index?(index).should be_true
      end
    end
    
    it "returns false when the value at the index is a skip" do
      pattern = Launchpad::PlaybackPattern.new [normal,mute,skip,flam,normal]
      pattern.active_index?(2).should be_false
    end    
  end

  describe "#nth_active_index" do
    it "is the same as the argument when there is no skip value at or before the given index" do
      pattern = Launchpad::PlaybackPattern.new [normal,mute,skip,flam,normal]
      pattern.nth_active_index(0).should == 0
      pattern.nth_active_index(1).should == 1      
    end
    
    it "is the offset from the begining of the pattern, not counting skip values" do
      pattern = Launchpad::PlaybackPattern.new [normal,mute,skip,flam,skip,normal]
      pattern.nth_active_index(2).should == 3
      pattern.nth_active_index(3).should == 5
    end
  end  
  
  describe "#[]=" do
    it "assigns values to the given pattern index" do
      subject[2] = 10
      subject[2].should == 10
    end
    
    it "assigns values to the given index, mod pattern length (positive arg)" do
      subject[66] = 10
      subject[2].should == 10
    end
    
    it "assigns values to the given index, mod pattern length (negative arg)" do
      subject[-1] = 10
      subject[63].should == 10
    end    
  end
  
end