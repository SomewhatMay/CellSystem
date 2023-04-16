--// Schedule Service \\--
--// SomewhatMay, April 2023 \\--

local Config
local Evals
local BitLoader
local ScheduleService = {}
local Actions = {}

local function wrap(a, max)
    return (a % max)
end

function ScheduleService.mutateCell(cell, schedule)
    cell.Schedule = schedule
end

function ScheduleService.newSchedule(volume)
    local self = {}

    -- Let's run a loop for each schedule in the total schedules we need to make
    for _=1, Config.TotalScheduleSize, 1 do
        local str = ""

        -- Let's add 6 random bits for the schedule generation
        str = str .. BitLoader.EvalType() -- Eval Type
        str = str .. BitLoader.ConnectionPointer() -- ConnectionA
        str = str .. BitLoader.ConnectionPointer() -- ConnectionB
        str = str .. BitLoader.ActionType() -- Action Type
        str = str .. BitLoader.AssistingBit1() -- Assisting Bit 1
        str = str .. BitLoader.AssistingBit2() -- Assisting Bit 2
        str = str .. BitLoader.AssistingBit3() -- Assisting Bit 3
        str = str .. BitLoader.EvalBit() -- Eval Bit

        table.insert(self, str)
    end

    return self
end

-- @returns {pointer} connection - Determines the next schedule that should be called. 
function ScheduleService.readSchedule(cell, schedule, peviousArgument)
    -- Determining all the bits that are going to be used for running the schedule
    local evalType = schedule:sub(
        Config.ScheduleCoordinates.EvalType, 
        Config.ScheduleCoordinates.EvalType
    ) -- The type of evaulation being done
    local connectionA = schedule:sub(
        Config.ScheduleCoordinates.ConnectionA, 
        Config.ScheduleCoordinates.ConnectionA
    ) -- Pointer to connection A
    local connectionB = schedule:sub(
        Config.ScheduleCoordinates.ConnectionB, 
        Config.ScheduleCoordinates.ConnectionB
    ) -- Pointer to connection B
    local actionType = schedule:sub(
        Config.ScheduleCoordinates.ActionType, 
        Config.ScheduleCoordinates.ActionType
    ) -- Determiens whether a static variable or an action pointer is being used
    local assistingBit1 = schedule:sub(
        Config.ScheduleCoordinates.AssistingBit1, 
        Config.ScheduleCoordinates.AssistingBit1
    ) -- Either a static variable, or an action pointer

    -- Determines whether a static variable gets passed into the next action or
    -- if a static variable is the previous one, determines whether that variable
    -- is passed or a static one.
    local assistingBit2 = schedule:sub(
        Config.ScheduleCoordinates.AssistingBit2, 
        Config.ScheduleCoordinates.AssistingBit2
    ) 

    local assistingBit3 = schedule:sub(
        Config.ScheduleCoordinates.AssistingBit3, 
        Config.ScheduleCoordinates.AssistingBit3
    ) -- The bit that get passed into the next method if a seperate static variable is chosen by the previous bit
    
    local evalBit = schedule:sub(
        Config.ScheduleCoordinates.EvalBit, 
        Config.ScheduleCoordinates.EvalBit
    ) -- The bit that

    
    local actionReturn
    connectionA = tonumber(connectionA) + 1
    connectionB = tonumber(connectionB) + 1
    evalType = tonumber(evalType)
    assistingBit1 = tonumber(assistingBit1)
    assistingBit3 = tonumber(assistingBit3)
    evalBit = tonumber(evalBit)

    if actionType == "0" then
        if assistingBit2 == "1" then
            peviousArgument = assistingBit3
        end

        actionReturn = Actions[wrap(assistingBit1, #Actions) + 1](cell, peviousArgument)
    else
        actionReturn = assistingBit1
    end

    if Evals[wrap(evalType, #Evals) + 1](actionReturn, evalBit) == true then
        return connectionA, actionReturn
    else
        return connectionB, actionReturn
    end
end

-- @returns {string} schedule -- turns the TopSchedule into a stringed format with the '-' seperating each 'schedule'
function ScheduleService.toString(topSchedule)
    local str = ""

    for _, schedule in pairs(topSchedule) do
        str = str .. " - " .. schedule
    end

    return str
end

function ScheduleService.Init()
    Config = Packages.Config
    Evals = Packages.Evals
    BitLoader = require("src.main.ScheduleService.ScheduleBitLoader")

    local ActionFiles = love.filesystem.getDirectoryItems("src/actions")

    for index, actionName in pairs(ActionFiles) do
        actionName = string.gsub(actionName, ".lua", "")
        Actions[index] = require("src/actions/" .. actionName)
    end
end

return ScheduleService