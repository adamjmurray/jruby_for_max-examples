require 'jruby_for_max/send_receive'
include JRubyForMax::SendReceive

receive :my_note do |pitch, velocity|
  out0 "Receiver 1 got: #{pitch} #{velocity}"
end
