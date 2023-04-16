--// Cell Class \\--
--// SomewhatMay, April 2023 \\--

local Config
local TableToString
local ScheduleService
local cellClass = {}
local cell = {}
cell.__index = cell

function cell:Draw(TopLeftPosition)
	TopLeftPosition = TopLeftPosition or {
		X = (self.Position.X - 1) * Config.CellSize.X;
		Y = (self.Position.Y - 1) * Config.CellSize.Y;
	}

	love.graphics.setColor(math.max(255 - self.Points, 0) / 255, 1, math.max(255 - self.Points, 0) / 255)
	love.graphics.rectangle(
		"fill", 
		TopLeftPosition.X,
		TopLeftPosition.Y,
		Config.CellSize.X,
		Config.CellSize.Y
	)
end

function cell:Next()
	local currentSchedule = self.Schedule[self.Pointer]
	local newPointer, newResult = ScheduleService.readSchedule(self, currentSchedule, self.LatestResult)

	self.Pointer = newPointer
	self.LatestResult = newResult
end

function cell:Clone()
	local clonedSelf = cellClass.new()
	clonedSelf.Points = self.Points
	clonedSelf.Ancestry = self.Ancestry
	clonedSelf.Position = self.Position:Clone()
	clonedSelf.Pointer = self.Pointer
	clonedSelf.LatestResult = self.LatestResult
	clonedSelf.Schedule = {table.unpack(self.Schedule)}
	clonedSelf.Alive = self.Alive

	return clonedSelf
end

function cell:Destroy()
	self.type = nil
	self.Points = nil
	self.Ancestry = nil
	self.Position = nil
	self.Pointer = nil
	self.LatestResult = nil
	self.Schedule = nil
	self.Alive = nil

	setmetatable(self, nil)
end

function cellClass.new(position, ancestry)
	position = position or Vector2.new()
	ancestry = ancestry or Packages.UUID()

	local self = {
		type = "cell";

		Points = 0;
		Ancestry = ancestry;
		Position = position;
		Pointer = 1;
		LatestResult = nil;
		Schedule = nil;
		Alive = true;
	}

	setmetatable(self, cell)
	self.Schedule = ScheduleService.newSchedule()

	return self
end

function cellClass.Init()
	Config = Packages.Config
	TableToString = Packages.TableToString
	ScheduleService = Packages.ScheduleService
end

return cellClass