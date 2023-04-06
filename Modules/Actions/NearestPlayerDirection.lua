local function spiral(x, y, callback)
    local dx, dy = 1, 0
    local steps = 1
    local initX, initY = x, y -- Remember initial position

    while true do
        for i = 1, steps do
            x = x + dx
            y = y + dy

            if callback(x, y, x - initX, y - initY) then
                return true-- Pass relative position
            end
        end

        dx, dy = -dy, dx
        if dy == 0 then
            steps = steps + 1
        end
    end
end

return function(cell)
    local direction = 0

    spiral(cell.Position.X, cell.Position.Y, function(x, y, xOffset, yOffset)
        if love.CellGrid:OutOfBounds(x, y) then return end
        local value = love.CellGrid:Get(x, y)

        if value and value.type == "food" then
            if math.abs(xOffset) > math.abs(yOffset) then
                -- x offset is stronger, let's move in that direction first
                direction = ((xOffset > 0) and 1) or 3 -- 1 is right, 3 is left
            else
                direction = ((yOffset > 0) and 0) or 2 -- 0 is up, 2 is down
            end

            return true
        end
    end)

    return direction
end