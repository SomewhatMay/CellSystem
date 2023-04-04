local settings = {
    UpdateRate = 3; -- tickrate; in seconds

    World = {
        Columns = 100;
        Rows = 100;
    };

    WindowSize = {
        X = 800;
        Y = 800;
    }
}

settings.CellSize = {
    X = settings.WindowSize.X / settings.World.Columns;
    Y = settings.WindowSize.Y / settings.World.Rows;
} 

return settings