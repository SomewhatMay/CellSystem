local GameStates = {
	PAUSE = "game_state_paused";
	RUNNING = "game_state_playing";
}

local MainWorld = {
	GameStates = GameStates;

	GameState = GameStates.RUNNING;
	Generation = 0;
	Day = 0;
	FoodAlive = 0;
	FoodEaten = 0;
	CellsAlive = 0;
	CellsGarrisoned = 0;
	UpdateRate = nil;
}

function MainWorld.Pause()
	MainWorld.GameState = GameStates.PAUSE
end

function MainWorld.Unpause()
	MainWorld.GameState = GameStates.RUNNING
end

function MainWorld.TogglePause()
	if MainWorld.GameState == GameStates.PAUSE then
		MainWorld.Unpause()
	else
		MainWorld.Pause()
	end
end

function MainWorld.GetGameStateString()
	if MainWorld.GameState == GameStates.PAUSE then
		return "PAUSED"
	elseif MainWorld.GameState == GameStates.RUNNING then
		return "RUNNING"
	end
end

-- Check if food is finished, and if so, call NextGeneration()
local function isFoodFinished()
	if MainWorld.FoodAlive <= 0 then
		MainWorld.NextGeneration(love.CellGrid.Array, love.GarrisonedCells)

		return true
	end

	return false
end

local function getLeaderboard(leaderboardArray, gridArray)
	for _, currentCell in pairs(gridArray) do
		local leaderboardArrayLength = #leaderboardArray

		-- Let's check if the current cell's points is greater than a full leaderboard's lowest cell's points
		if not ((leaderboardArrayLength > 10) and (currentCell.Points < leaderboardArray[leaderboardArrayLength].Points)) then
			-- let's insert the current cell into the correct position in the cell array
			local inserted = false
			for index, topCell in pairs(leaderboardArray) do
				if currentCell.Points > topCell.Points then
					table.insert(leaderboardArray, index, currentCell)
					inserted = true
					leaderboardArrayLength = leaderboardArrayLength + 1

					break
				end
			end

			-- If the leaderboard is not full, lets add the cell to the end
			if (not inserted) and (leaderboardArrayLength < 10) then
				table.insert(leaderboardArray, currentCell)
				leaderboardArrayLength = leaderboardArrayLength + 1
			end

			-- Check if the current leaderboardArray's length is greater than 10
			if leaderboardArrayLength > 10 then
				table.remove(leaderboardArray, leaderboardArrayLength)
			end
		end
	end
end

function MainWorld.NextDay()
	MainWorld.Day = MainWorld.Day + 1
	local currentGeneration = MainWorld.Generation

	love.CellGrid:Iterate(function(column, row, value)
		if MainWorld.Generation ~= currentGeneration then return end

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

					MainWorld.CellsGarrisoned = MainWorld.CellsGarrisoned + 1
					MainWorld.CellsAlive = MainWorld.CellsAlive - 1 

					table.insert(love.GarrisonedCells, garrisonedCell)
				elseif residingCell and residingCell.type == "food" then
					love.CellGrid:Set(value.Position.X, value.Position.Y, nil)
					love.NextCellGrid:Set(value.Position.X, value.Position.Y, nil)

					MainWorld.FoodEaten = MainWorld.FoodEaten + 1
					MainWorld.FoodAlive = MainWorld.FoodAlive - 1

					residingCell:Destroy()
					value.Points = value.Points + Config.Points.Food

					if isFoodFinished() then
						return -- break out of the current .NextDay() function if we have moved on a generation
					end
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

	-- Only touch the grids if we havent changed generations
	if MainWorld.Generation == currentGeneration then
		-- Empty and replace the two BiArrays so we dont have to create a new one every frame
		love.CellGrid:Empty()
		love.CellGrid, love.NextCellGrid = love.NextCellGrid, love.CellGrid
	end
end

function MainWorld.NextGeneration(currentGrid, garrisonedGrid)
	-- TODO add next generation support :)

	MainWorld.Day = 0
	MainWorld.Generation = MainWorld.Generation + 1
	MainWorld.CellsAlive = 0
	MainWorld.CellsGarrisoned = 0
	MainWorld.FoodAlive = 0
	MainWorld.FoodEaten = 0

	-- Determine the top 10 cells
	-- [1 ...] = cell;
	local cellLeaderboard = {}

	if currentGrid then
		getLeaderboard(cellLeaderboard, currentGrid)
		getLeaderboard(cellLeaderboard, garrisonedGrid)

		Log("New generation starting! Last generation lifetime: " .. DifferenceTime.calculate("generation life time", true) .. " sec.")
	end

	-- Empty both cells so we can replace them with new generation
	love.CellGrid:Empty()
	love.NextCellGrid:Empty()

	love.CellGrid:Fill(function(column, row)
		local chance = love.CellSpawnRandom:NextInt(1, 150)

		if chance == 1 then
			local cell = Packages.CellClass.new(Vector2.new(column, row))
			MainWorld.CellsAlive = MainWorld.CellsAlive + 1

			-- Set the schedule of this new cell to a reproduced schedule
			if currentGrid then
				-- Percent value that wil reflect config's cell percent configuration
				local chosenAncestryPercent = love.CellSpawnRandom:NextInt(0, 100) / 100

				-- if we end up having a cell that is unsigned percent, we skip mutalations and assigning of schedule.
				if chosenAncestryPercent <= Config.ReproductionUnsignedSchedule then
					local chosenCell

					for rank, percent in pairs(Config.ReproductionPercentTable) do
						-- Set the min percent to 0 if the current rank is 1 because we cant have 0th index in a table.
						local minPercent = ((rank - 1 == 0 and 0) or Config.ReproductionPercentTable[rank - 1])

						-- Choose the cell based on the leaderboard and break out
						if chosenAncestryPercent > minPercent and chosenAncestryPercent <= percent then
							chosenCell = cellLeaderboard[rank]

							break
						end
					end

					if chosenCell then
						-- Set the schedule with some mutalations :)
						Packages.ScheduleService.mutateCell(cell, chosenCell.Schedule)
					end
				end
			end

			return cell
		elseif chance == 2 or chance == 4 then
			local food = Packages.FoodClass.new(Vector2.new(column, row))
			MainWorld.FoodAlive = MainWorld.FoodAlive + 1

			return food
		end
	end)

	love.GarrisonedCells = {}

	DifferenceTime.start("generation life time")
end

function MainWorld.load()
	MainWorld.UpdateRate = Config.UpdateRate
	MainWorld.Generation = 0
	
    Log("Initiating all cells...")

	love.NextCellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows)
	love.CellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows)

	MainWorld.NextGeneration()
	
	love.window.setMode(Config.WindowSize.X, Config.WindowSize.Y)

	DifferenceTime.start("simulation update rate")
end

function MainWorld.update()
    if ((DifferenceTime.calculate("simulation update rate", true, true)) > MainWorld.UpdateRate) and (MainWorld.GameState ~= GameStates.PAUSE) then
		MainWorld.NextDay()
		DifferenceTime.start("simulation update rate")
	end
end

function MainWorld.draw()
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

	-- GarrisonedCellsDisplay
	-- love.graphics.setColor(1, 1, 1)
	-- love.GarrisonedCellsDisplay:Iterate(function(column, row, value)
	-- 	if value > 0 then
	-- 		love.graphics.print(value, (column - 1) * Config.CellSize.X, (row - 1) * Config.CellSize.Y)
	-- 	end
	-- end)
end

function MainWorld.keyPressed(key)
	if key == "g" then
		MainWorld.NextGeneration()
	elseif key == "p" then
		MainWorld.TogglePause()
	elseif key == "d" then
		if MainWorld.GameState == GameStates.PAUSE then
			MainWorld.NextDay()
		end
	end
end

return MainWorld