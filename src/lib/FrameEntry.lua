local FrameEntry = {
    Buttons = {};
}
FrameEntry.__index = FrameEntry

FrameEntry.EntryTypes = {
    NEXT_LINE_VALUE = "frame_entry_type_next_line_value";
    BUTTON = "frame_entry_type_button";
}

function FrameEntry.mousePressed(x, y, button)
    local passedCallback = false

    if button == 1 then
        for _, button in pairs(FrameEntry.Buttons) do
            if x >= button.Position.X and y >= button.Position.Y then
                if x <= (button.Position.X + button.Size.Width) and y <= (button.Position.Y + button.Size.Height) then
                    for _, callback in pairs(button.PressCallbacks) do
                        callback(x, y, passedCallback)
                    end

                    -- This boolean lets the other buttons know that another button has alraedy been called passed to
                    passedCallback = true
                end
            end
        end
    end
end

local textFont = love.graphics.newFont(16)

function FrameEntry:Draw()
    -- Do not draw if the button is set to not visible.
    if not self.Visible then return end

    -- Draw the background
    love.graphics.setColor(.67, .67, .67, 1)
    love.graphics.rectangle("fill", self.Position.X, self.Position.Y, self.Size.Width, self.Size.Height)

    -- Draw the displayText
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(self.DisplayText, self.Position.X + 10, self.Position.Y)

    -- Draw the valueText only if we arent a button
    if self.EntryType ~= FrameEntry.EntryTypes.BUTTON then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.draw(self.ValueText, self.ValueTextPositionX, self.ValueTextPositionY)
    end
end

function FrameEntry:OnPress(callback)
    table.insert(self.PressCallbacks, callback)
end

function FrameEntry:UpdateValue(value, forceUpdate)
    if self.EntryType == FrameEntry.EntryTypes.BUTTON then return end
    if (forceUpdate ~= true) and (value == self.Value) then return end

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

        Visible = true;
        EntryType = entryType;
        PressCallbacks = {};
    }

    self = setmetatable(self, FrameEntry)

    if entryType == FrameEntry.EntryTypes.BUTTON then
        table.insert(FrameEntry.Buttons, self)
    else
        self:UpdateValue(value, true) -- set ValueText, Value, and ValueTextPosition
    end

    return self
end

return FrameEntry