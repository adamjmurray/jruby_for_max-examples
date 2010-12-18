Before do
  @output = []
  @gate   = MidiGate.new { |*args| @output << args }
end

When /^I play "([^"]*)"$/ do |pitch_name|
  pitch   = pitch_value(pitch_name)
  @gate.note(pitch, 127)
end

When /^I gate "([^"]*)"$/ do |pitch_number|
  @gate.gate(pitch_number.to_i, 127)
end

Then /^I should hear "([^"]*)"$/ do |pitch_name|
  pitch = pitch_value(pitch_name)
  @output.should == [[pitch, 127]]
end
