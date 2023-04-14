local MainWorld = {
	GamePaused = false;
	UpdateRate = nil;
	Generation = 0;
	Day = 0;
}

function MainWorld.load()
	MainWorld.UpdateRate = Config.UpdateRate
	MainWorld.Generation = 1
	MainWorld.Day = 1
	
    Log("Initiating all cells...")

    love.CellSpawnRandom = Packages.Random.new(Config.Seed)

	--love.GarrisonedCellsDisplay = BiArray.new(Config.World.Columns, Config.World.Rows, 0)

	--local chance = 10
	love.NextCellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows)
	love.CellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows, function(column, row)
		local chance = love.CellSpawnRandom:NextInt(1, 150)
		--chance = chance - 1
		
		if chance == 1 then
			local cell = Packages.CellClass.new({
				X = column;
				Y = row
			})
			

			return cell
		elseif chance == 2 or chance == 4 then
			local food = Packages.FoodClass.new({
				X = column;
				Y = row;
			})

			return food
		end
	end)

	love.GarrisonedCells = {}
	love.window.setMode(Config.WindowSize.X, Config.WindowSize.Y)

	DifferenceTime.start("simulation update rate")
end

function MainWorld.update()
    if ((DifferenceTime.calculate("simulation update rate", true, true)) > Config.UpdateRate) and (not MainWorld.GamePaused) then
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