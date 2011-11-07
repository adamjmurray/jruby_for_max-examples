require 'spec_helper'

describe Launchpad::Pattern do
  
  subject { Launchpad::Pattern.new [0,1,2,3]*16 }
  
  describe ".new" do
    it "by default, initializes to a 64-element list containing all 0s" do
      Launchpad::Pattern.new.to_a.should == Array.new(64,0)
    end
    
    it "initializes with the given list" do
      subject.to_a.should == [0,1,2,3]*16
    end
  end
  
  describe "#[]" do
    it "retrieves values in the pattern" do
      subject[2].should == 2
      subject[3].should == 3
      subject[4].should == 0
      subject[5].should == 1      
    end
    
    it "retrieves values, mod pattern length (positive arg)" do
      subject[64].should == subject[0]
      subject[65].should == subject[1]
    end
    
    it "retrieves values, mod pattern length (negative arg)" do
      subject[-1].should == subject[63]
      subject[-2].should == subject[62]
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
  
  describe "#to_json" do
    it "converts the values array to JSON" do
      subject.to_json.should == subject.to_a.to_s.gsub(' ', '')
    end
  end
  
  describe "#from_json" do
    it "constructs a new object from a JSON string" do
      pattern = Launchpad::Pattern.from_json "[0,1,2,3,4,5]"
      pattern.to_a.should == [0,1,2,3,4,5]
    end
  end
  
end