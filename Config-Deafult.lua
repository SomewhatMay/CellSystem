--// CellSystem \\--
--// SomewhatMay, April 2023 \\--

-- This will be used if there is no local Config.lua
-- The Config.lua always overwrites this config
-- It is highly recommended to use a local Config.lua to change new variables

local settings = {
    UpdateRate = 0; -- tickrate; in seconds
    TotalScheduleSize = 8; -- the number of schedules each cell should have
    Seed = "random"; -- can be any number or 'random'
    MutationChance = .4; -- a decimal number

    -- This will be used to calcualte the chance for reproduction of cells based on their 'ranking'
    ReproductionPercentTable = {
        [1] = .3;
        [2] = .15;
        [3] = .1;
        [4] = .08;
        [5] = .06;
        [6] = .05;
        [7] = .04;
        [8] = .04;
        [9] = .03;
        [10] = .02;
    };
    ReproductionUnsignedSchedule = nil; -- Gets calculated based on the sum of the previous table. 

    WorldExtents = {
        Columns = 150;
        Rows = 150;
    };

    SidebarWidth = 300;
    WorldPixelWidth = nil; -- Will be determined based on SidebarWidth

    WindowSize = {
        X = 1300;
        Y = 1000;
    };

    Points = {
        Food = 10;
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

settings.WorldPixelWidth = settings.WindowSize.X - settings.SidebarWidth

settings.CellSize = {
    X = settings.WorldPixelWidth / settings.WorldExtents.Columns;
    Y = settings.WindowSize.Y / settings.WorldExtents.Rows;
}

local ReproductionPercentTableSum = 0
for index, value in pairs(settings.ReproductionPercentTable) do
    ReproductionPercentTableSum = ReproductionPercentTableSum + value

    settings.ReproductionPercentTable[index] = ReproductionPercentTableSum
end
settings.ReproductionUnsignedSchedule = ReproductionPercentTableSum

return settings