# The model for a single track.
# Each track stores multiple note and playback patterns, and an fx pattern.
class Launchpad::Track
  
  # Number of different patterns of each type (note/playback)
  PATTERNS = 32  
  
  # The current note pattern.  
  # each note pattern is an 8x8 matrix representing the launchpad grid, 
  # where each value in the matrix is an int ranging from 0-3    
  attr_reader :note_pattern
  
  # The current playback pattern
  # playback patterns control whether the steps in the corresponding note pattern
  # play normally, play a flam, are muted, or are skipped      
  attr_reader :playback_pattern
  
  # All patterns
  attr_reader :note_patterns, :playback_patterns

  # Indexes for the currently selected notes and playback presets.
  # There are 32 presets for each per track (the 8x8 grid is used for both notes and playback presets for a track)
  # Note: The notes and playback arrays only contain the data for the current preset. 
  #       The data for all other presets is managed in the Max patcher with the pattr system.
  attr_accessor :note_pattern_index, :playback_pattern_index    

  # A Hash mapping fx grid indexes to values (we don't store a whole 8x8 grid array because these tend to be very transient)
  attr_accessor :fx
  
  
  def initialize
    @note_patterns = Array.new(PRESETS) { Launchpad::Pattern.new }    
    @playback_patterns = Array.new(PRESETS) { Launchpad::PlaybackPattern.new }    
    select_note_pattern 0
    select_playback_pattern 0
    @fx = {}
  end
  
  def select_note_pattern index
    @note_pattern = @note_patterns[index]
    @note_preset_index = index
  end

  def select_playback_pattern index
    @playback_pattern = @playback_patterns[index]
    @playback_pattern_index = index
  end
  
  
  def active_notes
    @active_notes ||= @note_pattern.select.with_index{|_,index| @playback_pattern.active_index? index }
  end

  def active_playback
    @playback_pattern.active_values
  end
  
  def active_indexes
    @playback_pattern.active_indexes
  end
  
  # get the note value at the given index, filtering out any notes with a corresponding playback value of SKIP
  def get_note(index)
    active_notes[index % active_notes.length]
  end

  # get the playback value at the given index, filtering out any values of SKIP
  def get_playback(index)
    active_playback[index % active_playback.length]
  end

  # get the absolute (0..63 valued) grid index for the given non-skipped index
  # for example, if playback[1] is SKIP, then get_grid_index(1) will return 2 (assuming playback[2] is not SKIP)
  def get_grid_index(index)
    active_indexes[index % active_indexes.length]
  end
  
  def set_note(index,value)
    @notes[index] = value
    active_notes[get_grid_index(index)] = value
  end

  def set_playback(index,value)
    if @playback_pattern[index] = value
      # need to invalidate active cache
      @active_notes = nil
    end
  end  
  
  def notes= values    
    @notes = values
    @active_notes = nil    
  end  
  
  def playback= values
    @playback = values
    @active_playback = nil
    @active_indexes = nil    
  end

end