class LaunchpadController

  attr_reader :screen, :track, :selected_pattern
  
  def initialize model, view, note_out
    @model = model
    @view = view
    @note_out = note_out
    @track = 0
    @button_timer = LaunchpadButtonTimer.new self
    @flam_timer = LaunchpadFlamTimer.new self
    self.screen = 0
    self.mode = 3
  end
  
  def note_out pitch,velocity
    @note_out.call pitch,velocity
  end
    
  def screen= index
    @screen = index
    @patterns = case index
      when 1 then @model.playback_patterns 
      else @model.note_patterns
    end
    @view.radio_select_arrow_button index
    self.track = @track
  end
  
  def mode= index
    if index == 3
      @mode = :timed
      @button_timer.active = true
      color = [3,2]
    else
      @mode = index+1
      @button_timer.active = false
      color = LaunchpadModel::Pattern.color_for @mode
    end
    @view.radio_select_mode_button index, color
  end    
  
  def track= index
    @track = index
    @button_timer.clear
    @selected_pattern = @patterns[index]
    @selected_step = nil    
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

  def step_pressed x,y
    if @mode == :timed
      @button_timer.step_pressed x,y
    else
      value = get_step(x,y) == @mode ? 0 : @mode        
      set_step x,y,value
    end
  end
  
  def step_released x,y
    if @mode == :timed    
      @button_timer.step_released x,y
    end
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
    for track in 0..7
      playback = @model.playback_patterns[track]
      playback_length = playback.length
      
      # TODO: this approach is too simplistic, and buggy
      # It doesn't index the active note correctly, it simply truncase from the end of the note grid.
      step = pulse_index % playback_length      
      
      x = step % 8
      y = (step / 8) % 8        
      select_step x,y if track == @track
            
      note_value = @model.note_patterns[track][x,y]
      if note_value > 0
        pitch = track
        velocity = 127 - (3- note_value)*40 # convert note values in range 0-3 to a velocity in the range 0-127        
        case playback[x,y]  
          when LaunchpadModel::PLAYBACK_NORMAL then note_out pitch,velocity            
          when LaunchpadModel::PLAYBACK_FLAM  then @flam_timer.flam pitch,velocity
        end
      end      
    end
  end
  
  def step_values x,y
     @patterns.collect.with_index do |pattern,index| 
       playback_value = @model.playback_patterns[index][x,y]       
       if playback_value > 0 # TODO: support skip, flam...
         note_value = @model.note_patterns[index][x,y]
       else
         0
       end
    end
  end
  
end