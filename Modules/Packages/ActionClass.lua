local Action = {}
Action.__index = Action

function Action:__call(cell, ...)
    self.callback(cell)
end

function Action.new(callback)
    local self = {
        Callback = callback;
    }

    setmetatable(self, Action)

    return self
end

return Action