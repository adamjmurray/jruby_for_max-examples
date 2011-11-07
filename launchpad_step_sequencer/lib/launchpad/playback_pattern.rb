# The model state for a single 8x8 grid
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
      @values.each_with_index{|value,index| active_indexes << index unless value == SKIP }
      active_indexes
    )
  end
  
  # the pattern index for the given non-skipped index (the offset from the begining of the pattern, not counting SKIP values)
  # for example, if playback[1] is SKIP, then get_grid_index(1) will return 2 (assuming playback[2] is not SKIP)
  def active_index(offset)
    active_indexes[offset % active_indexes.length]
  end

  # return true when the active playback cache is invalidated
  def []= index,value
    old_value = @values[index % @length]    
    @values[index % @length] = value
    if value == SKIP or old_value == SKIP
      @active_indexes = nil
      true
    else
      false
    end
  end
    
end