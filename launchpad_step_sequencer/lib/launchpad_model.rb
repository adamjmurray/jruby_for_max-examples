class LaunchpadModel

  attr_reader :tracks
  
  def initialize
    @tracks = Array.new(8) { LaunchpadTrack.new }
  end
  
  # serialize all persistable state in the model to a Hash mapping model property to a list of numbers
  def serialize
    data = {}
    @tracks.each_with_index do |track,index|
      data["notes#{index}"] = track.notes
      data["playback#{index}"] = track.playback
    end
    data
  end
  
  # deserialize a single property
  def deserialize_property name,value
    case name
       when /notes([0-7])/ then @tracks[$1.to_i].notes = value
       when /playback([0-7])/ then @tracks[$1.to_i].playback = value
       else error "invalid model element: #{elemen}"
    end    
  end
  
end