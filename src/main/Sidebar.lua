local Sidebar = {}

local clickedTargetCellFont
function Sidebar.load()
    clickedTargetCellFont = love.graphics.newFont(16)
end

local clickedTargetCell
function Sidebar.update()
    
end

function Sidebar.draw()
    -- Sidebar Background
    love.graphics.setColor(121/255, 121/255, 121/255, 1)
    love.graphics.rectangle("fill", Config.WorldPixelWidth, 0, Config.SidebarWidth, Config.WindowSize.Y)

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
		}
	end

    -- Target cell gui gui
	if not targetCell then
    else
		love.graphics.setColor(1, 1, 1, .5)
		love.graphics.rectangle("fill", 8, 10, targetCell.text:getWidth() + 3, targetCell.text:getHeight() + 3)
		love.graphics.setColor(0, 0, 0)
		love.graphics.draw(targetCell.text, 10, 12)
	end
end

return Sidebar