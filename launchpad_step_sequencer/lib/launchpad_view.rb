class LaunchpadView

  def initialize(launchpad_adapter)
    @launchpad = launchpad_adapter
    all_off
  end
  
  def all_off
    @launchpad.all_off
  end
  
  # light up a button on the right column, turning off any previously lit button
  def radio_select_right_button index, color=[3,3]
    if @active_right_button_index
      # turn off previously lit button
      @launchpad.right @active_right_button_index, nil
    end
    @launchpad.right index, color
    @active_right_button_index = index        
  end
  
  def radio_select_arrow_button index, color=[3,3]
    if @arrow_button_index
      # turn off previously lit button
      @launchpad.top @arrow_button_index, nil
    end
    @launchpad.top index, color
    @arrow_button_index = index        
  end

  # update the 8x8 grid to display the state of the given pattern model object
  def render_grid pattern, selected_step
    for y in 0..7
      for x in 0..7
        selected = ([x,y] == selected_step)      
        render_grid_button pattern, x, y, selected
      end
    end
  end
  
  # update the lights on a single button in the 8x8 grid
  def render_grid_button pattern, x, y, selected=false
    g,r = *pattern.color_at(x,y)
    if selected
      g += 1
      r += 1
    end  
    @launchpad.grid x,y,[g,r]
    #puts "#{x},#{y}: [#{g}/#{r}]"    
  end
  
end
