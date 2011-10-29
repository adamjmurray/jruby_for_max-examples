# The model state for a single track
class LaunchpadTrack
    
  # each note pattern is an 8x8 matrix representing the launchpad grid, 
  # where each value in the matrix is an int ranging from 0-3    
  attr_accessor :notes
  
  # playback patterns control whether the steps in the corresponding note pattern
  # play normally, play a flam, are muted, or are skipped      
  attr_reader :playback

  # Indexes for the currently selected notes and playback presets.
  # There are 32 presets for each per track (the 8x8 grid is used for both notes and playback presets for a track)
  # Note: The notes and playback arrays only contain the data for the current preset. 
  #       The data for all other presets is managed in the Max patcher with the pattr system.
  attr_accessor :notes_preset_index, :playback_preset_index    

  
  # definition of values for the playback grid
  PLAYBACK_MUTE = 0
  PLAYBACK_NORMAL = 1
  PLAYBACK_FLAM = 2
  PLAYBACK_SKIP = 3
  
  SIZE = 64
  PRESETS = 32
  
  
  def initialize
    @notes = Array.new(SIZE,0)    
    @playback = Array.new(SIZE,PLAYBACK_NORMAL)
    @notes_preset_index = 0
    @playback_preset_index = 0
  end
  
  def active_notes
    @active_notes ||= @notes.select.with_index{|_,index| @playback[index] != PLAYBACK_SKIP }
  end

  def active_playback
    @active_playback ||= @playback.select{|value| value != PLAYBACK_SKIP }
  end
  
  def active_indexes
    @active_indexes ||= (
      active_index = []
      SIZE.times{|index| active_index << index if @playback[index] != PLAYBACK_SKIP } 
      active_index
    )
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
    old_value = @playback[index]
    @playback[index] = value
    if value == PLAYBACK_SKIP or old_value == PLAYBACK_SKIP
      @active_notes = nil
      @active_playback = nil
      @active_indexes = nil
    else
      active_playback[get_grid_index(index)] = value
    end
  end    
  
  def playback= values
    values.each_with_index{|value,index| set_playback(index,value) }
  end

end