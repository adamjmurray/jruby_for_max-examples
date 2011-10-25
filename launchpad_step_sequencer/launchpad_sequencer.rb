require 'lib/launchpad_adapter'
require 'lib/launchpad_button_timer'
require 'lib/launchpad_flam_timer'
require 'lib/launchpad_model'
require 'lib/launchpad_view'
require 'lib/launchpad_controller'

inlet_assist 'from launchpad note on', 'from launchpad control change', 'transport time (bars beats units)', 'model load'
outlet_assist 'to launchpad note on', 'to launchpad control change', 'sequencer out', 'model dump'

@launchpad = LaunchpadAdapter.new lambda{|pitch,velocity| out0 pitch,velocity}, lambda{|number,value| out1 number,value}
@model = LaunchpadModel.new
@view = LaunchpadView.new @launchpad
@controller = LaunchpadController.new @model, @view, lambda{|pitch,velocity| out2 pitch,velocity}
 
def in0 *args # note on/off
  note,velocity = *args
  x = note % 16
  y = note / 16  

  if velocity > 0
    if x > 7
      @controller.track = y
    else
      @controller.step_pressed x,y
    end
  else
    @controller.step_released x,y
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
  @controller.pulse(pulse_index)
end

def in3 *data
  if data.first == 'dump' # dump of all values is done
    @controller.screen = 0   
  else    
    @model.deserialize data
  end
end

def dump
  preset_number = 1 # TODO: support different preset slots
  for param,value in @model.serialize
    out3 'setstoredvalue', param, preset_number, *value
  end
end

def all_off
  @view.all_off
end

# set all the lights on the launchpad hardware for the current state
# used to undo the "all notes off" message automatically send by Ableton Live to all MIDI hardware
def reset_lights
  @controller.select_pattern @controller.selected_pattern_index
end 

