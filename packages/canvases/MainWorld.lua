local MainWorld = {}

local clickedTargetCellFont
function MainWorld.load()
    clickedTargetCellFont = love.graphics.newFont(16)

    Log("Initiating all cells...")

    love.CellSpawnRandom = Packages.Random.new(Config.Seed)

	--love.GarrisonedCellsDisplay = BiArray.new(Config.World.Columns, Config.World.Rows, 0)

	--local chance = 10
	love.NextCellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows)
	love.CellGrid = Packages.BiArray.new(Config.WorldExtents.Columns, Config.WorldExtents.Rows, function(column, row)
		local chance = love.CellSpawnRandom:NextInt(1, 150)
		--chance = chance - 1
		
		if chance == 1 then
			local cell = Packages.Cell.new({
				X = column;
				Y = row
			})
			

			return cell
		elseif chance == 2 or chance == 4 then
			local food = Packages.Food.new({
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

local clickedTargetCell
function MainWorld.update()
    if (DifferenceTime.calculate("simulation update rate", true, true)) > Config.UpdateRate then

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
end

return MainWorld