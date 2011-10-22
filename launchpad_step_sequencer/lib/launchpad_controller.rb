class LaunchpadController

  attr_reader :screen, :track, :selected_pattern
  
  def initialize model, view
    @model = model
    @view = view
    @track = 0
    @button_timer = ButtonTimer.new self
    self.screen = 0
    self.mode = 3
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
    x = pulse_index % 8
    y = (pulse_index / 8) % 8
    select_step x,y
    step_values x,y   
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
  
  
  # timer logic for :timed mode
  class ButtonTimer
    BUTTON_HOLD_RATE = 0.33 # every third of a second the button is held, the value increases

    def initialize controller
      @controller = controller
      @pressed = {}
      @bg_thread ||= Thread.new do
        begin
        loop do
          if @active
            unless @pressed.empty?
              now = Time.new
              for key,val in @pressed
                x,y = *key
                value,time = *val
                value_increment = ((now - time) / BUTTON_HOLD_RATE).to_i
                if value_increment > 0
                  value += value_increment
                  if value >= 3
                    value = 3
                    @pressed.delete [x,y]
                  else
                    @pressed[[x,y]] = [value,time + BUTTON_HOLD_RATE*value_increment]
                  end
                  @controller.set_step x,y,value
                end
              end
            end
            sleep 0.05            
          else
            sleep 0.5
          end
        end
        rescue
          p $!
        end  
      end
      
      at_exit do
        @bg_thread.kill if @bg_thread
        @bg_thread = nil
      end
    end
    
    def active= active
      @active = active
      clear if not active
    end
    
    def step_pressed x,y
      value = @controller.get_step x,y
      if value == 0
        @pressed[[x,y]] = [1,Time.new]
        value = 1
      else
        value = 0
      end
      @controller.set_step x,y,value      
    end

    def step_released x,y
      @pressed.delete [x,y]
    end
    
    def clear
      @pressed.clear        
    end
  end
end