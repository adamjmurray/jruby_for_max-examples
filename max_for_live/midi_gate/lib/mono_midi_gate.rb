class MonoMidiGate

  def initialize(&output)
    @output        = output
    @held_notes    = {}
    @gate_notes    = {}
    @playing_notes = {}
    @playing_notes_gate_count = Array.new(127, 0)
  end

  def note(pitch, velocity)
    update_note_state(@held_notes, pitch, velocity)

    if velocity > 0 # note on
      @gate_notes.each do |gate_pitch, gate_velocity|
        play(pitch, velocity, gate_velocity)
      end

    else #note off
      if @playing_notes[pitch]
        play(pitch, 0, 0)
      end
    end
  end

  def gate(gate_pitch, gate_velocity)
    update_note_state(@gate_notes, gate_pitch, gate_velocity)
    @held_notes.each do |pitch, velocity|
      play(pitch, velocity, gate_velocity)
    end
  end

  def dump
    "\nHELD_NOTES: #{@held_notes.inspect}\nGATE_NOTES: #{@gate_notes.inspect}\nPLAY_NOTES: #{@playing_notes.inspect}"
  end

  def reset
    @held_notes.clear
    @gate_notes.clear
    @playing_notes.clear
    @playing_notes_gate_count.fill(0)
  end


  ##############################################
  private

  def play(pitch, velocity, gate_velocity)
     # this note's velocity is scaled by the gate velocity, which automatically takes care of note-offs
    scaled_velocity = velocity*gate_velocity/127
    note_on = scaled_velocity > 0
    playing = @playing_notes.include? pitch
    update_state = false
    if note_on
      @playing_notes_gate_count[pitch] += 1
      update_state = (not playing) # only send a note on if not already playing
    else
      count = @playing_notes_gate_count[pitch] -= 1
      update_state = (count == 0)
    end
    if update_state
      update_note_state(@playing_notes, pitch, scaled_velocity)
      @output.call(pitch, scaled_velocity)
    end
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
