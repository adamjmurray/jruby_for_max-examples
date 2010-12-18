$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'midi_gate'

# Define pitch constants, like C4 (=60)
PITCH_CLASS = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']
module Kernel
  for pitch in 0..127
    octave = (pitch/12)-1
    name = PITCH_CLASS[pitch%12] + octave.to_s.sub('-', '_')
    const_set name, pitch
  end
end

def pitch_value(pitch_name)
  Kernel::const_get pitch_name
end

