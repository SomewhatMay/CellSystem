local FrameEntry = {}
FrameEntry.__index = FrameEntry

FrameEntry.EntryTypes = {
    NEXT_LINE_VALUE = "NEXT_LINE_VALUE_ajdfbhoasdyufghuids";
}

local textFont = love.graphics.newFont(16)

function FrameEntry:Draw()
    -- Draw the background
    love.graphics.setColor(.67, .67, .67, 1)
    love.graphics.rectangle("fill", self.Position.X, self.Position.Y, self.Size.Width, self.Size.Height)

    -- Draw the displayText
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(self.DisplayText, self.Position.X + 10, self.Position.Y)

    -- Draw the valueText
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(self.ValueText, self.ValueTextPositionX, self.ValueTextPositionY)
end

function FrameEntry:UpdateValue(value)
    self.Value = value
    self.ValueText:set(tostring(value))
    self.ValueText:set(tostring(value), self.ValueText:getWidth(), "right")
    self.ValueTextPositionX = self.Position.X + self.Size.Width - self.ValueText:getWidth() - 5
end

--@param position {Vector2} - {X = int; Y = int}
--@param size {UDIM2} - {Width = int; Height = int}
function FrameEntry.new(displayName, value, position, size, entryType)
    local valueTextPositionY = position.Y

    if entryType == FrameEntry.EntryTypes.NEXT_LINE_VALUE then
        valueTextPositionY = valueTextPositionY + 16
        size.Height = size.Height + 16
    end

    local self = {
        DisplayName = displayName;
        Value = nil;
        Position = position;
        Size = size;
        DisplayText = love.graphics.newText(textFont, displayName);
        ValueText = love.graphics.newText(textFont);
        ValueTextPositionX = nil;
        ValueTextPositionY = valueTextPositionY;
    }

    self = setmetatable(self, FrameEntry)
    self:UpdateValue(value) -- set ValueText, Value, and ValueTextPosition

    return self
end

return FrameEntry