local Random = {}
local randomObject = {
    m = 2^31 - 1;   -- modulus
    a = 1664525 ; -- multiplier
    c = 1013904223 ;      -- increment
}
randomObject.__index = randomObject

function randomObject:NextInt(min, max)
    if not (min and max) then
        min = 1
        max = self.m
    elseif not max then
        max = min
        min = 1
    end

    local range = max - min + 1
    self.seed = (self.a * self.seed + self.c) % self.m

    return min + (self.seed % range)
end

function randomObject:NextNumber()
    return self:NextInt() / self.m
end

function Random.new(seed)
    if (not seed) or (seed == "random") then
        seed = love.math.random()
    end

    local self = {
        seed = seed;
    }

    self = setmetatable(self, randomObject)
    self:NextInt() -- call it at least once to 'calibrate' it

    return self
end

return Random