RegisterNUICallback('HideUI', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('GetNearbyPlayers', function(_, cb)
    local Players = lib.callback.await('mani-housing:server:GetNearbyPlayers', false, GetEntityCoords(cache.ped), cache.CurrentHouse or cache.InHouse)
    cb(Players)
end)

RegisterNUICallback('UpdateKeyPermissions', function(Data, cb)
    local Success, Message = lib.callback.await('mani-housing:server:UpdatePermissions', false, Data)
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end
    cb({})
end)

RegisterNUICallback('RemoveKeyholder', function(Data, cb)
    local Success, Message = lib.callback.await('mani-housing:server:RemoveKeyholder', false, Data)
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end
    cb({
        Success = Success
    })
end)

RegisterNUICallback('PurchaseHouse', function(HouseId, cb)
    SetNuiFocus(false, false)
    local Success, Message = lib.callback.await('mani-housing:server:PurchaseHouse', false, HouseId)
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end
    cb({})
end)

RegisterNUICallback('PlaceWardrobe', function(_, cb)
    SetNuiFocus(false, false)
    local HouseId = cache.InHouse
    if not HouseId then return end
    local Success, Message = lib.callback.await('mani-housing:server:PlaceWardrobe', false, {
        HouseId = HouseId,
        PlayerCoords = GetEntityCoords(cache.ped)
    })
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end
    cb({})
end)

RegisterNUICallback('PlaceStash', function(HouseId, cb)
    SetNuiFocus(false, false)
    local HouseId = cache.InHouse
    if not HouseId then return end
    local Success, Message = lib.callback.await('mani-housing:server:PlaceStash', false, {
        HouseId = HouseId,
        PlayerCoords = GetEntityCoords(cache.ped)
    })
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end
    cb({})
end)