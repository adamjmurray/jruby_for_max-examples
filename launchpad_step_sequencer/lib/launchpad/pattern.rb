# The model state for a single 8x8 grid
class Launchpad::Pattern
    
  DEFAULT_LENGTH = 64
  
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
  
  def to_a
    @values.clone
  end

  def self.from_a values
    new values
  end

  def to_json *args
    @values.to_json(*args)
  end
  
  def self.from_json json
    new JSON.parse(json)
  end
    
end