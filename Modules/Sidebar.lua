local Sidebar = {}

function Sidebar:Draw()
    -- Sidebar Background
    love.graphics.setColor(121/255, 121/255, 121/255, 1)
    love.graphics.rectangle("fill", Config.WorldPixelWidth, 0, Config.SidebarWidth, Config.WindowSize.Y)
end

return Sidebar