class LaunchpadView < LaunchpadAdapter

  def initialize(model, note_on_sender, control_change_sender)
    super note_on_sender, control_change_sender
    @model = model
    all_off
    redraw
  end
  
  def redraw
    redraw_track_selection
    redraw_screen_selection
    redraw_mode_selection    
    redraw_grid
  end
  
  def redraw_track_selection
    color = [3,0]
    radio_select_right_button @model.track_index,color
  end
  
  def redraw_screen_selection
    color = [3,3]
    radio_select_arrow_button @model.screen_index,color
  end  
  
  def redraw_mode_selection
    index = @model.mode_index
    if index == 3
      color = [3,2]
    else
      color = color_for index+1
    end
    radio_select_mode_button index,color
  end
  
  def selected_grid_index= index
    # TODO: selected_grid_index should be in the model
    prev_index = @selected_grid_index
    @selected_grid_index = index
    redraw_step prev_index if prev_index
    redraw_step index
  end
  
  def redraw_grid
    grid_values = @model.grid_values
    64.times{|index| redraw_step index, grid_values }
  end
  
  def redraw_step index, grid_values=@model.grid_values
    g,r = color_for grid_values[index]
    
    # TODO: selected_grid_index should be in the model
    if index == @selected_grid_index
      g += 1
      r += 1
    end  
    x = (index % 8)
    y = (index / 8)
    grid x,y,[g,r]
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
