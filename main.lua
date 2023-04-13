
-- Log stuff
local logFile = io.open("Log.txt", "w+")
_Global_log_file = false

if logFile then
	logFile:close()
	logFile = io.open("Log.txt", "a")
end

if not logFile then
	---@diagnostic disable-next-line: cast-local-type
	logFile = love.filesystem.newFile("Log.txt")
	logFile:open("w")
	love.Log = Log
	_Global_log_file = true
end

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

if _Global_log_file then
	Log("Cannot create local log file. Using global..")
end

Log("main.lua starting...")

-- Difftime
local DiffTime = {Scheduled = {}}

function DiffTime.start(code)
	DiffTime.Scheduled[code] = love.timer.getTime()
end

function DiffTime.calculate(code, inSeconds, dontEmpty)
	-- in seconds
	local diff = love.timer.getTime() - DiffTime.Scheduled[code]

	-- if inSeconds == false, then convert it to miliseconds
	if inSeconds ~= true then
		diff = diff * 1000
	end

	-- let's round it to the nearest hundredth
	diff = math.floor(diff * 100) / 100

	if dontEmpty ~= true then
		DiffTime.Scheduled[code] = nil
	end

	return diff
end

-- Import new modules and add them to a directory

Log("Attempting to import modules...")

local Modules = {}
local function import(path)
	local lastPeriod = string.find(path, "%.[^%.]*$")
	local moduleName = string.sub(path, (lastPeriod or 0) + 1, #path)
	local loadedModule = Modules[moduleName]

	if loadedModule then
		return loadedModule
	end

	loadedModule = require(path)
	
	Modules[moduleName] = loadedModule
	Log("Successfully imported - ", path)

	return loadedModule
end
love.Modules = Modules
love.Import = import

-- Lets import the config module and add a metatable to the deafult one.
Config = nil
local Config_Deafult
do
	local success1 = pcall(function()
		Config_Deafult = import("Config-Deafult")
	end)

	local success2 = pcall(function()
		Config = import("Config")
	end)

	if not success1 then
		Log("No Config-deafult.lua! This is a required file to continue. Please refresh origin!")
		error("No Config-deafult.lua! This is a required file to continue. Please refresh origin!")
	end
	
	if success2 then
		Log("Local config available. Setting metatable to deafult config...")
		Config.__index = function(_, key)
			Log("No available key \"", tostring(key), "\" in local config; returning from Config-Deafult...")
			
			return Config_Deafult[key]
		end
	else
		Log("No local config - using deafult config.")
		Config = Config_Deafult
	end

	love.Modules.Config = Config
end

-- Importing required modules
local BiArray = import("Modules.Packages.BiArray")
local CellClass = import("Modules.Packages.Cell")
local FoodClass = import("Modules.Packages.Food")
local UUID = import("Modules.Packages.UUID")
local UUID = import("Modules.ScheduleService")
local Evals = import("Modules.Packages.Evals")
local TableToString = import("Modules.Packages.TableToString")
local Random = import("Modules.Packages.Random")

Log("All modules imported. Initating all modules...")

DiffTime.start("Module init startup")
-- Initiating all modules
for _, module in pairs(Modules) do
	if type(module) == "table" and module.Init then
		module.Init()
	end
end

Log("All modules loaded in " .. DiffTime.calculate("Module init startup") .. "ms")

-- Memory stuff
local last_mem_update
local max_mem_usage = 0
local min_mem_usage = math.huge
local mem_usage = 0
local mem_usage_sum, mem_usage_quantity = 0, 0
local average_mem_usage = 0

function love.load()
	Log("love.load() started - Initiating all cells...")

	love.CellSpawnRandom = Random.new(Config.Seed)

	--love.GarrisonedCellsDisplay = BiArray.new(Config.World.Columns, Config.World.Rows, 0)

	--local chance = 10
	love.NextCellGrid = BiArray.new(Config.WorldSize.Columns, Config.WorldSize.Rows)
	love.CellGrid = BiArray.new(Config.WorldSize.Columns, Config.WorldSize.Rows, function(column, row)
		local chance = love.CellSpawnRandom:NextInt(1, 150)
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
	last_mem_update = love.timer.getTime()

	DiffTime.start("simulation update rate")

	Log("love.load() completed!")
end

local clickedTargetCell
local clickedTargetCellFont
function love.update(dt)
	-- Memory stuff
	mem_usage = math.floor(collectgarbage("count")) / 1000
	
	if (love.timer.getTime() - last_mem_update) >= 1 then
		average_mem_usage = math.floor(mem_usage_sum / mem_usage_quantity * 100) / 100
		mem_usage_sum = 0
		mem_usage_quantity = 0
		last_mem_update = love.timer.getTime()
	end

	mem_usage_sum = mem_usage_sum + mem_usage
	mem_usage_quantity = mem_usage_quantity + 1

	if mem_usage > max_mem_usage then
		max_mem_usage = mem_usage
	end

	if mem_usage < min_mem_usage then
		min_mem_usage = mem_usage
	end

	clickedTargetCellFont = love.graphics.newFont(16)

	if (DiffTime.calculate("simulation update rate", true, true)) > Config.UpdateRate then

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
						--love.GarrisonedCellsDisplay:Increment(value.Position.X, value.Position.Y, 1)
					elseif residingCell and residingCell.type == "food" then
						love.CellGrid:Set(value.Position.X, value.Position.Y, nil)
						love.NextCellGrid:Set(value.Position.X, value.Position.Y, nil)

						residingCell:Destroy()
						value.Points = value.Points + Config.Points.Food
			    	end
				elseif value.type == "food" then
					repaste = true
				else
					Log("Cell type unknown!")
				end
			end

			if repaste then
    			love.NextCellGrid:Set(value.Position.X, value.Position.Y, value)
			end
		end)

		-- Empty and replace the two BiArrays so we dont have to create a new one every frame
		love.CellGrid:Empty()
		love.CellGrid, love.NextCellGrid = love.NextCellGrid, love.CellGrid 

		DiffTime.start("simulation update rate")
	end
end

function love.draw()
	-- Memory stuff
	love.graphics.setColor(1, 1, 1)

	love.graphics.print("avg:  " .. tostring(average_mem_usage) .. "MB", 1010, 10)
	love.graphics.print("max:  " .. tostring(max_mem_usage) .. "MB", 1010, 30)
	love.graphics.print("min:  " .. tostring(min_mem_usage) .. "MB", 1010, 50)
	love.graphics.print("cur:  " .. tostring(mem_usage) .. "MB", 1010, 70)

	love.graphics.setBackgroundColor(0, 0, 0)

	-- Cell drawing
    love.CellGrid:Iterate(function(column, row, value)
		local TopLeftPosition = {
			X = (column - 1) * Config.CellSize.X;
			Y = (row - 1) * Config.CellSize.Y
		}

		-- Outlines
		love.graphics.setLineWidth(2)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle(
			"line",
			TopLeftPosition.X,
			TopLeftPosition.Y,
			Config.CellSize.X,
			Config.CellSize.Y
		)

		if value then
			value:Draw(TopLeftPosition)
		end
	end)

	-- Target cell info gatherer
	local targetCell
	local mouseX, mouseY = love.mouse.getPosition()
	local targetPosition = {
		X = math.ceil(mouseX / Config.CellSize.X);
		Y = math.ceil(mouseY / Config.CellSize.Y);
	}

	if love.mouse.isDown(1) then
		local currentCell = love.CellGrid:Get(targetPosition.X, targetPosition.Y)
		local stringedCellData = currentCell and ("(%s, " .. "%s) %s"):format(currentCell.Position.X, currentCell.Position.Y, 
			((currentCell.type == "cell" and "- " .. currentCell.Points) or "")
		);

		clickedTargetCell = currentCell and {
			Cell = currentCell;

			text = love.graphics.newText(clickedTargetCellFont, stringedCellData);

			targetCellPosition = {
				X = currentCell.Position.X * Config.CellSize.X; 
				Y = currentCell.Position.Y * Config.CellSize.Y
			};
		}

		if not clickedTargetCell then
			clickedTargetCell = nil
		end
	end

	targetCell = clickedTargetCell

	if not clickedTargetCell then
		local currentCell = love.CellGrid:Get(targetPosition.X, targetPosition.Y)
		local stringedCellData = currentCell and ("(%s, " .. "%s) %s"):format(currentCell.Position.X, currentCell.Position.Y, 
			((currentCell.type == "cell" and "- " .. currentCell.Points) or "")
		);

		targetCell = currentCell and {
			Cell = currentCell;

			text = love.graphics.newText(clickedTargetCellFont, stringedCellData);

			targetCellPosition = {
				X = currentCell.Position.X * Config.CellSize.X; 
				Y = currentCell.Position.Y * Config.CellSize.Y
			};
		}
	end

	if targetCell then
		love.graphics.setColor(1, 1, 1, .5)
		love.graphics.rectangle("fill", 8, 10, targetCell.text:getWidth() + 3, targetCell.text:getHeight() + 3)
		love.graphics.setColor(0, 0, 0)
		love.graphics.draw(targetCell.text, 10, 12)
	end

	-- GarrisonedCellsDisplay
	-- love.graphics.setColor(1, 1, 1)
	-- love.GarrisonedCellsDisplay:Iterate(function(column, row, value)
	-- 	if value > 0 then
	-- 		love.graphics.print(value, (column - 1) * Config.CellSize.X, (row - 1) * Config.CellSize.Y)
	-- 	end
	-- end)
end

function love.quit()
	Log("Quitting successfully.")
end