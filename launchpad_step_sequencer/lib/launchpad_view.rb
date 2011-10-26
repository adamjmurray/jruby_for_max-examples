class LaunchpadView

  def initialize(launchpad_adapter)
    @launchpad = launchpad_adapter
    all_off
  end
  
  def all_off
    @launchpad.all_off
  end
  
  # light up a button on the right column, turning off any previously lit button
  def radio_select_right_button index
    color=[3,0]
    if @active_right_button_index
      # turn off previously lit button
      @launchpad.right @active_right_button_index, nil
    end
    @launchpad.right index, color
    @active_right_button_index = index        
  end
  
  def radio_select_arrow_button index
    color=[3,3]
    if @arrow_button_index
      # turn off previously lit button
      @launchpad.top @arrow_button_index, nil
    end
    @launchpad.top index, color
    @arrow_button_index = index        
  end
  
  def radio_select_mode_button index
    if index == 3
      color = [3,2]
    else
      color = color_for index+1
    end
    
    index += 4
    if @mode_button_index
      # turn off previously lit button
      @launchpad.top @mode_button_index, nil
    end
    @launchpad.top index, color
    @mode_button_index = index        
  end
  
  # update the 8x8 grid to display the values in a 64 element array
  def grid= grid_values 
    @grid_values = grid_values
    redraw_grid
  end
  
  def selected_grid_index= index
    prev_index = @selected_grid_index
    @selected_grid_index = index
    redraw_step prev_index if prev_index
    redraw_step index
  end
  
  def redraw_grid
    64.times{|index| redraw_step index }
  end
  
  def redraw_step index
    g,r = color_for @grid_values[index]
    if index == @selected_grid_index
      g += 1
      r += 1
    end  
    x = (index % 8)
    y = (index / 8)
    @launchpad.grid x,y,[g,r]
  end
  
  def color_for value
    case value
      when 1 then [2,0]
      when 2 then [1,2]
      when 3 then [0,2]
      else [0,0]
    end
  end
  
end
