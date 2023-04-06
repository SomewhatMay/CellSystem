
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

local lastUpdate

-- Log stuff
local logFile
function string.lpad(str, len, char)
    if char == nil then char = ' ' end
    local distance = len - #str
    return str .. ((distance > 0 and string.rep(char, distance)) or "")
end

function Log(noTime, ...)
    local strings = {...}
    local prefixTime
    local prefix = ""

    if not (type(noTime) == "boolean" and noTime == true) then
        prefixTime = love.timer.getTime()
        prefix = prefixTime .. " : "
        prefix = string.lpad(prefix, 15)
        table.insert(strings, 1, noTime)
    end

	local pString = ""
    logFile:write("\n" .. prefix)
    for _, str in pairs(strings) do
        logFile:write(str)
		pString = pString .. str
    end

	print(pString)

    return prefixTime
end

function love.load()
	logFile = love.filesystem.newFile("/Log.txt")
    logFile:open("w")
	love.Log = Log

	Log("Initiating all cells...")

	--local chance = 10
	love.NextCellGrid = BiArray.new(Config.World.Columns, Config.World.Rows)
	love.CellGrid = BiArray.new(Config.World.Columns, Config.World.Rows, function(column, row)
		local chance = love.math.random(1, 150)
		--chance = chance - 1
		
		if chance == 1 then
			local cell = CellClass.new({
				X = column;
				Y = row
			})
			

			return cell
		elseif chance == 2 or chance == 4 then
			local food = FoodClass.new({
				X = column;
				Y = row;
			})

			return food
		end
	end)

	love.GarrisonedCells = {}
	love.window.setMode(Config.WindowSize.X, Config.WindowSize.Y)
	lastUpdate = love.timer.getTime()

	Log("love.load() completed!")
end

local isUpdating = false
function love.update(dt)
	if (not isUpdating) and (love.timer.getTime() - lastUpdate) > Config.UpdateRate then
		isUpdating = true

		love.CellGrid:Iterate(function(column, row, value)
			local repaste = false
			
			if value then 
				if value.type == "cell" then
					if value.Alive ~= true then return end
					
					repaste = true
					
					value:Next()
					-- Lets check if the cell is overlapping or eating 
					-- We're gonna check in the current CellGrid instead of the NextCellGrid
			    	local residingCell = love.CellGrid:Get(value.Position.X, value.Position.Y)
			    	if residingCell and residingCell.type == "cell" and (residingCell ~= value) then
			       		--print(value.Ancestry, "- Cell found -", residingCell.Ancestry)
			        
						-- Lets check which cell has a higher points value

						local garrisonedCell

						if residingCell.Points > value.Points then
							garrisonedCell = value
							repaste = false
						else
							garrisonedCell = residingCell
						end

						garrisonedCell.Points = garrisonedCell.Points + Config.Points.Death
						garrisonedCell.Alive = false
						table.insert(love.GarrisonedCells, garrisonedCell)
					elseif residingCell and residingCell.type == "food" then
						love.CellGrid:Set(value.Position.X, value.Position.Y, nil)
						love.NextCellGrid:Set(value.Position.X, value.Position.Y, nil)

						residingCell:Destroy()
						value.Points = value.Points + Config.Points.Food
			    	end
				elseif value.type == "food" then
					repaste = true
				end
			end

			if repaste then
    			love.NextCellGrid:Set(value.Position.X, value.Position.Y, value)
			end
		end)

		love.CellGrid:Destroy()
		love.CellGrid = love.NextCellGrid
		love.NextCellGrid = BiArray.new(Config.World.Columns, Config.World.Rows)

		lastUpdate = love.timer.getTime()
		isUpdating = false
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0, 0, 0)

    love.CellGrid:Iterate(function(column, row, value)
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
end

function love.quit()
	Log("Quitting successfully.")
end