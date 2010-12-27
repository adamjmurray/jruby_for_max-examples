require 'jruby_for_max/delay'
include JRubyForMax::Delay

@delay = 1000    # 1000 ms == 1 second

def in0 delay
  @delay = delay
end

def bang
  after @delay do 
    out0 'bang'
  end
end

inlet_assist 'delay time (ms), or bang'
outlet_assist 'delayed bang'

