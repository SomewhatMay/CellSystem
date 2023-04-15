local Sidebar
local SelectionFrame = {
    Position = Vector2.new(
        Config.WorldPixelWidth + 10,
        40
    );

    Size = UDIM2.new(
        Config.SidebarWidth - 20,
        180
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
    Entries.CellAncestry = FrameEntry.new("Ancestry:", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ), FrameEntry.EntryTypes.NEXT_LINE_VALUE)

    Entries.CellPoints = FrameEntry.new("Points:", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 40
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ))

    Entries.CellPosition = FrameEntry.new("Position:", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 65
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ))

    Entries.CellSchedule = FrameEntry.new("Schedule:", nil, Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 90
    ), UDIM2.new(
        SelectionFrame.Size.Width - 10,
        20
    ), FrameEntry.EntryTypes.NEXT_LINE_VALUE)

    Entries.CellLearnMore = FrameEntry.new("Learn more ...", "", Vector2.new(
        SelectionFrame.Position.X + 5,
        SelectionFrame.Position.Y + 5 + 130
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

        if targetCell.type == "cell" then
            Entries.CellPoints:UpdateValue(targetCell.Points)
            Entries.CellAncestry:UpdateValue(targetCell.Ancestry)
            Entries.CellSchedule:UpdateValue(Packages.ScheduleService.toString(targetCell.Schedule))
        else
            Entries.CellPoints:UpdateValue("N/A")
            Entries.CellAncestry:UpdateValue("N/A")
            Entries.CellSchedule:UpdateValue("N/A")
        end
	end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", SelectionFrame.Position.X, SelectionFrame.Position.Y, SelectionFrame.Size.Width, SelectionFrame.Size.Height)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(SelectionFrame.TitleText, SelectionFrame.Position.X + 5, SelectionFrame.Position.Y + 5)

    Entries.CellPosition:Draw()
    Entries.CellPoints:Draw()
    Entries.CellAncestry:Draw()
    Entries.CellSchedule:Draw()
    Entries.CellLearnMore:Draw()
end

return SelectionFrame