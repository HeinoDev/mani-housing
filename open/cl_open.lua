local Util = {}

function Util.InDistance(House) -- When the player is near a house.
    
end

function Util.InteractGarage(House)
    if cache.vehicle then
        TriggerEvent("elevate_garage:parkVehicle", cache.vehicle, "privatHus")
    else
        TriggerEvent("elevate_garage:openGarage", "privatHus", true)
    end
end

function Util.OpenWardrobe()
    TriggerEvent('rcore_clothing:openClothingShopWithEverythingAndFree')
end

function Util.OpenStash()

end

return Util