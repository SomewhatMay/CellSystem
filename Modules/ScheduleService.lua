
local Config
local ScheduleService = {}
local Actions = {}
local Inputs = {}

local function random(a, b)
    return love.math.random(1, 10)
end

function ScheduleService.newSchedule(volume)
    local self = 
    random()

    -- Lets add random characters for Evaluation Type, Connection A, Connection B, and Action Type as they are finite in length
    

    -- Lets add an undetermined number of Action Input 1s
    local reachedStatic = false

    while not reachedStatic do
        local bit1 = random() % 3

        if bit1 == 0 or bit1 == 1 then -- Static bit, end it here.
            reachedStatic = true
        else -- Bit is not static, this will call a 

        end
    end
end

function ScheduleService.Init()
    Config = love.Modules.Config

    local ActionFiles = love.filesystem.getDirectoryItems("Modules/Actions")

    print("Getting things in", #ActionFiles)
    for index, actionName in pairs(ActionFiles) do
        actionName = string.gsub(actionName, ".lua", "")
        Actions[index] = require("Modules/Actions/" .. actionName)
    end

end

return ScheduleService