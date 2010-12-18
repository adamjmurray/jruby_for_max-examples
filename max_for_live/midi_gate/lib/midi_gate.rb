class MidiGate

  def initialize(&output)
    @output        = output
    @held_notes    = {}
    @gate_notes    = {}
    @playing_notes = {}
  end

  def note(pitch, velocity)
    update_note_state(@held_notes, pitch, velocity)

    if velocity > 0 # note on
      @gate_notes.each do |gate_pitch, gate_velocity|
        play(pitch, velocity, gate_velocity)
      end

    else #note off
      if @playing_notes[pitch]
        # stop playing the note
        @playing_notes.delete(pitch)
        @output.call(pitch, 0)
      end
    end
  end

  def gate(gate_pitch, gate_velocity)
    update_note_state(@gate_notes, gate_pitch, gate_velocity)
    @held_notes.each do |pitch, velocity|
      play(pitch, velocity, gate_velocity)
    end
  end

  def reset
    @held_notes.clear
    @playing_notes.clear
  end


  ##############################################
  private

  def play(pitch, velocity, gate_velocity)
    vel = velocity*gate_velocity/127 # this note's velocity is scaled by the gate velocity, which automatically takes care of note-offs
    update_note_state(@playing_notes, pitch, vel)
    @output.call(pitch, vel)
  end

  def update_note_state(collection, pitch, velocity)
    if velocity > 0
      # note on
      collection[pitch] = velocity
    else
      # note off
      collection.delete(pitch)
    end
  end

end