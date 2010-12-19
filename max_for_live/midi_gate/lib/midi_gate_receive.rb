require 'mono_midi_gate'
require 'jruby_for_max/send_receive'
include JRubyForMax::SendReceive

@gate = MonoMidiGate.new{|pitch,velocity| out0(pitch,velocity) }

# Handle notes on this track, which won't play unless the gate allows it
def in0( pitch, velocity )
  @gate.note(pitch,velocity)
end

# listen to events on the given track
def in1( track_name )
  unreceive # stop listening to previous track
  channel = "midi_gate-#{track_name}"
  receive channel do |gate_pitch, gate_velocity|
    out1 gate_pitch, gate_velocity
    @gate.gate(gate_pitch,gate_velocity)
  end
rescue
  out1 $! 
end

def reset
  @gate.reset
end
