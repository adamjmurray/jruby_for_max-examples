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
    @view.radio_select_arrow_button index
    self.track = @track
  end
  
  def mode= index
    if index == 3
      @mode = :timed
      @button_timer.active = true
    else
      @mode = index+1
      @button_timer.active = false
    end
    @view.radio_select_mode_button index
  end    
  
  def track= index
    @track = index
    @button_timer.clear
    @pattern = @model.patterns[index]
    @view.radio_select_right_button index
    @view.grid = grid_values
    select_step @selected_step if @selected_step
  end
  
  # the values for the grid (in a 64 element array) that's currently displayed
  def grid_values
    case @screen
      when 1 then @pattern.playback
      else @pattern.notes
    end  
  end

  # TODO update all of these to use flat indexing 0..63
  def get_step x,y
    index = x+y*8
    grid_values[index]
  end

  # TODO update all of these to use flat indexing 0..63
  def set_step x,y,value
    index = x+y*8    
    # TODO: this logic should be encapsulated in the model
    case @screen
      when 1 then @pattern.set_playback(index,value)
      else @pattern.set_note(index,value)
    end
    @view.redraw_step index
  end

  # TODO update all of these to use flat indexing 0..63
  def step_pressed x,y
    if @mode == :timed
      @button_timer.step_pressed x,y
    else
      value = get_step(x,y) == @mode ? 0 : @mode        
      set_step x,y,value
    end
  end
  
  # TODO update all of these to use flat indexing 0..63
  def step_released x,y
    if @mode == :timed    
      @button_timer.step_released x,y
    end
  end
  
  def select_step index
    @selected_step = index    
    @view.selected_grid_index = @pattern.get_grid_index(index)
  end
  
  def pulse index
    for track in 0..7
      select_step index if track == @track
      pattern = @model.patterns[track]            
      note_value = pattern.get_note(index)
      if note_value > 0        
        pitch = track
        velocity = 127 - (3- note_value)*40 # convert note values in range 0-3 to a velocity in the range 0-127        
        case pattern.get_playback(index)
          when LaunchpadPattern::PLAYBACK_NORMAL then note_out pitch,velocity            
          when LaunchpadPattern::PLAYBACK_FLAM  then @flam_timer.flam pitch,velocity
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