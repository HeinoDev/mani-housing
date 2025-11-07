local House = {}

function House.InDistance(House) -- When the player is near a house.
    
end

function House.InteractGarage(House)
    if cache.vehicle then
        TriggerEvent("elevate_garage:parkVehicle", cache.vehicle, "privatHus")
    else
        TriggerEvent("elevate_garage:openGarage", "privatHus", true)
    end
end

return House