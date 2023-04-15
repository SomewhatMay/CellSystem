--// Vector2 \\--
--// SomewhatMay, April 2023 \\--

Vector2 = {}
local vector2 = {}
vector2.__index = function(self, index)
    if index == "Width" or index == "Height" then
        love.errhand("Attempted to index \"" .. index .. "\" of Vector2. Did you mean to use UDIM2?")
    end

    return vector2[index]
end

vector2.__sub = function(self, vectorB)
    return Vector2.new(self.X - vectorB.X, self.Y - vectorB.X)
end

vector2.__add = function(self, vectorB)
    return Vector2.new(self.X + vectorB.X, self.Y + vectorB.X)
end

vector2.__mul = function(self, vectorB)
    return Vector2.new(self.X * vectorB.X, self.Y * vectorB.X)
end

vector2.__div = function(self, vectorB)
    return Vector2.new(self.X / vectorB.X, self.Y / vectorB.X)
end

function vector2:toString()
    return ("(X = %s, Y = %s)"):format(self.X, self.Y)
end

function Vector2.new(X, Y)
    local self = {
        X = X or 0;
        Y = Y or 0;
    }
    self = setmetatable(self, vector2)

    return self
end

return Vector2