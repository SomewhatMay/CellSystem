--// CellSystem \\--
--// SomewhatMay, April 2023 \\--

__Main_version = "4.20.3A"

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

function table.find(haystack, needle)
	for index, value in pairs(haystack) do
		if value == needle then
			return index
		end
	end

	return nil
end

LogTypes = {
	ERROR = {"error", "askodhjasu9gd91jp9sdfh"}; -- Errors in the consoles and halts the program
	WARN = {"warns", "1390uwed99h8effhspf"}; -- Warns in the console but doesnt halt the program
	NO_TIME = {"no_time", "dfgi931380dhh9prunvg"}; -- does not display the time information in the log.txt file
}

--@param logType {LogType} - the type of loggin
function Log(logType, ...)
    local strings = {...}
    local prefixTime
	local pString = ""

	for _, str in pairs(strings) do
		pString = pString .. str
    end

	if logType == LogTypes.ERROR then
		Log(...)

		love.errhand(...)
	elseif logType == LogTypes.WARN then
		local traceback = debug.traceback("Warning: " .. tostring(pString), 2)

		print(traceback)
	elseif logType ~= LogTypes.NO_TIME then
		prefixTime = love.timer.getTime()
		local prefix = prefixTime .. " : "
		prefix = string.lpad(prefix, 15)

		pString = prefix .. logType .. pString

		print(pString)
    end
	
    logFile:write("\n" .. pString)

    return prefixTime
end

function love.errhand(msg)
	local traceback = debug.traceback("Error: " .. tostring(msg), 2)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print(traceback, 10, 10)
	love.graphics.present()
	love.event.pump()

	while true do
		local event = love.event.wait()
			if event == "quit" then
			return
		end
	end
end


if _Global_log_file then
	Log("Cannot create local log file. Using global..")
end

Log("main.lua starting... (Version: " .. __Main_version .. ")")

-- Difftime
DifferenceTime = {Scheduled = {}}

function DifferenceTime.start(code)
	DifferenceTime.Scheduled[code] = love.timer.getTime()
end

function DifferenceTime.calculate(code, inSeconds, dontEmpty)
	-- in seconds
	local diff = love.timer.getTime() - DifferenceTime.Scheduled[code]

	-- if inSeconds == false, then convert it to miliseconds
	if inSeconds ~= true then
		diff = diff * 1000
	end

	-- let's round it to the nearest hundredth
	diff = math.floor(diff * 100) / 100

	if dontEmpty ~= true then
		DifferenceTime.Scheduled[code] = nil
	end

	return diff
end

-- Import new modules and add them to a directory

Log("Attempting to import modules...")

local Modules = {}
local function import(path, indexName)
	local lastPeriod = string.find(path, "%.[^%.]*$")
	local moduleName = string.sub(path, (lastPeriod or 0) + 1, #path)
	local loadedModule = Modules[moduleName]

	if loadedModule then
		return loadedModule
	end

	loadedModule = require(path)
	
	Modules[indexName or moduleName] = loadedModule

	return loadedModule
end
Packages = Modules
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
		Log("here")
		Log(LogTypes.ERROR, "No Config-deafult.lua! This is a required file to continue. Please refresh origin!")
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

	Packages.Config = Config
end

-- Importing required modules
-- lib
local Vector2 = import("src.lib.Vector2")
local UDIM2 = import("src.lib.UDIM2")
local BiArray = import("src.lib.BiArray")
local CellClass = import("src.lib.Cell", "CellClass")
local FoodClass = import("src.lib.Food", "FoodClass")
local UUID = import("src.lib.UUID")
local Evals = import("src.main.ScheduleService.Evals")
local TableToString = import("src.lib.TableToString")
local Random = import("src.lib.Random")
local FrameEntry = import("src.lib.FrameEntry")
-- main
local ScheduleService = import("src.main.ScheduleService.init", "ScheduleService")
local Sidebar = import("src.main.Sidebar.init", "Sidebar")
local MainWorld = import("src.main.MainWorld")

Log("All modules imported. Initating all modules...")

DifferenceTime.start("Module init startup")
-- Initiating all modules
local ModuleScheduledCalls = {
	load = {};
	update = {};
	draw = {};
	keyPressed = {};
	keyReleased = {};
	mousePressed = {};
	mouseReleased = {};
}
for _, module in pairs(Modules) do
	if type(module) == "table" then
		if module.Init then
			module.Init()
		end

		if module.load then
			table.insert(ModuleScheduledCalls.load, module)
		end

		if module.update then
			table.insert(ModuleScheduledCalls.update, module)
		end

		if module.draw then
			table.insert(ModuleScheduledCalls.draw, module)
		end

		if module.keyPressed then
			table.insert(ModuleScheduledCalls.keyPressed, module)
		end

		if module.keyReleased then
			table.insert(ModuleScheduledCalls.keyReleased, module)
		end

		if module.mousePressed then
			table.insert(ModuleScheduledCalls.mousePressed, module)
		end

		if module.mouseReleased then
			table.insert(ModuleScheduledCalls.mouseReleased, module)
		end
	end
end

Log("All modules loaded in " .. DifferenceTime.calculate("Module init startup") .. "ms")

-- Memory stuff
local last_mem_update
local max_mem_usage = 0
local min_mem_usage = math.huge
local mem_usage = 0
local mem_usage_sum, mem_usage_quantity = 0, 0
local average_mem_usage = 0

function love.load()
	DifferenceTime.start("love.load() start timer")
	Log("love.load() started - calling .load() on all modules...")

	for _, module in pairs(ModuleScheduledCalls.load) do
		module.load()
	end

	local cell = CellClass.new()
	cell:Destroy()

	last_mem_update = love.timer.getTime()

	Log("love.load() completed in " .. DifferenceTime.calculate("love.load() start timer") .. "ms!")
end

function love.update(dt)
	for _, module in pairs(ModuleScheduledCalls.update) do
		module.update(dt)
	end

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
end

function love.keypressed(key)
	for _, module in pairs(ModuleScheduledCalls.keyPressed) do
		module.keyPressed(key)
	end
end

function love.keyreleased(key)
	for _, module in pairs(ModuleScheduledCalls.keyReleased) do
		module.keyReleased(key)
	end
end

function love.mousepressed(x, y, button)
	for _, module in pairs(ModuleScheduledCalls.mousePressed) do
		module.mousePressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	for _, module in pairs(ModuleScheduledCalls.mouseReleased) do
		module.mouseReleased(x, y, button)
	end
end

function love.draw()
	for _, module in pairs(ModuleScheduledCalls.draw) do
		module.draw()
	end

	-- Memory stuff
	love.graphics.setColor(1, 1, 1)

	love.graphics.print("avg:  " .. tostring(average_mem_usage) .. "MB", Config.WorldPixelWidth + 10, 5)
	love.graphics.print("max:  " .. tostring(max_mem_usage) .. "MB", Config.WorldPixelWidth + 160, 25)
	love.graphics.print("min:  " .. tostring(min_mem_usage) .. "MB", Config.WorldPixelWidth + 10, 25)
	love.graphics.print("cur:  " .. tostring(mem_usage) .. "MB", Config.WorldPixelWidth + 160, 5)
end

function love.quit()
	Log("Calling quit on all modules...")

	for _, module in pairs(Modules) do
		if type(module) == "table" and module.quit then
			module.quit()
		end
	end

	Log("Quitting successfully.")
end