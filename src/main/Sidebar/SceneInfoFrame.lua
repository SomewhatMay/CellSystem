--// SceneInfo: Frame \\--
--// SomewhatMay, April 2023 \\--

local Sidebar
local MainWorld
local SelectionFrame
local SceneFrame = {
    Position = Vector2.new(
        Config.WorldPixelWidth + 10,
        0 -- We have to add the selectioNFrame's size and position to this + 5 padding
    );

    Size = UDIM2.new(
        Config.SidebarWidth - 20,
        205
    );

    TitleText = nil;
}
local FrameEntry
local Entries = {}

local sceneFrameTitleFont
function SceneFrame.load()
    Sidebar = Packages.Sidebar
    SelectionFrame = Sidebar.SelectionFrame
    MainWorld = Packages.MainWorld
    FrameEntry = Packages.FrameEntry

    SceneFrame.Position.Y = SelectionFrame.Position.Y + SelectionFrame.Size.Height + 10

    sceneFrameTitleFont = love.graphics.newFont(20)

    SceneFrame.TitleText = love.graphics.newText(sceneFrameTitleFont, "Scene Info")

    -- Scene info entries
    Entries.GameState = FrameEntry.new("Game State: ", nil, Vector2.new(
        SceneFrame.Position.X + 5,
        SceneFrame.Position.Y + 5 + 25
    ), UDIM2.new(
        SceneFrame.Size.Width - 10,
        20
    ))

    Entries.PauseGame = FrameEntry.new("Pause Game ", nil, Vector2.new(
        SceneFrame.Position.X + 5,
        SceneFrame.Position.Y + 5 + 25 + 25
    ), UDIM2.new(
        SceneFrame.Size.Width - 10,
        20
    ), FrameEntry.EntryTypes.BUTTON)

    Entries.Generation = FrameEntry.new("Generation: ", nil, Vector2.new(
        SceneFrame.Position.X + 5,
        SceneFrame.Position.Y + 5 + 50 + 25
    ), UDIM2.new(
        SceneFrame.Size.Width - 10,
        20
    ))

    Entries.Day = FrameEntry.new("Day: ", nil, Vector2.new(
        SceneFrame.Position.X + 5,
        SceneFrame.Position.Y + 5 + 75 + 25
    ), UDIM2.new(
        SceneFrame.Size.Width - 10,
        20
    ))

    Entries.CellsInfo = FrameEntry.new("Cells: ", nil, Vector2.new(
        SceneFrame.Position.X + 5,
        SceneFrame.Position.Y + 5 + 100 + 25
    ), UDIM2.new(
        SceneFrame.Size.Width - 10,
        20
    ))

    Entries.FoodInfo = FrameEntry.new("Food: ", nil, Vector2.new(
        SceneFrame.Position.X + 5,
        SceneFrame.Position.Y + 5 + 125 + 25
    ), UDIM2.new(
        SceneFrame.Size.Width - 10,
        20
    ))

    -- Attach event listeners
    Entries.PauseGame:OnPress(MainWorld.TogglePause)
end

function SceneFrame.update(dt)
    -- Update the values
    Entries.GameState:UpdateValue(MainWorld.GetGameStateString())
    Entries.Generation:UpdateValue(MainWorld.Generation)
    Entries.Day:UpdateValue(MainWorld.Day)
    Entries.CellsInfo:UpdateValue(tostring(MainWorld.CellsAlive) .. " (" .. tostring(MainWorld.CellsGarrisoned) .. ")")
    Entries.FoodInfo:UpdateValue(tostring(MainWorld.FoodAlive) .. " (" .. tostring(MainWorld.FoodEaten) .. ")")
end

function SceneFrame.draw()
    -- Draw the frame itself
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", SceneFrame.Position.X, SceneFrame.Position.Y, SceneFrame.Size.Width, SceneFrame.Size.Height)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(SceneFrame.TitleText, SceneFrame.Position.X + 5, SceneFrame.Position.Y + 5)

    -- Draw the entries
    Entries.GameState:Draw()
    Entries.Generation:Draw()
    Entries.Day:Draw()
    Entries.CellsInfo:Draw()
    Entries.FoodInfo:Draw()
    Entries.PauseGame:Draw()
end

return SceneFrame