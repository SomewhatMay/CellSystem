
local Config
local ScheduleService
local foodClass = {}
local food = {}
food.__index = food

function food:Draw()
    love.graphics.setColor(255, 255, 0)
	love.graphics.rectangle(
		"fill", 
		(self.Position.X - 1) * Config.CellSize.X, 
		(self.Position.Y - 1) * Config.CellSize.Y, 
		Config.CellSize.X,
		Config.CellSize.Y
	)
end

function food:Destroy()
	self.Position = nil

	setmetatable(self, nil)

	if #self > 0 then
		print("Incomplete :Destroy()")
	end
end

function foodClass.new(position)
	position = position or {X = 0; Y = 0}
	local self = {
        type = "food";

		Position = position;
	}

	setmetatable(self, food)

	return self
end

function foodClass.Init()
	Config = love.Modules.Config
	ScheduleService = love.Modules.ScheduleService
end

return foodClass