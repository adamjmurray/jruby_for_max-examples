require 'lib/launchpad'
inlet_assist 'launchpad note in', 'launchpad CC in', 'transport time (bars beats units)', 'load JSON'
outlet_assist 'launchpad note out', 'launchpad CC out', 'sequencer out', 'fx out', 'save JSON'

@model = Launchpad::Model.new
@view = Launchpad::View.new @model, 
        ->(pitch,velocity) { out0 pitch,velocity }, # launchpad note out 
        ->(cc_number,value){ out1 cc_number,value } # launchpad CC out

@controller = Launchpad::Controller.new @model, @view, 
              ->(pitch,velocity){ out2 pitch,velocity }, # sequencer out
              ->(pitch,velocity){ out3 pitch,velocity } # fx out
 
def in0 *args # launchpad note in 
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

def in1 *args # launchpad CC in
  cc,val = *args  
  if val > 0
    index = cc-104
    if index < 4
      @controller.screen = index
    else
      @controller.mode = index-4
    end
  end
end 
 
def in2 *args # transport time (bars beats units)
  @controller.pulse *args
end

def in3 json # load JSON
  @model.from_json json
end

def dump
  out4 @model.to_json
end
alias save dump

def all_off
  @view.all_off
end

def reset
  @model.reset
  reset_lights
end

# set all the lights on the launchpad hardware for the current state
# used to undo the "all notes off" message automatically send by Ableton Live to all MIDI hardware
def reset_lights
  @view.redraw
end
