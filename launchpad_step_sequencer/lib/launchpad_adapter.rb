class LaunchpadAdapter
  
  def initialize(note_on_sender, control_change_sender)
    @note_on_sender = note_on_sender
    @control_change_sender = control_change_sender
  end
  
  def note_on(pitch,velocity)
    @note_on_sender.call pitch,velocity
  end
  
  def control_change(number,value)
    @control_change_sender.call number,value
  end
  
  def grid x,y,color=3
    x = clip(x,0,8)
    y = clip(y,0,7)
    c = color_value(color)
    note_on(16*y + x, c)
  end

  def right index,color=3
    grid 8,index,color
  end

  def top index,color=3
    c = color_value(color)
    p = 104 + clip(index,0,7)
    control_change(p,c)
  end

  def all_on(brightness=3)
    # convert brightness values 0,1,2,3 to 0,125,126,127
    # (0=off, 125=low, 126=med, 127=high)
    b = clip(brightness,0,3)
    b += 124 if b > 0
    control_change(0,b)
  end
  
  def all_off
    control_change(0,0)
  end

  def duty_cycle(numerator,denominator)
    n = clip(numerator,1,16)
    d = clip(denominator,3,18)
    if n < 9
      control_change(30, 16*(n-1) + (d-3))
    else
      control_change(31, 16*(n-9) + (d-3))
    end
  end
  
  # light up a button on the right column, turning off any previously lit button
  def radio_select_right_button index,color
    if @active_right_button_index
      # turn off previously lit button
      right @active_right_button_index,nil
    end
    right index,color
    @active_right_button_index = index        
  end
  
  def radio_select_arrow_button index,color
    if @active_arrow_button_index
      # turn off previously lit button
      top @active_arrow_button_index,nil
    end
    top index,color
    @active_arrow_button_index = index        
  end
  
  def radio_select_mode_button index,color
    top_row_button_index = index+4
    if @active_mode_button
      # turn off previously lit button
      top @active_mode_button,nil
    end
    top top_row_button_index,color
    @active_mode_button = top_row_button_index        
  end

  ###############################
  protected

  def clip(value,min,max)
    value = min if value.nil? or value < min
    value = max if value > max
    return value
  end

  def color_value(color)
    case color
    when Array
      g,r = color[0],color[1]
    when Numeric
      g,r = color,0
    else 
      case color.to_s.downcase
      when 'green',  'g', 'true' then g,r = 3,0
      when 'yellow', 'y' then g,r = 3,2
      when 'amber',  'a' then g,r = 1,1    
      when 'orange', 'o' then g,r = 2,3
      when 'red',    'r' then g,r = 0,3 
      else g,r = 0,0     
      end
    end
    g = clip(g.to_i,0,3)
    r = clip(r.to_i,0,3)
    return 16*g + r
  end

end