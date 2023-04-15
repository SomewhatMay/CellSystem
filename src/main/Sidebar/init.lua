local Sidebar = {}
local SelectionFrame = require("src.main.Sidebar.SelectionFrame")

function Sidebar.load()
	SelectionFrame.load(Sidebar)
end

function Sidebar.update()
    
end

function Sidebar.draw()
    -- Sidebar Background
    love.graphics.setColor(0.4745, 0.4745, 0.4745, 1)
    love.graphics.rectangle("fill", Config.WorldPixelWidth, 0, Config.SidebarWidth, Config.WindowSize.Y)

	SelectionFrame.draw()
end

return Sidebar