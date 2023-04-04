local Action = {}
Action.__index = Action

function Action:__call(cell, canRun, argument, connectionA, connectionB)
    if canRun then
        self.callback(cell, argument)

        return connectionA
    else
        return connectionB
    end
end

function Action.new(callback)
    local self = {
        Callback = callback;
    }

    setmetatable(self, Action)

    return self
end

return Action