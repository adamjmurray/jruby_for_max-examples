require 'mono_midi_gate'
require 'poly_midi_gate'
require 'jruby_for_max/send_receive'
include JRubyForMax::SendReceive

@chord_gate = MonoMidiGate.new{|pitch,velocity| out0(pitch,velocity) }
@arp_gate = PolyMidiGate.new{|pitch,velocity| out0(pitch,velocity) }

@gate = @arp_gate


# Handle notes on this track, which won't play unless the gate allows it
def in0( pitch, velocity )
  @gate.note(pitch,velocity)
end


# listen to events on the given track
def in1( track_name )
  @gate.reset
  unreceive # stop listening to previous track
  channel = "midi_gate-#{track_name}"
  receive channel do |gate_pitch, gate_velocity|
    out1 gate_pitch, gate_velocity if @monitor
    @gate.gate(gate_pitch,gate_velocity)
  end
end


ARP_MODE = 1
def in2( mode )
  @gate.reset
  if mode == ARP_MODE
    @gate = @arp_gate
  else
    @gate = @chord_gate
  end
end


@monitor = false
def in3( monitor_enabled )
  @monitor = (monitor_enabled == 1)
end


def in4( _ )
  @gate.reset
end    


inlet_assist 'note in', 'sidechain track name', 'chord/arp mode', 'monitor', 'reset'
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
