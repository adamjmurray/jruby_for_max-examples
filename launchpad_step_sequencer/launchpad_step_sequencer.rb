require 'launchpad_adapter'

inlet_assist 'from launchpad note on', 'from launchpad control change', 'transport time (bars beats units)'
outlet_assist 'to launchpad note on', 'to launchpad control change'

@launchpad = LaunchpadAdapter.new lambda{|pitch,velocity| out0 pitch,velocity}, lambda{|number,value| out1 number,value}

def in0 *args # note on/off
  note,vel = *args
  x = note % 16
  y = note / 16  
  if x > 7
    right_press y,(vel > 0)
  else    
    grid_press x,y,(vel > 0)
  end
end 

def in1 *args # control change
  cc,val = *args  
  top_press (cc-104),(val > 0)
end

def in2 *args
  bars,beats,units = *args
  # assume 4/4 with 1/16 note pulses
  y = ((bars-1) %4)*2 + (beats-1)/2
  x = ((beats-1)%2)*4 + units/120
  all_off
  @launchpad.grid x,y,:a  
end
  
def top_press index,pressed
  #puts "top[#{index}]: #{pressed ? :X : :_}"
  @launchpad.top index,pressed
end

def grid_press x,y,pressed
  #puts "grid[#{x},#{y}] #{pressed ? :X : :_}"
  @launchpad.grid x,y,pressed
end

def right_press index,pressed
  #puts "right[#{index}] #{pressed ? :X : :_}"
  @launchpad.right index,pressed
end

def all_off
  @launchpad.all_off
end 
