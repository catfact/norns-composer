-- FIXME: dunno how to include this here.
-- assuming top level script includes stuff in order and globally
--local Pattern = dofile('pattern.lua')

local Sequence = {}
Sequence.__index = Sequence

-- args: a pattern
function Sequence.new(p) 
    local s = setmetatable({}, Sequence)
    s.pattern = p
    s.idx = 0 -- special initial value, normally in [1, length]
    return s
end 

function Sequence:set_pattern(p) 
  self.pattern = p
end

-- returns current stage data, advances stage counter
function Sequence:step()
  --print('stepping (sequence)...')
  local stage = nil
  self.idx = self.idx + 1
  if self.idx > self.pattern.length then
    self.idx = 1
  end
  if self.pattern ~= nil then
    stage = self.pattern.stages[self.idx]
  end
  return stage
end 

function Sequence:reset()
  self.idx = 0
end

return Sequence