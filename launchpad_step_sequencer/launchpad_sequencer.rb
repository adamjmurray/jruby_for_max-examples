$LOAD_PATH << File.join( File.dirname(__FILE__), 'vendor', 'json_pure' )
require 'json'
require 'lib/launchpad_adapter'
require 'lib/launchpad_model'
require 'lib/launchpad_view'
require 'lib/launchpad_controller'

inlet_assist 'from launchpad note on', 'from launchpad control change', 'transport time (bars beats units)', 'model load'
outlet_assist 'to launchpad note on', 'to launchpad control change', 'sequencer out', 'model dump'

@launchpad = LaunchpadAdapter.new lambda{|pitch,velocity| out0 pitch,velocity}, lambda{|number,value| out1 number,value}
@model = LaunchpadModel.new
@view = LaunchpadView.new @launchpad
@controller = LaunchpadController.new @model, @view
@pressed = {}
 
def in0 *args # note on/off
  note,velocity = *args
  x = note % 16
  y = note / 16  

  if velocity > 0
    if x > 7
      @pressed.clear
      @controller.track = y
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

# control change (top row)
def in1 *args 
  cc,val = *args  
  if val > 0
    index = cc-104
    if index < 2 # only 2 screens so far
      @controller.screen = index
    elsif index > 3
      @controller.mode = index-4
    end
  end
end

# metro input in [bars, beats, units]
def in2 *args
  bars,beats,units = *args
  # assume 4/4 with 1/16 note pulses
  pulse_index = (bars-1)*16 + (beats-1)*4 + (units/120).round
  step_values = @controller.pulse(pulse_index)
  step_values.each_with_index do |step_value,pattern_index|
    # todo support multiple values
    if step_value > 0
      # step_value should range from 1-3
      velocity = 127 - (3-step_value)*40
      out2 pattern_index,velocity
    end  
  end
end

def in3 json
  @model.from_json json
  @controller.select_pattern 0
end

def dump
  out3 @model.to_json
end

def all_off
  @view.all_off
end

# set all the lights on the launchpad hardware for the current state
# used to undo the "all notes off" message automatically send by Ableton Live to all MIDI hardware
def reset_lights
  @controller.select_pattern @controller.selected_pattern_index
end 


BUTTON_HOLD_RATE = 0.25 # every quarter second the button is held, the value increases

@bg_thread ||= Thread.new do
  begin
  loop do
    sleep 0.05
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
