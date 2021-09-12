local Pattern = {}
Pattern.__index = Pattern

local Stage = {}
Stage.__index = Stage

Pattern.MAX_LEN = 64

function Pattern.new() 
    local p = setmetatable({}, Pattern)
    p.stages = {}
    for i=1,Pattern.MAX_LEN do
      p.stages[i] = Stage.new()
    end
    return p
end 

Stage.flags = {}
Stage.flags.NOTEON = 1
Stage.flags.NOTEOFF = 2
Stage.flags.TIE = 4

Stage.masks = {}
Stage.masks.NOTEON = 0xff ~ Stage.flags.NOTEON
Stage.masks.NOTEOFF = 0xff ~ Stage.flags.NOTEOFF
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

function Stage:set_noteoff(num)
    self.data[num] = self.data[num] | Stage.flags.NOTEOFF
end

function Stage:set_tie(num)
    self.data[num] = self.data[num] | Stage.flags.TIE
end

function Stage:clear_noteon(num)
    self.data[num] = self.data[num] & Stage.masks.NOTEON
end

function Stage:clear_noteoff(num)
    self.data[num] = self.data[num] & Stage.masks.NOTEOFF
end

function Stage:clear_tie(num)
    self.data[num] = self.data[num] & Stage.masks.TIE
end

Pattern.Stage = Stage
return Pattern