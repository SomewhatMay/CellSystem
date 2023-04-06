local settings = {
    UpdateRate = 1; -- tickrate; in seconds
    TotalScheduleSize = 8; -- the number of schedules each cell should have 

    World = {
        Columns = 100;
        Rows = 100;
    };

    WindowSize = {
        X = 800;
        Y = 800;
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