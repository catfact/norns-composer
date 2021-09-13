-- COMPOSER.
--
-- polyphonic piano roll
-- pattern sequencer.
-- for when everything else on norns 
-- is too weird.
--
-- requires grid.
--
-- E1: change current pattern length
-- E2: move grid editing window on note axis
-- E3: move grid editing window on time axis
--
-- K1: (nothing)
-- K2 (lift): stop if playing, 
--              reset if stopped
-- K3 (lift): play if stopped, 
--              reset if playing
--
-- grid:
-- press keys to toggle notes
-- lower right key 
--     toggles pattern selection (top row)
--
-- TODO: midi output, ties, engine

musicutil = require ('musicutil')

Pattern = include('lib/pattern')
Sequence = include('lib/sequence')

engine.name = 'PolyPerc'

NUM_PATTERNS = 16

pat = {}
for i=1,NUM_PATTERNS do 
  pat[i] = Pattern.new() 
end

cur_pat = 1
seq = Sequence.new(pat[cur_pat])

-- yes, this comes after the global stuff above :/
set_cur_pat_idx = function(i)
  cur_pat = i
  local p = pat[cur_pat]
  seq:set_pattern(p)
end

Gui = include('lib/grid_ui')
g = grid.connect(1)

clk = nil

grid_timer = nil

running = true

save_all_patterns = function()
  print('saving patterns...')
  for i=1,NUM_PATTERNS do
    pat[i]:save('pattern_'..i)
  end
  print('...done saving patterns.')
end

load_all_patterns = function()
  for i=1,NUM_PATTERNS do
    pat[i]:load('pattern_'..i)
  end
end

init = function()
  local p = pat[cur_pat]
  grid_timer = metro.init()
  grid_timer.event = function() 
    g:refresh()
  end
  grid_timer.time = 1/30
  grid_timer:start()
  
  
  screen_timer = metro.init()
  screen_timer.event = function() 
    redraw()
  end
  screen_timer.time = 1/15
  screen_timer:start()
    
  clk = clock.run(clock_loop)
 
  ------------------------
  --- polyperc params, stolen from `awake`
  
   cs_AMP = controlspec.new(0,1,'lin',0,0.5,'')
  params:add{type="control",id="amp",controlspec=cs_AMP,
    action=function(x) engine.amp(x) end}

  cs_PW = controlspec.new(0,100,'lin',0,50,'%')
  params:add{type="control",id="pw",controlspec=cs_PW,
    action=function(x) engine.pw(x/100) end}

  cs_REL = controlspec.new(0.1,3.2,'lin',0,1.2,'s')
  params:add{type="control",id="release",controlspec=cs_REL,
    action=function(x) engine.release(x) end}

  cs_CUT = controlspec.new(50,5000,'exp',0,800,'hz')
  params:add{type="control",id="cutoff",controlspec=cs_CUT,
    action=function(x) engine.cutoff(x) end}

  cs_GAIN = controlspec.new(0,4,'lin',0,1,'')
  params:add{type="control",id="gain",controlspec=cs_GAIN,
    action=function(x) engine.gain(x) end}
  
  cs_PAN = controlspec.new(-1,1, 'lin',0,0,'')
  params:add{type="control",id="pan",controlspec=cs_PAN,
    action=function(x) engine.pan(x) end}
  ------------------------
  
  load_all_patterns()
  
  params:default()
  
end

cleanup = function()
  print('cleanup?')
  params:write()
  save_all_patterns()
end

cur_stage = nil
clock_loop = function()
  while true do
    if running then
      cur_stage = seq:step()
      if cur_stage == nil then
        print("stage data was nil!")
      else
        for num=0,127 do
          if cur_stage:test_noteon(num) then
            local hz = musicutil.note_num_to_freq(num)
            engine.hz(hz)
          end
        end
      end
      gui:redraw(g, seq.idx)
    end
    clock.sync(1/4)
  end
end

g = grid.connect(1)
gui = Gui.new()
gui:set_pattern(pat[cur_pat])

g.key = function(x, y, z)
  --print(''..x..','..y..','..z)
  gui:handle_key(x, y, z)
  gui:redraw(g, seq.idx)
end 

enc = function(n, d)
  if n == 1 then
    local l = pat[cur_pat].length
    l = l + d
    if l < 1 then l = 1 end
    if l > Pattern.MAX_LENGTH then l = Pattern.MAX_LENGTH end
    pat[cur_pat].length = l
  end
  
  if n == 2 then
    local off = gui.note_offset + d
    if off < 0 then off = 0
    elseif off > 111 then off = 111
    end
    gui.note_offset = off
    gui:redraw(g, seq.idx)
  end
  if n == 3 then
    local off = gui.step_offset + d
    if off < 0 then off = 0
    elseif off > Pattern.MAX_LENGTH - 16 then off = Pattern.MAX_LENGTH - 16
    end
    gui.step_offset = off
    gui:redraw(g, seq.idx)
  end
  
end

key = function(n, z)
  if n == 2 then
    if z > 0 then
      stop_key_held = true
    else
      if running then
        running = false
      else
        seq:reset()
      end
      stop_key_held = false
    end
  end
  if n == 3 then
    if z > 0 then
      play_key_held = true
    else 
      if running then
        seq:reset()
      else
      running = true;
      end
      play_key_held = false
    end
  end
  
end

redraw = function()
  screen.clear()
  screen.font_face(6) -- idk
  screen.aa(0)
  screen.font_size(16)
  
  screen.move(0, 12)
  screen.text("pat.:")
  screen.move(40, 12)
  screen.text(cur_pat)
  
  screen.move(0, 24)
  screen.text("len.:")
  screen.move(40, 24)
  screen.text(pat[cur_pat].length)
  
  screen.move(0, 36)
  screen.text("note:")
  screen.move(40, 36)
  screen.text(gui.note_offset)
  
  screen.move(0, 48)
  screen.text("step:")
  screen.move(40, 48)
  screen.text(gui.step_offset)
  
  screen.font_size(12)
  screen.level(15)
  screen.move(36, 56)
  if stop_key_held then
    screen.level(9)
  else
    screen.level(15)
  end
  if running then
    screen.text('STOP')
  else
    screen.text('RESET')
  end

  ---- play/stop labels
  screen.move(78, 56)
  if play_key_held then
    screen.level(9)
  else
    screen.level(15)
  end
  if running then
    screen.text('RESET')
  else
    screen.text('PLAY')
  end
  screen.update()
end 

