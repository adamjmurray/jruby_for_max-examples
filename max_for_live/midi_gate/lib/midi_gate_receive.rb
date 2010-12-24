require 'mono_midi_gate'
require 'poly_midi_gate'
require 'jruby_for_max/send_receive'
include JRubyForMax::SendReceive


# TODO: figure out a way to log relative to this file
#LOG = File.new("/Users/adam/tmp/jruby_for_max.log", 'w')
#def log(msg)
#  LOG.puts "#{ Thread.current.__id__ }   #{msg}"
#  LOG.flush
#end
#
#def out0(*params)
#  outlet 0, *params
#  log("OUTPUT: #{params.inspect}")
#end

@mgate = MonoMidiGate.new{|pitch,velocity| out0(pitch,velocity) }
@pgate = PolyMidiGate.new{|pitch,velocity| out0(pitch,velocity) }


POLYPHONIC = 1
@gate = @pgate

# Handle notes on this track, which won't play unless the gate allows it
def in0( pitch, velocity )
#  log("note [#{pitch},#{velocity}]")
  @gate.note(pitch,velocity)
#  log(@gate.dump)
end

# listen to events on the given track
def in1( track_name )
  unreceive # stop listening to previous track
  channel = "midi_gate-#{track_name}"
  receive channel do |gate_pitch, gate_velocity|
#    log("gate [#{gate_pitch},#{gate_velocity}]")
    out1 gate_pitch, gate_velocity
    @gate.gate(gate_pitch,gate_velocity)
#    log(@gate.dump)
  end
rescue
  out1 $! 
end

def in2( mode )
  case mode
  when POLYPHONIC
    @gate = @pgate
    out1 'polyphonic'
  else
    @gate = @mgate
    out1 'mono'
  end
  reset # TODO: 'panic' and send note outs?
end

def reset
  @gate.reset
end
