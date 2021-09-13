-- class to manage stateful view/controller for grid UI

local Gui = {}
Gui.__index = Gui

function Gui.new()
  local x = setmetatable({}, Gui)
  x.step_offset = 0
  x.note_offset = 60
  x.mode_select = false 
  x.pattern = nil
  x.levels = { 
    noteon = {13, 15},
    tie = {10, 12},
    inactive = {0, 2}
  }
  print('new gui; step offset = '.. x.step_offset)
  return x
end

function Gui:set_pattern(p)
  self.pattern = p
end

-- g: a grid
function Gui:redraw(g, idx)
  local level = 0
  for x=1,16 do
    local step = self.step_offset + x
    local stage = self.pattern.stages[step]
    if step == idx then which_level = 2 else which_level = 1 end
    for y=1,8 do
      local num = self.note_offset + 9 - y
      if stage:test_noteon(num) then
        level = self.levels.noteon[which_level]
      elseif stage:test_tie(num) then
        level = self.levels.tie[which_level]
      else
        level = self.levels.inactive[which_level]
      end
      g:led(x, y, level)
    end
  end
end

function Gui:handle_key (x, y, z)
  if x == 16 and y == 8 then
    self:toggle_view()
  else
    if self.mode_select then
      self:handle_key_select(x, y, z)
    else
      self:handle_key_edit(x, y, z)
    end
  end
end

function Gui:handle_key_edit(x, y, z)
  local step = self.step_offset + x
  local stage = self.pattern.stages[step]
  local num = self.note_offset + 9 - y
  tab.print({step=step, stage=stage, num=num})
  -- TODO: if another key is held, 
  -- (and whatever other conditions are met,)
  -- then make this a tie instead
  if z > 0 then
    if stage:test_noteon(num) then
      stage:clear_noteon(num)
    else
      stage:set_noteon(num)
    end
  end
end

function Gui:handle_key_select (x, y, z)
  -- TODO
end

return Gui