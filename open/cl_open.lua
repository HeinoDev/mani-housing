local Util = {}

local Webhook = ''

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

function Util.OpenStash(House)
    if not exports['mani-bridge']:OpenInventory('stash', ('housestash_%s'):format(House.HouseId)) then
        local Success, Message = lib.callback.await('mani-housing:server:RegisterStash', false, House.HouseId)
        if Success then
            exports['mani-bridge']:OpenInventory('stash', ('housestash_%s'):format(House.HouseId))
        else
            exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000)
        end
    end
end

function Util.Log(Source, Message)
    exports['mani-bridge']:DiscordWebhook(Source, {
        Webhook = Webhook,
        Resource = 'Mani-Housing',
        Message = Message
    })
end

return Util