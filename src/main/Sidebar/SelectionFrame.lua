local Sidebar
local SelectionFrame = {
    Position = Vector2.new(
        Config.WorldPixelWidth + 10,
        40
    );

    Size = UDIM2.new(
        Config.SidebarWidth - 20,
        150
    );

    TitleText = nil;
}
local FrameEntry
local Entries = {}

local slectionFrameFont
local slectionFrameTitleFont
function SelectionFrame.load(_Sidebar)
    Sidebar = _Sidebar
    FrameEntry = require("src.main.Sidebar.FrameEntry")

    slectionFrameFont = love.graphics.newFont(16)
    slectionFrameTitleFont = love.graphics.newFont(20)

    SelectionFrame.TitleText = love.graphics.newText(slectionFrameTitleFont, "Selection")

    -- Cell selection entries
    Entries.CellPosition = FrameEntry.new("Position", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 50
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ))

    Entries.CellPoints = FrameEntry.new("Points", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 25
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ))

    Entries.CellAncestry = FrameEntry.new("Ancestry", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ))

    Entries.CellDNA = FrameEntry.new("DNA", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 75
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ))

    Entries.CellLearnMore = FrameEntry.new("Learn more ...", "", Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 100
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ))
end

local clickedTargetCell
function SelectionFrame.draw()
    -- Target cell drawing 
	local targetCell
	local mouseX, mouseY = love.mouse.getPosition()
	local targetPosition = {
		X = math.ceil(mouseX / Config.CellSize.X);
		Y = math.ceil(mouseY / Config.CellSize.Y);
	}

	if love.mouse.isDown(1) then
		local currentCell = love.CellGrid:Get(targetPosition.X, targetPosition.Y)
		clickedTargetCell = currentCell
	end

	targetCell = clickedTargetCell

	if not targetCell then
		local currentCell = love.CellGrid:Get(targetPosition.X, targetPosition.Y)
		targetCell = currentCell
	end

	if targetCell then
		Entries.CellPosition:UpdateValue(targetCell.Position:toString())
        Entries.CellPoints:UpdateValue(targetCell.Points)
        Entries.CellAncestry:UpdateValue(targetCell.Ancestry)
        Entries.CellDNA:UpdateValue(targetCell.DNA)
	end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", SelectionFrame.Position.X, SelectionFrame.Position.Y, SelectionFrame.Size.Width, SelectionFrame.Size.Height)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(SelectionFrame.TitleText, SelectionFrame.Position.X + 5, SelectionFrame.Position.Y + 5)

    Entries.CellPosition:Draw()
    Entries.CellPoints:Draw()
    Entries.CellAncestry:Draw()
    Entries.CellDNA:Draw()
    Entries.CellLearnMore:Draw()
end

return SelectionFrame