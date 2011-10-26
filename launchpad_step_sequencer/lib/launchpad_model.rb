class LaunchpadModel

  attr_reader :patterns
  
  def initialize
    @patterns = Array.new(8) { LaunchpadPattern.new }
  end
  
  def serialize(*args)
    data = {}
    error "serialize implementation needs to be updated"
    #@note_patterns.each_with_index{|pattern,index| data["notes#{index}"] = pattern.grid.flatten }
    #@playback_patterns.each_with_index{|pattern,index| data["playback#{index}"] = pattern.grid.flatten }
    data
  end
  
  def deserialize data
    error "desserialize implementation needs to be updated"    
    # element = data.shift
    # case element
    #   when /notes([0-7])/ then @note_patterns[$1.to_i].grid = data.each_slice(8).to_a
    #   when /playback([0-7])/ then @playback_patterns[$1.to_i].grid = data.each_slice(8).to_a
    #   else error "invalid model element: #{elemen}"
    # end    
  end
  
end