class LaunchpadController

  attr_reader :model, :selected_pattern, :selected_pattern_index, :screen, :screen_index
  
  def initialize model, view
    @model = model
    @view = view
    @selected_pattern_index = 0
    select_screen 0
  end  
  
  def select_pattern index
    @selected_pattern_index = index
    @selected_pattern = @grid[index]    
    @view.radio_select_right_button index
    @view.render_grid @selected_pattern, @selected_step
  end

  def get_step x,y
    @selected_pattern[x,y]
  end

  def set_step x,y,value
    @selected_pattern[x,y]= value
    @view.render_grid_button @selected_pattern, x, y, @selected_step
  end
  
  def select_step x,y
    prev_selected_step = @selected_step
    @selected_step = [x,y]
    if prev_selected_step
      prev_x, prev_y = *prev_selected_step          
      @view.render_grid_button @selected_pattern, prev_x, prev_y
    end
    @view.render_grid_button @selected_pattern, x, y, true
    step_values x,y    
  end
  
  def step_values x,y
     @grid.collect{|pattern| pattern[x,y] }
  end
  
  def select_screen index
    @grid = case index
    when 1 then @model.playback_patterns 
    else @model.note_patterns
    end
    @view.radio_select_arrow_button index
    select_pattern @selected_pattern_index
  end
  
end