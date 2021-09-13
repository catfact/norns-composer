local Pattern = {}
Pattern.__index = Pattern

local Stage = {}
Stage.__index = Stage

Pattern.MAX_LENGTH = 64

function Pattern.new() 
    local p = setmetatable({}, Pattern)
    p.stages = {}
    for i=1,Pattern.MAX_LENGTH do
      p.stages[i] = Stage.new()
    end
    p.length = 16
    return p
end 


Stage.flags = {}
Stage.flags.NOTEON = 1
Stage.flags.TIE = 2

Stage.masks = {}
Stage.masks.NOTEON = 0xff ~ Stage.flags.NOTEON
Stage.masks.TIE = 0xff ~ Stage.flags.TIE

function Stage.new() 
    local s = setmetatable({}, Stage)
    s.data = {}
    for i=0,127 do
        s.data[i] = 0
    end
    return s
end 

function Stage:set_noteon(num)
    self.data[num] = self.data[num] | Stage.flags.NOTEON
end

function Stage:set_tie(num)
    self.data[num] = self.data[num] | Stage.flags.TIE
end

function Stage:clear_noteon(num)
    self.data[num] = self.data[num] & Stage.masks.NOTEON
end

function Stage:clear_tie(num)
    self.data[num] = self.data[num] & Stage.masks.TIE
end

function Stage:test_noteon(num)
  --print('test noteon; num = '..num)
  return (self.data[num] & Stage.flags.NOTEON) > 0
end

function Stage:test_tie(num)
  return (self.data[num] & Stage.flags.TIE) > 0
end

function Stage:load_data(arr)
  for note=0,127 do
    self.data[note] = arr[note+1]
  end
end

function Stage:load_sparse_data(arr)
  -- for k,v in pairs(arr) do
  --   print(''..k..' = '..v)
  --   self.data[k] = v
  -- end
  for note=0,127 do
    if arr[note] ~= nil then
      self.data[note] = arr[note]
    else
      self.data[note] = 0
    end
  end
end

function Pattern:save(name)
  local dir = _path.data.."composer/patterns/"
  os.execute("mkdir -p "..dir)
  f = io.open(dir..name..'.lua', 'w')
  f:write('return {\n')
  for stage=1,Pattern.MAX_LENGTH do
    f:write('  { ')
    local s = self.stages[stage]
    for note=0,127 do
      if s.data[note] ~= 0 then
        f:write('['..note..']='..s.data[note]..', ')
      end
      --f:write(s.data[note])
      --f:write(', ')
    end
    f:write(' },\n')
  end
  f:write('}\n')
  f:close()
end


function Pattern:load(name)
  local location = _path.data.."composer/patterns/"..name..'.lua'
  local f = io.open(location, 'r')
  if f == nil then
    print("failed to open pattern file: "..location)
    return
  end
  io.close(f)
  
  local data = dofile(location)
  
  for stage=1,Pattern.MAX_LENGTH do
    local s = self.stages[stage]
    s:load_sparse_data(data[stage])
    --s:load_data(data[stage])
  end
end

function Pattern:clear() 
  for stage=1,Pattern.MAX_LENGTH do
    for note=0,127 do
      self.stages[stage].data[note] = 0
    end
  end
end

Pattern.Stage = Stage
return Pattern