# The model state for a single 8x8 grid
class Launchpad::Pattern
    
  DEFAULT_LENGTH = 64
  
  attr_reader :values
  
  def initialize(values=nil)
    # A 64-element array that contains all the values for the pattern
    @values = values ? values.to_a : Array.new(DEFAULT_LENGTH,0)    
    @length = @values.length
  end
    
  def [] index
    @values[index % @length]
  end
  
  def []= index,value
    @values[index % @length] = value    
  end
  
  def select
    @values.select
  end
  
  alias to_a values

  def self.from_a values
    new values
  end
  
  def to_json(*options)
    @values.to_json(*options)
  end
    
end