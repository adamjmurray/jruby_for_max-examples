class Launchpad::Model
  
  # The number of tracks
  TRACKS = 8
  
  # The list of tracks in the model
  attr_reader :tracks

  # The currently selected track
  attr_reader :track
  
  # The index of the currently selected track
  # Ranges from 0-7
  attr_reader :track_index
  
  # The index of the currently selected screen
  # Ranges from 0-3
  attr_reader :screen_index
  
  # Screen index constants
  SCREEN_NOTES = 0
  SCREEN_PLAYBACK = 1
  SCREEN_PATTERNS = 2
  SCREEN_FX = 3  
    
  # The index of the currently selected mode
  # Ranges from 0-3
  attr_reader :mode_index
  
  # Mode index constants (modes have different meanings on different screens, hence the abstract names)
  MODE_GREEN = 0
  MODE_ORANGE = 1
  MODE_RED = 2
  MODE_YELLOW = 3
  
  # The index of the current transport pulse
  # Currently this is setup to be the number of 16th notes since the beginning of the song.
  attr_accessor :pulse_index

  
  EMPTY_GRID = {}.freeze
  
  
  def initialize
    reset
  end
  
  def reset
    @tracks = Array.new(TRACKS) { Launchpad::Track.new }
    select_track 0
    @screen_index = SCREEN_NOTES
    @mode_index = MODE_YELLOW    
  end
  
  def select_track index
    @track_index = index
    @track = @tracks[index]
  end
  
  def select_screen index
    raise "Invalid screen #{@screen_index}" if not (index >= 0 and index <= 3)
    @screen_index = index
  end

  def notes_screen_selected?
    @screen_index == SCREEN_NOTES
  end
  
  def playback_screen_selected?
    @screen_index == SCREEN_PLAYBACK
  end
  
  def patterns_screen_selected?
    @screen_index == SCREEN_PATTERNS
  end

  def fx_screen_selected?
    @screen_index == SCREEN_FX
  end  
  
  def screen_supports_timed_mode?
    @screen_index < 2
  end
  
  def select_mode index
    @mode_index = index
  end
  
  def set_grid_step index,value
    case @screen_index      
      when SCREEN_NOTES 
        @track.set_note(index,value)
        
      when SCREEN_PLAYBACK 
        @track.set_playback(index,value)
        
      when SCREEN_PATTERNS
        if index < 32
          @track.select_note_pattern(index)
        else
          @track.select_playback_pattern(index-32)
        end
      
      when SCREEN_FX
        @track.fx[index] = value      
    end
  end
  
  def selected_grid_index
    if @pulse_index and @screen_index < 2 # we only should the pulse light on screens 0 and 1
      @track.get_grid_index @pulse_index
    end
  end
  
  # The values for the grid (in a 64 element array) that's currently displayed.
  # returns a 64-element Array representing every value in the grid
  # OR a Hash that maps active button indexes to values
  def grid_values
    case @screen_index
      when SCREEN_NOTES then @track.note_pattern
      when SCREEN_PLAYBACK then @track.playback_pattern
      when SCREEN_PATTERNS then {@track.note_pattern_index => 1, @track.playback_pattern_index+32 => 3}
      when SCREEN_FX then @track.fx
    end  
  end
  
  def to_json(*options)    	
    @tracks.to_json(*options)
  end

  def from_json json
    data = JSON.parse json, symbolize_names: true
    @tracks = data.map{|track_data| Launchpad::Track.from_hash track_data }
  end
  
end