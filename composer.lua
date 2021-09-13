musicutil = require ('musicutil')

Pattern = include('lib/pattern')
Sequence = include('lib/sequence')
Gui = include('lib/grid_ui')

engine.name = 'PolyPerc'

NUM_PATTERNS = 16
pat = {}
for i=1,NUM_PATTERNS do 
  pat[i] = Pattern.new() 
end

seq = Sequence.new(pat[1])
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
  local p = pat[1]
  grid_timer = metro.init()
  grid_timer.event = function() 
    g:refresh()
  end
  grid_timer.time = 1/15
  grid_timer:start()
  
  
  screen_timer = metro.init()
  screen_timer.event = function() 
    redraw()
  end
  screen_timer.time = 1/15
  screen_timer:start()
    
  clk = clock.run(clock_loop)
 
  -- TODO:
  -- start/stop/reset handlers
  -- ...
  
  load_all_patterns()
  
end

cleanup = function()
  print('cleanup?')
  save_all_patterns()
end

cur_stage = nil
clock_loop = function()
  while true do
    if running then
      cur_stage = seq:step()
      --print("stepping (composer)...")
      if cur_stage == nil then
        print("stage data was nil!")
      else
        --print('playing stage index: '..seq.idx)
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
gui:set_pattern(pat[1])

g.key = function(x, y, z)
  --print(''..x..','..y..','..z)
  gui:handle_key(x, y, z)
  gui:redraw(g, seq.idx)
end 

enc = function(n, d)
  if n == 2 then
    local off = gui.step_offset + d
    if off < 1 then off = 1
    elseif off > Pattern.MAX_LENGTH - 16 then off = Pattern.MAX_LENGTH - 16
    end
    gui.step_offset = off
    gui:redraw(g, seq.idx)
  end
  
  if n == 3 then
    local off = gui.note_offset + d
    if off < 0 then off = 0
    elseif off > 111 then off = 111
    end
    gui.note_offset = off
    gui:redraw(g, seq.idx)
  end
end

key = function(n, z)
-- ALSO NOT A GOOD IDEA I GUESS
  -- if n==1 and z > 0 then 
  --   save_all_patterns()
  -- end
end

redraw = function()
  screen.clear()
  screen.font_face(3) -- idk
  screen.aa(0)
  screen.font_size(16)
  screen.move(0, 20)
  screen.text("note:")
  screen.move(40, 20)
  screen.text(gui.note_offset)
  screen.move(0, 40)
  screen.text("step:")
  screen.move(40, 40)
  screen.text(gui.step_offset)
  screen.update()
end 

