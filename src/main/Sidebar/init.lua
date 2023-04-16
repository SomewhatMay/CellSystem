--// Sidebar \\--
--// SomewhatMay, April 2023 \\--

local Sidebar = {}
local SelectionFrame
local SceneInfoFrame
local FrameEntry

function Sidebar.Init()
    FrameEntry = Packages.FrameEntry
    SelectionFrame = require("src.main.Sidebar.SelectionFrame")
    SceneInfoFrame = require("src.main.Sidebar.SceneInfoFrame")
end

function Sidebar.load()
    Sidebar.SelectionFrame = SelectionFrame
    Sidebar.SceneInfoFrame = SceneInfoFrame

	SelectionFrame.load()
    SceneInfoFrame.load()
end

function Sidebar.update(dt)
    SelectionFrame.update(dt)
    SceneInfoFrame.update(dt)
end

function Sidebar.draw()
    -- Sidebar Background
    love.graphics.setColor(0.4745, 0.4745, 0.4745, 1)
    love.graphics.rectangle("fill", Config.WorldPixelWidth, 0, Config.SidebarWidth, Config.WindowSize.Y)

	SelectionFrame.draw()
    SceneInfoFrame.draw()
end

return Sidebar