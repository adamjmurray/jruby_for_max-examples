# The model state for a single 8x8 grid
# Playback patterns control whether the steps in the corresponding note pattern
# play normally, play a flam, are muted, or are skipped
class Launchpad::PlaybackPattern < Launchpad::Pattern
  
  # definition of values for playback patterns
  MUTE = 0
  NORMAL = 1
  FLAM = 2
  SKIP = 3
  
  def initialize(values = nil)
    super ( values || Array.new(DEFAULT_LENGTH,NORMAL) )
  end
  
  def active_indexes
    @active_indexes ||= (
      active_indexes = []
      @values.each_with_index{|value,index| active_indexes << index if value != SKIP }
      active_indexes
    )
  end
  
  def active_values
    @active_values ||= @values.select{|value| value != SKIP }
  end
  
  def active_index? index
    @values[index % @length] != SKIP
  end
  
  # given an offset from the beginning of the pattern that doesn't count SKIP values,
  # this method returns the actual pattern index
  # for example, if playback[1] is SKIP, then get_grid_index(1) will return 2 (assuming playback[2] is not SKIP)
  def nth_active_index offset
    active_indexes[offset % active_indexes.length]
  end  

  # return true when the active playback cache is invalidated
  def []= index,value
    old_value = @values[index % @length]    
    @values[index % @length] = value
    if value == SKIP or old_value == SKIP
      @active_indexes = nil
      @active_values = nil
      true
    else
      active_values[nth_active_index(index)] = value
      false
    end
  end
    
end