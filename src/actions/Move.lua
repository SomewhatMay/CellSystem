--// Move: Action \\--
--// SomewhatMay, April 2023 \\--

--wraps if it doesnt fit in the values
--@param {number} direction - Can be `0` (up) `1` (right) `2` (down) `3` (left)
return function(cell, direction)
    direction = (direction or 0) % 4
    local XOffset, YOffset = 0, 0

    if direction == 0 then
        YOffset = 1
    elseif direction == 1 then
        XOffset = 1
    elseif direction == 2 then
        YOffset = -1
    elseif direction == 3 then
        XOffset = -1
    end

    cell.Position.X = cell.Position.X + XOffset
    cell.Position.Y = cell.Position.Y + YOffset

    if cell.Position.X > Packages.Config.WorldExtents.Columns then
        cell.Position.X = 1
    end

    if cell.Position.Y > Packages.Config.WorldExtents.Rows then
        cell.Position.Y = 1
    end

    return direction
end