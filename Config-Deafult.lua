-- This will be used if there is no local Config.lua
-- The Config.lua always overwrites this config
-- It is highly recommended to use a local Config.lua to change new variables

local settings = {
    UpdateRate = .01; -- tickrate; in seconds
    TotalScheduleSize = 8; -- the number of schedules each cell should have

    World = {
        Columns = 150;
        Rows = 150;
    };

    WindowSize = {
        X = 1000;
        Y = 1000;
    };

    Points = {
        Food = 50;
        Death = -100;
    };

    ScheduleCoordinates = {
        EvalType = 1;
        ConnectionA = 2;
        ConnectionB = 3;
        ActionType = 4;
        AssistingBit1 = 5;
        AssistingBit2 = 6;
        AssistingBit3 = 7;
        EvalBit = 8;
    };
}

settings.CellSize = {
    X = settings.WindowSize.X / settings.World.Columns;
    Y = settings.WindowSize.Y / settings.World.Rows;
} 

return settings