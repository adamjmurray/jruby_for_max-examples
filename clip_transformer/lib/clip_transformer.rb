require 'jruby_for_max/live_api'
include JRubyForMax

@clip = LiveAPI::Clip.new

# Default behavior is to connect first outlet to live.object and second outlet to live.path
outlet_assist 'to live.object', 'to live.path', 'dump'
alias dump out2

@clip.object_not_found do |path|
  if path.include? :highlighted_clip_slot
    dump 'No clip in currently selected clip slot'
  else
    # path starts with 'live_set' 'view' and ends with 'clip', so we chop that off:
    dump "No clip at #{path[1..-2].join ' '}"
  end
end 

# This reversal algorithm reverses the entire clip to produce the mirror-image.
# This is type of reversal is easy to understand, but often does not produce very musical results.
def absolute_reverse notes
  notes.each{|note| note.start = @clip.loop_start + @clip.loop_end - note.start - note.length }
end

# This reversal algorithm maintains the relative duration between each note on.
# It also ensures that the first note starts on the same beat before and after the transformation.
def relative_reverse notes
  offset, earliest = nil,nil
  for note in notes 
    offset = note.start if offset.nil? or note.start < offset
    note.start = @clip.loop_start + @clip.loop_end - note.start
    earliest = note.start if earliest.nil? or note.start < earliest
  end       
  notes.each{|note| note.start = note.start + offset - earliest }  
end  

# This reversal algorithm maintains the rhythm, and reverse all the pitches (and velocities)
def pitch_reverse notes
  notes.sort! do |n1,n2| 
    # sort by start time
    comparison = n1.start <=> n2.start
    if comparison == 0
      # and use pitch as the tie-breaker for consistent results
      n1.pitch <=> n2.pitch
    else 
      comparison
    end
  end 
  len = notes.size-1
  for i in 0..(len/2)
    n1 = notes[i]
    n2 = notes[len-i]
    n1.start,n2.start = n2.start,n1.start
    n1.duration,n2.duration = n2.duration,n1.duration
  end
end

def bang
  transform_type = inlet_index
  @clip.transform_selected_clip do |notes|
    case transform_type
    when 1 then relative_reverse notes
    when 2 then pitch_reverse notes
    else absolute_reverse notes
    end
  end
end
