require 'mono_midi_gate'

class PolyMidiGate

  def initialize(&output)
    @output = output
    @pitches = []
    @notes = {}
    @gate_notes = {}
    @playing_notes = {}
    @triggered_by = {}
  end

  def note(pitch, velocity)
    if velocity > 0
      note_on pitch, velocity
    else
      note_off pitch
    end
  end

  def gate(gate_pitch, gate_velocity)
    if gate_velocity > 0
      gate_on gate_pitch, gate_velocity
    else
      gate_off gate_pitch
    end
  end

  def reset
    @playing_notes.each do |pitch, _|
      @output.call(pitch, 0)
    end
    @pitches.clear
    @held_notes.clear
    @gate_notes.clear
    @playing_notes.clear
    @triggered_by.clear
  end

##############################################
  private

  def note_on pitch, velocity
    if not @notes.include? pitch
      @notes[pitch] = velocity
      @pitches << pitch
      @pitches.sort
      pitch_index = @pitches.index(pitch)

      @gate_notes.each do |gate_pitch, gate_velocity|
        gate_index = gate_pitch % @pitches.size
        if pitch_index == gate_index
          play(pitch, velocity, gate_pitch, gate_velocity)
          break
        end
      end
    end
  end

  def note_off pitch
    if @notes.delete pitch
      @pitches.delete(pitch)
      stop_playing pitch
    end
  end

  def gate_on gate_pitch, gate_velocity
    if not @gate_notes.include? gate_pitch
      @gate_notes[gate_pitch] = gate_velocity
      if not @pitches.empty?
        pitch = @pitches[gate_pitch % @pitches.size]
        velocity = @notes[pitch]
        play(pitch, velocity, gate_pitch, gate_velocity)
      end
    end
  end

  def gate_off gate_pitch
    if @gate_notes.delete gate_pitch
      pitch = @triggered_by.delete gate_pitch
      stop_playing pitch, gate_pitch if pitch
    end
  end

  def play(pitch, velocity, gate_pitch, gate_velocity)
    if not @playing_notes.include? pitch
      scaled_velocity = velocity*gate_velocity/127
      @playing_notes[pitch] = scaled_velocity
      @triggered_by[gate_pitch] = pitch
      @output.call(pitch, scaled_velocity)
    end
  end

  def stop_playing pitch, gate_pitch=nil
    if @playing_notes.delete pitch
      @triggered_by.delete gate_pitch
      @output.call(pitch, 0)
    end
  end

end

