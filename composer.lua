

Pattern = include('lib/pattern')
Sequence = include('lib/sequence')

engine.name = 'PolyPerc'

g = grid.connect()

pat = {}
for i=1,16 do 
  pat[i] = Pattern.new() 
end

seq = Sequence.new(pat[1])
clk = nil

init = function()
  
  local p = pat[1]
  p.stages[1]:set_noteon(60 + 12)
  p.stages[1]:set_noteon(64 + 12)
  p.stages[1]:set_noteon(67 + 12)
  
  p.stages[5]:set_noteon(60 + 12 + 7)
  p.stages[5]:set_noteon(64 + 12 + 7)
  p.stages[5]:set_noteon(67 + 12 + 7)
  
  p.stages[9]:set_noteon(48)
    
 clk = clock.run(clock_loop)
  -- TODO:
  -- start/stop handlers
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
          local hz = 440 * 2 ^ ((num-69)/12)
          engine.hz(hz)
        end
      end
    end
    clock.sync(1/16)
  end
end

