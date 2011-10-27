class LaunchpadModel

  attr_reader :tracks, :track, :track_index, :screen_index, :mode_index
  
  SCREEN_NOTES = 0
  SCREEN_PLAYBACK = 1
  SCREEN_PRESETS = 2
  SCREEN_FX = 3  
  
  MODE_GREEN = 0
  MODE_ORANGE = 1
  MODE_RED = 2
  MODE_YELLOW = 3
  
  EMPTY_GRID = {}
  
  
  def initialize
    @tracks = Array.new(8) { LaunchpadTrack.new }
    select_track 0
    @screen_index = SCREEN_NOTES
    @mode_index = MODE_YELLOW
  end
  
  def select_track index
    @track_index = index
    @track = @tracks[index]
  end
  
  def select_screen index
    @screen_index = index
  end
  
  def select_mode index
    @mode_index = index
  end
  
  def set_grid_step index,value
    case @screen_index
      when SCREEN_PLAYBACK then @track.set_playback(index,value)
      else @track.set_note(index,value)
    end
  end
  
  # The values for the grid (in a 64 element array) that's currently displayed.
  # returns a 64-element Array representing every value in the grid
  # OR a Hash that maps active button indexes to values
  def grid_values
    case @screen_index
      when SCREEN_NOTES then @track.notes
      when SCREEN_PLAYBACK then @track.playback
      when SCREEN_PRESETS then {@track.notes_preset_index => 1, @track.playback_preset_index => 2}
      else EMPTY_GRID
    end  
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