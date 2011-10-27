class LaunchpadController

  def initialize model, view, note_out
    @model = model
    @view = view
    @note_out = note_out
    @button_timer = LaunchpadButtonTimer.new self
    @flam_timer = LaunchpadFlamTimer.new self
    timed_mode    
  end
  
  def note_out pitch,velocity
    @note_out.call pitch,velocity
  end
    
  def screen= index
    @model.select_screen index
    @view.redraw_screen_selection    
    self.track = @model.track_index
  end
  
  # set the input mode based on the mode button index (0-3)
  def mode= index
    @model.select_mode index    
    @view.redraw_mode_selection
    if index == 3
      timed_mode
    else
      @mode_type = index+1
      @button_timer.active = false
    end
  end
  
  def timed_mode
    @mode_type = :timed
    @button_timer.active = true
  end    
  
  def track= index
    @model.select_track index
    @button_timer.clear
    @view.redraw_track_selection
    @view.redraw_grid
    select_step @selected_step if @selected_step
  end

  def get_step index    
    @model.grid_values[index]
  end

  def set_step index,value
    @model.set_grid_step index,value
    @view.redraw_step index
  end

  def step_pressed index
    if @mode_type == :timed
      @button_timer.step_pressed index
    else
      value = ( get_step(index) == @mode_type ? 0 : @mode_type )
      set_step index,value
    end
  end
  
  def step_released index  
    @button_timer.step_released index if @mode_type == :timed    
  end
  
  def select_step index
    @selected_step = index        
    # TODO: selected_grid_index should be in the model
    @view.selected_grid_index = @model.track.get_grid_index(index)
  end
  
  def pulse index
    for track_index in 0..7
      select_step index if track_index == @model.track_index
      track = @model.tracks[track_index]            
      note_value = track.get_note(index)
      if note_value > 0        
        pitch = track_index
        velocity = 127 - (3- note_value)*40 # convert note values in range 0-3 to a velocity in the range 0-127        
        case track.get_playback(index)
          when LaunchpadTrack::PLAYBACK_NORMAL then note_out pitch,velocity            
          when LaunchpadTrack::PLAYBACK_FLAM  then @flam_timer.flam pitch,velocity
        end
      end      
    end
  end
  
end