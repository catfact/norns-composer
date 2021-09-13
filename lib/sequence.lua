-- FIXME: dunno how to include this here.
-- assuming top level script includes stuff in order and globally
--local Pattern = dofile('pattern.lua')

local Sequence = {}
Sequence.__index = Sequence

-- args: a pattern
function Sequence.new(p) 
    local s = setmetatable({}, Sequence)
    s.pattern = p
    s.idx = 1
    return s
end 

function Sequence:set_pattern(p) 
  self.pattern = p
end

-- returns current stage data, advances stage counter
function Sequence:step()
  --print('stepping (sequence)...')
  local stage = nil
  if self.pattern ~= nil then
    stage = self.pattern.stages[self.idx]
  end
  self.idx = self.idx + 1
  if self.idx > self.pattern.length then
    self.idx = 1
  end
  return stage
end 

return Sequence