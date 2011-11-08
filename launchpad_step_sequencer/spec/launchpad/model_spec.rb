require 'spec_helper'

describe Launchpad::Model do
  
  subject { Launchpad::Model.new }
  
  def array_to_json array
    '[' + array.join(',') + ']'
  end
  
  let(:default_note_pattern) { [0]*Launchpad::Pattern::DEFAULT_LENGTH }
  
  let(:default_note_pattern_json) { array_to_json(default_note_pattern) }
  
  let(:default_playback_pattern_json) {
    array_to_json([Launchpad::PlaybackPattern::NORMAL]*Launchpad::Pattern::DEFAULT_LENGTH) 
  }
  
  let(:default_track_json) { 
    '{' +
      '"note_patterns":' + array_to_json([default_note_pattern_json]*Launchpad::Track::PATTERNS) +
      ',"playback_patterns":' + array_to_json([default_playback_pattern_json]*Launchpad::Track::PATTERNS) +
    '}'
  }
  
  let(:default_model_json) {
    array_to_json([default_track_json]*Launchpad::Model::TRACKS)
  }
  
  describe "#to_json" do
    it "converts the model to JSON" do
      subject.to_json.should == default_model_json      
    end 
    
    it "reflects changes to the model" do
      subject.set_grid_step 0,3
      subject.to_json.should == default_model_json.sub('0','3') # replaced first 0 with 3
    end
  end
  
  describe "#from_json" do
    it "parses a default model from JSON" do
      subject.tracks.clear
      subject.from_json default_model_json
      subject.tracks.length.should == 8
      subject.tracks[0].note_pattern.values.should == default_note_pattern
    end
    
    it "parses a non-default model from JSON" do
      subject.from_json default_model_json.sub('0','3')
      subject.tracks[0].note_pattern.values[0].should == 3
    end
    
  end
  
end