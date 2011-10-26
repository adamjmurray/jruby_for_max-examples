class LaunchpadModel

  attr_reader :patterns
  
  def initialize
    @patterns = Array.new(8) { LaunchpadPattern.new }
  end
  
  # serialize all persistable state in the model to a Hash mapping model property to a list of numbers
  def serialize
    data = {}
    @patterns.each_with_index do |pattern,index|
      data["notes#{index}"] = pattern.notes
      data["playback#{index}"] = pattern.playback
    end
    data
  end
  
  # deserialize a single property
  def deserialize_property name,value
    case name
       when /notes([0-7])/ then @patterns[$1.to_i].notes = value
       when /playback([0-7])/ then @patterns[$1.to_i].playback = value
       else error "invalid model element: #{elemen}"
    end    
  end
  
end