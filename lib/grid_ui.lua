-- class to manage stateful view/controller for grid UI

local Gui = {}
Gui.__index = Gui

Gui.new = function()
  local x = setmetatable({}, Gui)
  x.step_offset = 0
  x.note_offset = 0
  x.mode_select = false 
  x.current_pattern = nil
  return x
end

Gui:set_pattern = function(p) 
  self.pattern = p
end

-- g: a grid
Gui:redraw(g) = function()
end

Gui:handle_key = function(x, y, z)
  if x == 16 && y = 8 then
    self:toggle_view()
  else
    if self.mode_select then
      self:handle_key_select(x, y, z)
    else
      self:handle_key_edit(x, y, z)
    end
  end
end


Gui:handle_key_edit = function(x, y, z)
  -- TODO
end

Gui:handle_key_select = function(x, y, z)
  -- TODO
end