
-- Import new modules and add them to a directory
local Modules = {}
local function import(path)
	local lastPeriod = string.find(path, "%.")
	local moduleName = string.sub(path, (lastPeriod or 0) + 1, #path)
	local loadedModule = Modules[moduleName]

	if loadedModule then
		return loadedModule
	end

	loadedModule = require(path)
	
	Modules[moduleName] = loadedModule

	return loadedModule
end
love.Modules = Modules
love.Import = import

-- Importing required modules 
local Config = import("Config")
local BiArray = import("Modules.BiArray")
local CellClass = import("Modules.Cell")
local FoodClass = import("Modules.Food")
local UUID = import("Modules.UUID")
local UUID = import("Modules.ScheduleService")
local ActionClass = import("Modules.ActionClass")
local Evals = import("Modules.Evals")
local TableToString = import("Modules.TableToString")

-- Initiating all modules
for _, module in pairs(Modules) do
	if type(module) == "table" and module.Init then
		module.Init()
	end
end

local cellGrid
local lastUpdate = 0

function love.load()
	cellGrid = BiArray.new(Config.World.Rows, Config.World.Columns, function(column, row)
		local chance = love.math.random(1, 100)
		
		if chance == 1 then
			local cell = CellClass.new({
				X = column;
				Y = row
			})
			

			return cell
		elseif chance == 2 then
			local food = FoodClass.new({
				X = column;
				Y = row;
			})

			return food
		end
	end)

	love.window.setMode(Config.WindowSize.X, Config.WindowSize.Y)
end

function love.update(dt)
	if lastUpdate >= Config.UpdateRate then
		lastUpdate = lastUpdate - Config.UpdateRate

		cellGrid:Iterate(function(column, row, value)
			if value and value.type == "cell" then
				value:Next()
			end
		end)
	else
		lastUpdate = lastUpdate + dt
	end
end

local index = 1
function love.draw()
	love.graphics.setBackgroundColor(0, 0, 0)

    cellGrid:Iterate(function(column, row, value)
		-- Outlines
		love.graphics.setLineWidth(2)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle(
			"line", 
			(column - 1) * Config.CellSize.X, 
			(row - 1) * Config.CellSize.Y,
			Config.CellSize.X, 
			Config.CellSize.Y
		)

		if value then
			value:Draw()
		end
	end)

	index = index + 10
end

function love.quit()

end