
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
	local start = love.timer.getTime()
	if self.LastNext and (start - self.LastNext < Config.UpdateRate) then
		love.Log(("Called schedule on %s too early. (%s)"):format(self.Ancestry, start - self.LastNext))
	end
	self.LastNext = start

	local currentSchedule = self.Schedule[self.Pointer]
	local newPointer, newResult = ScheduleService.readSchedule(self, currentSchedule, self.LatestResult)

	self.Pointer = newPointer
	self.LatestResult = newResult
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
		LatestResult = nil;
	}

	setmetatable(self, cell)
	self.Schedule = ScheduleService.newSchedule()

	return self
end

function cellClass.Init()
	Config = love.Modules.Config
	TableToString = love.Modules.TableToString
	ScheduleService = love.Modules.ScheduleService
end

return cellClass