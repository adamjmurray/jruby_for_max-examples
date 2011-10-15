require 'launchpad_adapter'
require 'launchpad_controller'

inlet_assist 'from launchpad note on', 'from launchpad control change', 'transport time (bars beats units)'
outlet_assist 'to launchpad note on', 'to launchpad control change', 'sequencer out'

@launchpad = LaunchpadAdapter.new lambda{|pitch,velocity| out0 pitch,velocity}, lambda{|number,value| out1 number,value}
@controller = LaunchpadController.new @launchpad
 
def in0 *args # note on/off
  note,velocity = *args
  if velocity > 0
    # when pressed (ignore release, when vel==0)
  
    x = note % 16
    y = note / 16  
    if x > 7
      @controller.select_pattern y
    else    
      @controller.toggle_step x,y
    end
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
  step_values = 
  @controller.step_values x,y
  @controller.select_step(x,y).each_with_index do |step_value,pattern_index|
    # todo support multiple values
    if step_value
      out2 pattern_index,100
    end  
  end
end

def all_off
  @launchpad.all_off
end 
