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
        when 1 then [0,2]
        when 2 then [1,2]
        when 3 then [2,0]
        else [0,0]
      end
    end
    
    def color_at(x,y)      
      self.class.color_for @grid[y][x]
    end
  end


  # each note pattern is an 8x8 matrix representing the launchpad grid, 
  # where each value in the matrix is an int ranging from 0-3
  attr_reader :note_patterns

  # playback patterns control whether the steps in the corresponding note pattern
  # play normally, play a flam, are muted, or are skipped
  attr_reader :playback_patterns
  
  
  def initialize
    @note_patterns = Array.new(8) { Pattern.new }  
    @playback_patterns = Array.new(8) { Pattern.new(3) }
  end
  
  def serialize(*args)
    @note_patterns.map{|pattern| pattern.grid }.flatten + @playback_patterns.map{|pattern| pattern.grid }.flatten
  end
  
  def deserialize data
    arrays = data.each_slice(8).each_slice(8).each_slice(8).to_a
    note_arrays,playback_arrays = *arrays    
    note_arrays.each_with_index{|grid,index| @note_patterns[index].grid = grid }
    playback_arrays.each_with_index{|grid,index| @playback_patterns[index].grid = grid }
  end
  
end