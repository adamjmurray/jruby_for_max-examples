# Midi Gate
## a Max for Live project ##

### Midi Gate is midi sidechain system for combining a pitch track with a rhythm gate track. ###

Open the .als (Live set) file in the midi\_gate Project folder and take it for a spin.
Try different clips in the GATE track, 
and switching between mono & poly modes in the "midi\_gate\_receive" Live device in the NOTES track.

### How poly mode works ###
All pitches in the main "notes" track are sorted in ascending order in an array.
Sidechain gates are mapped to notes with the formula:
    
    pitch_to_play = sorted_pitches[gate_pitch % sorted_pitches.length]
    
This means that the lowest MIDI note on the GATE track will play the lowest note in the chord. 
And the second lowest MIDI note on the GATE track will play the second note in a chord, etc.
Because we're using modular arithmetic, and middle-C (MIDI pitch 60) is divisible by 1,2,3,4,5, and 6, 
you can also use middle-C to play the lowest note in any chord up to 6 simultaneous notes. 
(With a 7 note chord, things start to "wrap around", which could give some interesting results...)
