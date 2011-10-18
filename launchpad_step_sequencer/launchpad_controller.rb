class LaunchpadController

  attr_reader :patterns, :selected_pattern, :selected_pattern_index
  
  def initialize launchpad_adapter, options={}
    @launchpad = launchpad_adapter
    num_patterns = options.fetch :patterns, 8
    
    # each pattern is an 8x8 matrix representing the launchpad grid, 
    # where each value in the matrix is a pair of [green brightness, red brightness] (brightness values are ints ranging from 0-3)
    @patterns = Array.new(num_patterns) { Array.new(8) { Array.new(8,0) } }
    @launchpad.all_off
    select_pattern 0
  end
  
  def select_pattern index
    prev_index = @selected_pattern_index
    @selected_pattern_index = index
    @selected_pattern = @patterns[index]    
    @launchpad.right prev_index,nil if prev_index    
    @launchpad.right index,[3,3]
    display_pattern    
  end

  def get_step x,y
    @selected_pattern[x][y]
  end

  def set_step x,y,value
    @selected_pattern[x][y]= value
    display_step x,y
  end
  
  def select_step x,y
    prev_step = @selected_step    
    @selected_step = [x,y]
    display_step *prev_step if prev_step
    display_step x,y
    step_values x,y    
  end
  
  def step_values x,y
    @patterns.collect{|pattern| pattern[x][y] }
  end
  
  ####################################
  protected
  
  def display_pattern
    for y in 0..7
      for x in 0..7      
        display_step x,y
      end
    end
  end
  
  def display_step x,y
    step_value = @selected_pattern[x][y]
    g,r = case step_value
      when 1 then [2,0]
      when 2 then [1,1]
      when 3 then [0,2]
      else [0,0]
    end
    if @selected_step == [x,y]
      g += 1
      r += 1
    end  
    @launchpad.grid x,y,[g,r]
    #puts "#{x},#{y}: [#{g}/#{r}]"    
  end 
  
  
end