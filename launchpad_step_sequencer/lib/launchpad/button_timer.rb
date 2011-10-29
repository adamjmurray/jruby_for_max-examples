# Handles updating button state when in "timed" mode where holding a button longer increase it's value
class Launchpad::ButtonTimer
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
              for index,val in @pressed
                value,time = *val
                value_increment = ((now - time) / BUTTON_HOLD_RATE).to_i
                if value_increment > 0
                  value += value_increment
                  if value >= 3
                    value = 3
                    @pressed.delete index
                  else
                    @pressed[index] = [value,time + BUTTON_HOLD_RATE*value_increment]
                  end
                  @controller.set_step index,value
                end
              end
            end
            sleep 0.05            
          else
            sleep 0.5
          end
        end
      rescue => e
        error e.inspect
        error e.backtrace
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
  
  def step_pressed index
    value = @controller.get_step index
    if value == 0
      @pressed[index] = [1,Time.new]
      value = 1
    else
      value = 0
    end
    @controller.set_step index,value      
  end

  def step_released index
    @pressed.delete index
  end
  
  def clear
    @pressed.clear        
  end
end