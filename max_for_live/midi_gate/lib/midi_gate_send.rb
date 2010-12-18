require 'jruby_for_max/send_receive'
include JRubyForMax::SendReceive

def in0 pitch, velocity
  send @channel, pitch, velocity
end

def in1 track_name
  @channel = "midi_gate-#{track_name}"
end