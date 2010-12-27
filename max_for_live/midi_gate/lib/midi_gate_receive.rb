require 'mono_midi_gate'
require 'poly_midi_gate'
require 'jruby_for_max/send_receive'
include JRubyForMax::SendReceive
require 'thread'
LOCK = Mutex.new

@mono_gate = MonoMidiGate.new{|pitch,velocity| out0(pitch,velocity) }
@poly_gate = PolyMidiGate.new{|pitch,velocity| out0(pitch,velocity) }

@gate = @poly_gate


# Handle notes on this track, which won't play unless the gate allows it
def in0( pitch, velocity )
  LOCK.synchronize do  
    @gate.note(pitch,velocity)
  end
end


# listen to events on the given track
def in1( track_name )
  LOCK.synchronize do
    @gate.reset
    unreceive # stop listening to previous track
  end
  channel = "midi_gate-#{track_name}"
  receive channel do |gate_pitch, gate_velocity|
    out1 'gate', gate_pitch, gate_velocity if @monitor
    LOCK.synchronize do
      @gate.gate(gate_pitch,gate_velocity)
    end
  end
end


POLYPHONIC = 1
def in2( mode )
  LOCK.synchronize do
    @gate.reset
    case mode
    when POLYPHONIC
      @gate = @poly_gate
      out1 'mode', 'polyphonic'
    else
      @gate = @mono_gate
      out1 'mode', 'mono'
    end
  end
end


@monitor = false
def in3( monitor_enabled )
  @monitor = (monitor_enabled == 1)
end


def in4( _ )
  LOCK.synchronize do
    @gate.reset
  end
end    


inlet_assist 'note in', 'sidechain track name', 'mono/poly mode', 'monitor', 'reset'
outlet_assist 'note out', 'monitor'


# 
# # TODO: figure out a way to log relative to this file
# LOG = File.new("/Users/adam/tmp/jruby_for_max.log", 'w')
# def log(msg)
#  LOG.puts "#{ Thread.current.__id__ }   #{msg}"
#  LOG.flush
# end
# 
# def out0(*params)
#  outlet 0, *params
#  log("OUTPUT: #{params.inspect}")
# end
