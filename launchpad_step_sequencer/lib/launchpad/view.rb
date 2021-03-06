class Launchpad::View < Launchpad::Adapter

  def initialize(model, note_on_sender, control_change_sender, grid_sender)
    super note_on_sender, control_change_sender, grid_sender
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
  
  def redraw_pulse_index
    index = @model.selected_grid_index
    prev_index = @selected_grid_index
    @selected_grid_index = index
    
    grid_values = @model.grid_values
    selected_grid_index = @model.selected_grid_index
    
    redraw_step prev_index, grid_values, selected_grid_index if prev_index
    redraw_step index, grid_values, selected_grid_index if index
  end
  
  def redraw_grid    
    @selected_grid_index = @model.selected_grid_index
    
    if @model.patterns_screen_selected?
      colors = []     
      for track in @model.tracks
        track_colors = Array.new(Launchpad::Track::PATTERNS, 0)      
        track_colors[track.note_pattern_index] =  color_for(1)
        # TODO track_colors[track.playback_pattern_index+32 => 3
        colors += track_colors          
      end
      
    elsif @model.fx_screen_selected?
      colors = Array.new(Launchpad::Pattern::EMPTY)
      for index,value in @model.grid_values      
        colors[index] = color_for(value)
      end
      
    else
      colors =  @model.grid_values.map.with_index{|value,index| color_for(value, index==@selected_grid_index) }     
    end
    
    grid colors 
  end
  
  def redraw_step index, grid_values=@model.grid_values, selected_grid_index=@model.selected_grid_index        
    x = (index % 8)
    y = (index / 8)    
    color = color_for(grid_values[index], index==selected_grid_index)  
    grid_button x,y,color
  end
  
  def color_for value, selected=false
    case value
      when 1 then g,r = 2,0
      when 2 then g,r = 1,2
      when 3 then g,r = 0,2
      else g,r = 0,0
    end
    if selected
      g += 1
      r += 1
    end
    [g,r]
  end
  
end
