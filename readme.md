# spec

## what we know:

- midi + synth output
- grid column selects notes in scale
- scroll octave on grid
- lower right corner key toggles pattern select / edit
- hold key in one column while pressing other column to create tie/sustain

- e3 scrolls octaves 
- pattern length is variable up to 64 steps
- pattern selection is possible

- all edits are saved immediately!

- on switching patterns, next step comes from new pattern

## open questions

- how does a tie work for midi?
  - sends new noteon, shortly followed by old noteoff

- how do we addres more than 16 steps on grid?
  - scroll with e2

- polyperc not a good fit for tie/sustain! (it is a one-shot percussive synth)

- switching patterns:
  - how to handle tie from the old pattern
  - how to handle new pattern shorter than next step index
  
- scale selection / definition? 
