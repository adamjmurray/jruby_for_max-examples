require 'launchpad_adapter'
require 'launchpad_controller'

inlet_assist 'from launchpad note on', 'from launchpad control change', 'transport time (bars beats units)'
outlet_assist 'to launchpad note on', 'to launchpad control change', 'sequencer out'

@launchpad = LaunchpadAdapter.new lambda{|pitch,velocity| out0 pitch,velocity}, lambda{|number,value| out1 number,value}
@controller = LaunchpadController.new @launchpad
@pressed = {}
 
def in0 *args # note on/off
  note,velocity = *args
  x = note % 16
  y = note / 16  

  if velocity > 0
    if x > 7
      @pressed.clear
      @controller.select_pattern y
    else    
      value = @controller.get_step x,y
      if value == 0
        @pressed[[x,y]] = [1,Time.new]
        value = 1
      else
        value = 0
      end
      @controller.set_step x,y,value
    end
  else
    @pressed.delete [x,y]
  end
end 

def in1 *args # control change
  cc,val = *args  
  @launchpad.top (cc-104),(val > 0)
end

def in2 *args
  bars,beats,units = *args
  # assume 4/4 with 1/16 note pulses
  y = ((bars-1) %4)*2 + (beats-1)/2
  x = ((beats-1)%2)*4 + units.round/120  
  @controller.select_step(x,y).each_with_index do |step_value,pattern_index|
    # todo support multiple values
    if step_value > 0
      # step_value should range from 1-3
      velocity = 127 - (3-step_value)*40
      out2 pattern_index,velocity
    end  
  end
end

def all_off
  @launchpad.all_off
end 

BUTTON_HOLD_RATE = 0.2 # every quarter second the button is held, the value increases

@bg_thread ||= Thread.new do
  begin
  loop do
    sleep 0.1
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
  rescue
    p $!
  end  
end

at_exit do
  @bg_thread.kill if @bg_thread
  @bg_thread = nil
end