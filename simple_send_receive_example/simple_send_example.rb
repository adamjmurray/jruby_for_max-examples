require 'jruby_for_max/send_receive'
include JRubyForMax::SendReceive

def in0 pitch, velocity
  # :my_note is the send/receive "channel", so only receivers of this message will receive anything
  send :my_note, pitch, velocity
end

