musicutil = require ('musicutil')

Pattern = include('lib/pattern')
Sequence = include('lib/sequence')
Gui = include('lib/grid_ui')

engine.name = 'PolyPerc'

pat = {}
for i=1,16 do 
  pat[i] = Pattern.new() 
end

seq = Sequence.new(pat[1])
clk = nil

grid_timer = nil

init = function()
  local p = pat[1]
  p.stages[1]:set_noteon(60 + 12)
  p.stages[1]:set_noteon(64 + 12)
  p.stages[1]:set_noteon(67 + 12)
  
  p.stages[5]:set_noteon(60 + 12 + 7)
  p.stages[5]:set_noteon(64 + 12 + 7)
  p.stages[5]:set_noteon(67 + 12 + 7)
  
  p.stages[9]:set_noteon(48)
 
 grid_timer = metro.init()
 grid_timer.event = function() 
   g:refresh()
 end
 grid_timer.time = 1/15
 grid_timer:start()
    
 clk = clock.run(clock_loop)
 
  -- TODO:
  -- start/stop/reset handlers
  -- ...
end

cur_stage = nil
clock_loop = function()
  while true do
    cur_stage = seq:step()
    --print("stepping (composer)...")
    if cur_stage == nil then
    --print("stage data was nil!")
    else
      for num=0,127 do
        if cur_stage:test_noteon(num) then
          local hz = musicutil.note_num_to_freq(num)
          engine.hz(hz)
        end
      end
    end
    gui:redraw(g, seq.idx)
    clock.sync(1/3) -- hm: what is the divisor actually? seems odd
  end
end

g = grid.connect(1)
gui = Gui.new()
gui:set_pattern(pat[1])

g.key = function(x, y, z)
  print(''..x..','..y..','..z)
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
    if off < 1 then off = 1
    elseif off > 111 then off = 111
    end
    gui.note_offset = off
    gui:redraw(g, seq.idx)
  end
end


key = function(n, z)
  -- ... ??
end

redraw = function()
  screen.clear()
end 

