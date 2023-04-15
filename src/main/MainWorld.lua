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

function MainWorld.NextDay()
	MainWorld.Day = MainWorld.Day + 1

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
					--love.GarrisonedCellsDisplay:Increment(value.Position.X, value.Position.Y, 1)
				elseif residingCell and residingCell.type == "food" then
					love.CellGrid:Set(value.Position.X, value.Position.Y, nil)
					love.NextCellGrid:Set(value.Position.X, value.Position.Y, nil)

					MainWorld.FoodEaten = MainWorld.FoodEaten + 1
					MainWorld.FoodAlive = MainWorld.FoodAlive - 1

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
end

function MainWorld.NextGeneration()
	-- TODO add next generation support :)

	MainWorld.Generation = MainWorld.Generation + 1

	-- Empty both grids so we can replace them with new generation cells
	love.CellGrid:Empty()
	love.NextCellGrid:Empty()

	-- Update the cells with possibilities
	love.CellGrid:Iterate(function(column, row)
		local chance = love.CellSpawnRandom:NextInt(1, 150)
		--chance = chance - 1
		
		if chance == 1 then
			local cell = Packages.CellClass.new(Vector2.new(column, row))
			MainWorld.CellsAlive = MainWorld.CellsAlive + 1

			return cell
		elseif chance == 2 or chance == 4 then
			local food = Packages.FoodClass.new(Vector2.new(column, row))
			MainWorld.FoodAlive = MainWorld.FoodAlive + 1

			return food
		end
	end)

	love.GarrisonedCells = {}
end

function MainWorld.load()
	MainWorld.UpdateRate = Config.UpdateRate
	
    Log("Initiating all cells...")

    love.CellSpawnRandom = Packages.Random.new(Config.Seed)

	love.NextCellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows)
	love.CellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows)
	MainWorld.NextGeneration()

	love.window.setMode(Config.WindowSize.X, Config.WindowSize.Y)

	DifferenceTime.start("simulation update rate")
end

function MainWorld.update()
    if ((DifferenceTime.calculate("simulation update rate", true, true)) > Config.UpdateRate) and (MainWorld.GameState ~= GameStates.PAUSE) then
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

return MainWorld