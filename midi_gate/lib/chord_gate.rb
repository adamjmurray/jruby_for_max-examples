# A gate which plays all notes in the main track (the full chord) whenever any gate note is playing.
class ChordGate

  # Create a new gate with 
  def initialize(&output)
    @output = output
    @notes = {}
    @gate_notes = {}
    @playing_notes = {}
  end

  # Handler for notes on the main track
  def note(pitch, velocity)
    if velocity > 0
      note_on(pitch, velocity)
    else
      note_off(pitch)
    end
  end

  # Handler for sidechain notes on the gate track 
  def gate(gate_pitch, gate_velocity)
    if gate_velocity > 0
      gate_on(gate_pitch, gate_velocity)
    else
      gate_off(gate_pitch)
    end
  end

  # Stop playing any currently playing notes and reset all internal state.
  def reset
    for pitch,_ in @playing_notes
      @output.call(pitch, 0)
    end
    @notes.clear
    @gate_notes.clear
    @playing_notes.clear
  end

  # Details of internal state for debugging purposes.
  def to_s
    "#{self.class}{\n  @notes: #{@notes.inspect}\n  @gate_notes: #{@gate_notes.inspect}\n  @playing_notes: #{@playing_notes.inspect}\n}"
  end


  ##############################################
  private

  def note_on(pitch, velocity)
    if not @notes.include? pitch
      @notes[pitch] = velocity
      if not @gate_notes.empty?
        play(pitch, velocity, *@gate_notes.first)
      end
    end
  end

  def note_off(pitch)
    if @notes.delete(pitch)
      stop_playing(pitch)
    end
  end

  def gate_on(gate_pitch, gate_velocity)
    if not @gate_notes.include? gate_pitch
      was_empty = @gate_notes.empty?
      @gate_notes[gate_pitch] = gate_velocity
      if was_empty
        for pitch,velocity in @notes
          play(pitch, velocity, gate_pitch, gate_velocity)
        end
      end
    end
  end

  def gate_off(gate_pitch)
    if @gate_notes.delete(gate_pitch)
      if @gate_notes.empty?
        for pitch,_ in @notes
          stop_playing(pitch, gate_pitch)
        end
      end
    end
  end

  def play(pitch, velocity, gate_pitch, gate_velocity)
    if not @playing_notes.include? pitch
      scaled_velocity = velocity*gate_velocity/127
      @playing_notes[pitch] = scaled_velocity      
      @output.call(pitch, scaled_velocity)
    end
  end

  def stop_playing(pitch, gate_pitch=nil)
    if @playing_notes.delete(pitch)
      @output.call(pitch, 0)
    end
  end
  
end
