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

def bang
  @clip.goto_selected_clip do
    @clip.get_notes do
      dump "GOT: #{@clip.notes.inspect}"
      # TODO: now let's actually transform the clip and write it back out..
    end
  end
end
  