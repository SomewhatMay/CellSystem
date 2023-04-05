
local Config
local TableToString
local ScheduleService
local cellClass = {}
local cell = {}
cell.__index = cell

function cell:Draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle(
		"fill", 
		(self.Position.X - 1) * Config.CellSize.X, 
		(self.Position.Y - 1) * Config.CellSize.Y, 
		Config.CellSize.X,
		Config.CellSize.Y
	)
end

function cell:Next()
	
end

function cell:Destroy()
	self.Points = nil
	self.Ancestry = nil
	self.Position = nil
	self.Schedule = nil
	self.Pointer = nil;

	setmetatable(self, nil)

	if #self > 0 then
		print("Incomplete :Destroy()")
	end
end

function cellClass.new(position, ancestry)
	position = position or {X = 0; Y = 0}
	ancestry = ancestry or love.Modules.UUID()

	local self = {
		type = "cell";

		Points = 0;
		Ancestry = ancestry;
		Position = position;
		Pointer = 1;
	}

	setmetatable(self, cell)
	self.Schedule = ScheduleService.newSchedule()

	print(TableToString(self))

	return self
end

function cellClass.Init()
	Config = love.Modules.Config
	TableToString = love.Modules.TableToString
	ScheduleService = love.Modules.ScheduleService
end

return cellClass