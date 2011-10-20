class LaunchpadModel

  class Pattern
    attr_accessor :grid
    
    def initialize(grid=nil)
      # each pattern is an 8x8 matrix representing the launchpad grid, 
      # where each value in the matrix is an int ranging from 0-3      
      @grid = Array.new(8) { Array.new(8,0) }
    end
    
    def [](x,y)
      # all the indexing is reversed so when we convert to/from JSON, the representation is a list of rows
      # rather than a list of columns, which I think is more intuitive
      @grid[y][x]
    end
    
    def []=(x,y,value)
      @grid[y][x] = value
    end
    
    def color_at(x,y)      
      case @grid[y][x]
        when 1 then [2,0]
        when 2 then [1,1]
        when 3 then [0,2]
        else [0,0]
      end
    end
    
    def to_json(*args)
      @grid.to_json(*args)
    end

  end

  attr_reader :patterns
  
  def initialize(num_patterns=8)
    # each pattern is an 8x8 matrix representing the launchpad grid, 
    # where each value in the matrix is an int ranging from 0-3
    @patterns = Array.new(num_patterns) { Pattern.new }
  end
  
  def to_json(*args)
    data = {patterns: @patterns}
    data.to_json(*args)
  end
  
  def from_json json
    puts "Parsing #{json}"
    data = JSON.parse json, symbolize_names: true
    p data
    patterns = data[:patterns]
    patterns.each_with_index do |grid,index|
      @patterns[index].grid = grid
    end      
  end
  
end