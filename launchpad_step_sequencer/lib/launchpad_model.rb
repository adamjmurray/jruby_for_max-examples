class LaunchpadModel

  class Pattern
    attr_accessor :grid
    
    def initialize(init_val=0)
      # each pattern is an 8x8 matrix representing the launchpad grid, 
      # where each value in the matrix is an int ranging from 0-3      
      @grid = Array.new(8) { Array.new(8,init_val) }
    end
    
    def [](x,y)
      # all the indexing is reversed so when we convert to/from JSON, the representation is a list of rows
      # rather than a list of columns, which I think is more intuitive
      @grid[y][x]
    end
    
    def []=(x,y,value)
      @grid[y][x] = value
    end
    
    def self.color_for value
      case value
        when 1 then [2,0]
        when 2 then [1,2]
        when 3 then [0,2]
        else [0,0]
      end
    end
    
    def color_at(x,y)      
      self.class.color_for @grid[y][x]
    end
  end

  # definition of values for the playback grids
  PLAYBACK_MUTE = 0
  PLAYBACK_NORMAL = 1
  PLAYBACK_FLAM = 2
  PLAYBACK_SKIP = 3
  
  # each note pattern is an 8x8 matrix representing the launchpad grid, 
  # where each value in the matrix is an int ranging from 0-3
  attr_reader :note_patterns

  # playback patterns control whether the steps in the corresponding note pattern
  # play normally, play a flam, are muted, or are skipped
  attr_reader :playback_patterns
  
  
  def initialize
    @note_patterns = Array.new(8) { Pattern.new }  
    @playback_patterns = Array.new(8) { Pattern.new(PLAYBACK_NORMAL) }
  end
  
  def serialize(*args)
    data = {}
    @note_patterns.each_with_index{|pattern,index| data["notes#{index}"] = pattern.grid.flatten }
    @playback_patterns.each_with_index{|pattern,index| data["playback#{index}"] = pattern.grid.flatten }
    data
  end
  
  def deserialize data
    element = data.shift
    case element
      when /notes([0-7])/ then @note_patterns[$1.to_i].grid = data.each_slice(8).to_a
      when /playback([0-7])/ then @playback_patterns[$1.to_i].grid = data.each_slice(8).to_a
      else error "invalid model element: #{elemen}"
    end    
  end
  
end