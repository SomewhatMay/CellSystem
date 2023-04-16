--// UDIM2 \\--
--// SomewhatMay, April 2023 \\--

UDIM2 = {}
local udim2 = {}
udim2.__index = udim2
udim2.__index = function(self, index)
    if index == "X" or index == "Y" then
        love.errhand("Attempted to index \"" .. index .. "\" of UDIM2. Did you mean to use Vector2?")
    end

    return udim2[index]
end


udim2.__sub = function(self, vectorB)
    return UDIM2.new(self.Width - vectorB.Width, self.Height - vectorB.Width)
end

udim2.__add = function(self, vectorB)
    return UDIM2.new(self.Width + vectorB.Width, self.Height + vectorB.Width)
end

udim2.__mul = function(self, vectorB)
    return UDIM2.new(self.Width * vectorB.Width, self.Height * vectorB.Width)
end

udim2.__div = function(self, vectorB)
    return UDIM2.new(self.Width / vectorB.Width, self.Height / vectorB.Width)
end

function udim2:Clone()
    return UDIM2.new(self.Width, self.Height)
end

function UDIM2.new(Width, Height)
    local self = {
        Width = Width or 0;
        Height = Height or 0;
    }
    self = setmetatable(self, udim2)

    return self
end

return UDIM2