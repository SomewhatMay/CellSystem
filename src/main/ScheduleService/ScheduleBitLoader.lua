--// Schedule Bit loaded \\--
--// SomewhatMay, April 2023 \\--
--// Loads bits found in the schedule \\--

local BitLoadOrder = {}
local BitLoader = {
    BitLoadOrder = BitLoadOrder
}

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

BitLoadOrder = {
    [1] = BitLoader.EvalType;  -- Eval Type
    [2] = BitLoader.ConnectionPointer; -- ConnectionA
    [3] = BitLoader.ConnectionPointer; -- ConnectionB
    [4] = BitLoader.ActionType; -- Action Type
    [5] = BitLoader.AssistingBit1; -- Assisting Bit 1
    [6] = BitLoader.AssistingBit2; -- Assisting Bit 2
    [7] = BitLoader.AssistingBit3; -- Assisting Bit 3
    [8] = BitLoader.EvalBit; -- Eval Bit
}

return BitLoader