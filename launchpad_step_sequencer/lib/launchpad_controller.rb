class LaunchpadController

  attr_reader :model, :selected_pattern, :selected_pattern_index
  
  def initialize launchpad_adapter, model
    @launchpad = launchpad_adapter
    @model = model
    @launchpad.all_off
    select_pattern 0
  end  
  
  def select_pattern index
    prev_index = @selected_pattern_index
    @selected_pattern_index = index
    @selected_pattern = @model.patterns[index]    
    @launchpad.right prev_index,nil if prev_index    
    @launchpad.right index,[3,3]
    display_pattern    
  end

  def get_step x,y
    @selected_pattern[x,y]
  end

  def set_step x,y,value
    @selected_pattern[x,y]= value
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
    @model.patterns.collect{|pattern| pattern[x,y] }
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
    g,r = *@selected_pattern.color_at(x,y)
    if @selected_step == [x,y]
      g += 1
      r += 1
    end  
    @launchpad.grid x,y,[g,r]
    #puts "#{x},#{y}: [#{g}/#{r}]"    
  end 
  
  
end