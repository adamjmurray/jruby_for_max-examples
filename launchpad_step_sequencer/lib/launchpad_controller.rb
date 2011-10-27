class LaunchpadController

  attr_reader :screen, :track, :selected_pattern
  
  def initialize model, view, note_out
    @model = model
    @view = view
    @note_out = note_out
    @track_index = 0
    @button_timer = LaunchpadButtonTimer.new self
    @flam_timer = LaunchpadFlamTimer.new self
    self.screen = 0
    self.mode = 3
  end
  
  def note_out pitch,velocity
    @note_out.call pitch,velocity
  end
    
  def screen= index
    @screen_index = index
    @view.radio_select_arrow_button index
    self.track = @track_index
  end
  
  # set the input mode based on the mode button index (0-3)
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
    @track_index = index
    @button_timer.clear
    @track = @model.tracks[index]
    @view.radio_select_right_button index
    @view.grid = grid_values
    select_step @selected_step if @selected_step
  end
  
  # the values for the grid (in a 64 element array) that's currently displayed
  def grid_values
    case @screen_index
      when 1 then @track.playback
      else @track.notes
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
    case @screen_index
      when 1 then @track.set_playback(index,value)
      else @track.set_note(index,value)
    end
    @view.redraw_step index
  end

  # TODO update all of these to use flat indexing 0..63
  def step_pressed x,y
    if @mode == :timed
      @button_timer.step_pressed x,y
    else
      value = (get_step(x,y) == @mode ? 0 : @mode)
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
    @view.selected_grid_index = @track.get_grid_index(index)
  end
  
  def pulse index
    for track_index in 0..7
      select_step index if track_index == @track_index
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