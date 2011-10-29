class Launchpad::FlamTimer
  TIMER_RATE = 0.01
  FLAM_RATE = 0.05 # another note-on is sent out at this rate (in seconds)
  FLAM_REPEAT = 3 # number of note-ons sent after the intial note-on that triggers a flam
  DECAY = 0.75 # velocity it multiplied by this each time

  def initialize controller
    @controller = controller
    @flams = {}
    @bg_thread ||= Thread.new do
      begin
        loop do
          now = Time.new
          for pitch,data in @flams
            velocity,count,time = *data
            if now-time > FLAM_RATE
              velocity = (velocity * DECAY).round
              count += 1              
              @controller.note_out pitch,velocity
              if count >= FLAM_REPEAT
                @flams.delete pitch
              else
                @flams[pitch] = [velocity,count,now]
              end
            end
          end
          sleep TIMER_RATE
        end
      rescue => e
        error e.inspect
        error e.backtrace
      end  
    end
    
    at_exit do
      @bg_thread.kill if @bg_thread
      @bg_thread = nil
    end
  end
  
  def flam pitch,velocity
    @controller.note_out pitch,velocity
    @flams[pitch] = [velocity, 0, Time.new]    
  end
end