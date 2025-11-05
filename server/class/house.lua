local House = {}
House.__index = House

function House:new(Data)
    return setmetatable({
        Owner = Data.Owner,
        Coords = Data.Coords,
        Decor = Data.Decor,
        SalesData = Data.SalesData,
        State = Data.State,
        Keyholders = {}
    }, self)
end

return House