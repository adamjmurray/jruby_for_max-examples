class Launchpad::Controller

  def initialize model, view, note_out, fx_out 
    @model,@view = model,view
    @note_out,@fx_out = note_out,fx_out
    @button_timer = Launchpad::ButtonTimer.new self
    @flam_timer = Launchpad::FlamTimer.new self
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
    if @model.patterns_screen_selected?
      @model.set_grid_step index,value
      @view.redraw_preset_grid
    else
      @model.set_grid_step index,value
      @view.redraw_step index
      if @model.fx_screen_selected?
        # TODO? distinguish between different tracks?
        pitch = index
        velocity = (value > 0 ? 127 : 0)
        @fx_out.call pitch,velocity
      end
    end
  end

  def step_pressed index
    if @model.screen_supports_timed_mode?
      if @mode_type == :timed
        @button_timer.step_pressed index
      else
        value = ( get_step(index) == @mode_type ? 0 : @mode_type )
        set_step index,value
      end
    else
      set_step index,1
    end
  end
  
  def step_released index
    if @model.fx_screen_selected?
      set_step index,0
    elsif @mode_type == :timed
      @button_timer.step_released index      
    end
  end
  
  def pulse bars,beats,units
    # assume 4/4 with 1/16 note pulses
    pulse_index = (bars-1)*16 + (beats-1)*4 + (units/120).round
    @model.pulse_index = pulse_index
    @view.redraw_pulse_index
    
    @model.tracks.each_with_index do |track,track_index|
      note_value = track.get_note(pulse_index)
      if note_value > 0        
        pitch = track_index
        velocity = 127 - (3- note_value)*40 # convert note values in range 0-3 to a velocity in the range 0-127        
        case track.get_playback(pulse_index)
          when Launchpad::PlaybackPattern::NORMAL then note_out pitch,velocity            
          when Launchpad::PlaybackPattern::FLAM  then @flam_timer.flam pitch,velocity
        end
      end      
    end
  end
  
end