require 'lib/launchpad'
inlet_assist 'from launchpad note on', 'from launchpad control change', 'transport time (bars beats units)', 'model load'
outlet_assist 'to launchpad note on', 'to launchpad control change', 'sequencer out', 'model dump'

@model = Launchpad::Model.new
@view = Launchpad::View.new @model, ->(pitch,velocity){out0 pitch,velocity}, ->(cc_number,value){out1 cc_number,value}
@controller = Launchpad::Controller.new @model, @view, ->(pitch,velocity){out2 pitch,velocity}, ->(*args){out3 *args}
 
# note on/off 
def in0 *args 
  note,velocity = *args
  x = note % 16
  y = note / 16  
  grid_index = x + y*8
  
  if velocity > 0
    if x > 7
      @controller.track = y
    else
      @controller.step_pressed grid_index
    end
  else
    @controller.step_released grid_index
  end
end 

# control change (top row)
def in1 *args 
  cc,val = *args  
  if val > 0
    index = cc-104
    if index < 3 # only 3 screens so far
      @controller.screen = index
    elsif index > 3
      @controller.mode = index-4
    end
  end
end 
 
# metro input in [bars, beats, units]
def in2 *args
  @controller.pulse *args
end

# pattrstorage input
def in3 *data
  if data.first == 'dump' # dump of all values is done
    @view.redraw_grid
  else    
    property_name = data.shift # first element is the property name (standard pattr message format)    
    @model.deserialize_property property_name,data
  end
end

# def dump
#   preset_number = 1 # TODO: support different preset slots
#   for param,value in @model.serialize
#     out3 'setstoredvalue', param, preset_number, *value
#   end
# end

def init_pattrstorage
  default_note_grid = [0]*64
  default_playback_grid = [Launchpad::Track::PLAYBACK_NORMAL]*64
  for preset_number in 0..31
    for track_index in 0..7
      out3 'setstoredvalue', "notes#{track_index}", preset_number, *default_note_grid
      out3 'setstoredvalue', "playback#{track_index}", preset_number, *default_playback_grid      
    end
  end
end

def all_off
  @view.all_off
end

# set all the lights on the launchpad hardware for the current state
# used to undo the "all notes off" message automatically send by Ableton Live to all MIDI hardware
def reset_lights
  @view.redraw
end 

