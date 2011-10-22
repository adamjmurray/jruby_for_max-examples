class LaunchpadController

  attr_reader :model, :selected_pattern, :selected_pattern_index, :screen, :screen_index
  
  def initialize model, view
    @model = model
    @view = view
    @selected_pattern_index = 0
    self.screen = 0
    self.mode = 3
  end
    
  def screen= index
    @grid = case index
      when 1 then @model.playback_patterns 
      else @model.note_patterns
    end
    @view.radio_select_arrow_button index
    self.track = @selected_pattern_index
  end
  
  def mode= index
    @mode = case index
      when 0 then [0,2]
      when 1 then [1,1]
      when 2 then [2,0]
      when 3 then :timed
    end
    color = (@mode == :timed ? [3,2] : @mode)
    @view.radio_select_mode_button index, color
  end    
  
  def track= index
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
    @view.render_grid_button @selected_pattern, x, y, (@selected_step == [x,y])
  end
  
  def select_step x,y
    prev_selected_step = @selected_step
    @selected_step = [x,y]
    if prev_selected_step
      prev_x, prev_y = *prev_selected_step          
      @view.render_grid_button @selected_pattern, prev_x, prev_y
    end
    @view.render_grid_button @selected_pattern, x, y, true     
  end
  
  def pulse pulse_index
    x = pulse_index % 8
    y = (pulse_index / 8) % 8
    select_step x,y
    step_values x,y   
  end
  
  def step_values x,y
     @grid.collect do |pattern| 
       playback_value = @model.playback_patterns[@selected_pattern_index][x,y]       
       if playback_value > 0 # TODO: support skip, flam...
         note_value = @model.note_patterns[@selected_pattern_index][x,y]
       else
         0
       end
    end
  end
  
end