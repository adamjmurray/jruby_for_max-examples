require 'chord_gate'

if not Hash.instance_methods.include? 'key'
  class Hash
    alias key index  # For backward compatibility with Ruby 1.8  
  end
end


# A gate where each sidechain note in the gate track can only trigger
# a single note in the main track. Useful for arpeggiation.
class ArpGate < ChordGate

  def initialize(&output)
    super
    @pitches = []    
    @gate_map = {}
  end

  def reset
    super
    @pitches.clear    
    @gate_map.clear
  end

##############################################
  private

  def note_on pitch, velocity
    if not @notes.include? pitch
      @notes[pitch] = velocity
      @pitches << pitch
      @pitches.sort!      
      update_note_state
    end
  end
  
  def note_off(pitch)
    if @notes.delete(pitch)
      @pitches.delete(pitch)
      update_note_state
    end
  end
  
  def update_note_state    
    new_gate_map = recalculate_gate_map
    new_playing_pitches = new_gate_map.values    
    playing_pitches = @playing_notes.keys
    
    pitches_that_keep_playing = new_playing_pitches & playing_pitches
    pitches_that_stop_playing = playing_pitches - pitches_that_keep_playing
    pitches_that_start_playing = new_playing_pitches - pitches_that_keep_playing    
    
    for pitch in pitches_that_stop_playing
      gate_pitch = @gate_map.key(pitch)
      stop_playing(pitch, gate_pitch)
    end
    
    for pitch in pitches_that_start_playing
      velocity = @notes[pitch]
      gate_pitch = new_gate_map.key(pitch)
      gate_velocity = @gate_notes[gate_pitch]
      play(pitch, velocity, gate_pitch, gate_velocity)
    end

    # and now we'll swap in the new gate map to update the mapping for any pitches_that_keep_playing,
    # so that gate offs can be handled correctly
    @gate_map = new_gate_map
  end
  
  # This method controls the arpeggiator-like behavior that maps the sidechain gate pitches
  # to the pitches in the current track.
  def recalculate_gate_map
    gate_map = {}
    if not @pitches.empty?
      for gate_pitch, gate_velocity in @gate_notes
        pitch = @pitches[gate_pitch % @pitches.size]
        if not gate_map.has_value? pitch
          gate_map[gate_pitch] = pitch
        end
      end
    end
    return gate_map
  end

  def gate_on(gate_pitch, gate_velocity)
    if not @gate_notes.include? gate_pitch
      @gate_notes[gate_pitch] = gate_velocity
      if not @pitches.empty?
        pitch = @pitches[gate_pitch % @pitches.size]
        velocity = @notes[pitch]
        play(pitch, velocity, gate_pitch, gate_velocity)
      end
    end
  end

  def gate_off(gate_pitch)
    if @gate_notes.delete(gate_pitch)
      pitch = @gate_map.delete(gate_pitch)
      stop_playing(pitch, gate_pitch) if pitch
    end
  end

  def play(pitch, velocity, gate_pitch, gate_velocity)
    if not @playing_notes.include? pitch
      scaled_velocity = velocity*gate_velocity/127
      @playing_notes[pitch] = scaled_velocity
      @gate_map[gate_pitch] = pitch
      @output.call(pitch, scaled_velocity)
    end
  end

  def stop_playing(pitch, gate_pitch)
    if @playing_notes.delete(pitch)
      @gate_map.delete(gate_pitch)
      @output.call(pitch, 0)
    end
  end
  
end

