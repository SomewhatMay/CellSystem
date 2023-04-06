
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

local function asihdas(k)
	local s = "{"

	for i, v in pairs(k.Array) do
		if type(v) == "table" and v.type == "cell" then
			v = "cell-" .. v.Ancestry
			s = s .. ("\n[%s] = %s"):format(i, v)
		end
	end

	s = s .. "\n}"

	return s
end

function love.load()
	logFile = love.filesystem.newFile("/Log.txt")
    logFile:open("w")
	love.Log = Log

	Log("Initiating all cells...")

	--local chance = 10
	love.NextCellGrid = BiArray.new(Config.World.Columns, Config.World.Rows)
	love.CellGrid = BiArray.new(Config.World.Columns, Config.World.Rows, function(column, row)
		local chance = love.math.random(1, 100)
		--chance = chance - 1
		
		if chance == 1 then
			local cell = CellClass.new({
				X = column;
				Y = row
			})
			

			return cell
		elseif chance == 0 then
			local food = FoodClass.new({
				X = column;
				Y = row;
			})

			return food
		end
	end)

	love.window.setMode(Config.WindowSize.X, Config.WindowSize.Y)
	lastUpdate = love.timer.getTime()

	Log("love.load() completed!")
end

local isUpdating = false
function love.update(dt)
	if (not isUpdating) and (love.timer.getTime() - lastUpdate) > Config.UpdateRate then
		isUpdating = true
		Log("Cell Grid:")
		Log(asihdas(love.CellGrid))
		Log("---------------")
		Log("Next Cell Grid:")
		Log(asihdas(love.NextCellGrid))

		love.CellGrid:Iterate(function(column, row, value)
			if value and value.type == "cell" then
				--Log("--calling next", love.timer.getTime() - lastUpdate)
				value:Next()
				--Log("called next", love.timer.getTime() - lastUpdate)
			end
		end)

		love.CellGrid:Destroy()
		love.CellGrid = love.NextCellGrid
		love.NextCellGrid = BiArray.new(Config.World.Columns, Config.World.Rows)

		Log("---------------")
		Log("Next Cell Grid:")
		Log(asihdas(love.CellGrid))

		lastUpdate = love.timer.getTime()
		isUpdating = false
		
		--Log(TableToString(cellGrid))
		--Log("-----------------------------------------------------")
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

end