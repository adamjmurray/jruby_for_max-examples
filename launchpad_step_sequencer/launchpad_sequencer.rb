require 'lib/launchpad'
inlet_assist 'launchpad note in', 'launchpad CC in', 'transport time (bars beats units)', 'load JSON'
outlet_assist 'launchpad note out', 'launchpad CC out', 'launchpad grid out', 'sequencer out', 'fx out', 'save JSON'

@model = Launchpad::Model.new
@view = Launchpad::View.new @model, 
        ->(pitch,velocity) { out0 pitch,velocity }, # launchpad note out 
        ->(cc_number,value){ out1 cc_number,value }, # launchpad CC out
        ->(values){ out2 *values } # launchpad grid out

@controller = Launchpad::Controller.new @model, @view, 
              ->(pitch,velocity){ out3 pitch,velocity }, # sequencer out
              ->(pitch,velocity){ out4 pitch,velocity } # fx out
 
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
  elsif x <= 7
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
  reset_lights
end

def dump
  out5 @model.to_json
end
alias save dump

def all_off
  @view.all_off
end

def reset
  @model.reset
  reset_lights
end

def reset_lights
  @view.redraw
end
