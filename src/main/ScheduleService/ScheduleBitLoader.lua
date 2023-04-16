--// Schedule Bit loaded \\--
--// SomewhatMay, April 2023 \\--
--// Loads bits found in the schedule \\--

local BitLoader = {}

local function random(a, b)
    a, b = a or 1, b or 10
    
    return love.CellSpawnRandom:NextInt(a, b) - 1
end

function BitLoader.EvalType()
    return tostring(random(1, 6))
end

function BitLoader.ConnectionPointer()
    return tostring(random(1, Config.TotalScheduleSize))
end

function BitLoader.ActionType()
    return tostring(random(1, 2))
end

function BitLoader.AssistingBit1()
    return tostring(random())
end

function BitLoader.AssistingBit2()
    return tostring(random(1, 2))
end

function BitLoader.AssistingBit3()
    return tostring(tostring(random()))
end

function BitLoader.EvalBit()
    return tostring(tostring(random()))
end

return BitLoader