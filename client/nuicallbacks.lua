RegisterNUICallback('HideUI', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('GetNearbyPlayers', function(_, cb)
    local Players = lib.callback.await('mani-housing:server:GetNearbyPlayers', false, GetEntityCoords(cache.ped), cache.currentHouse or cache.inHouse)
    cb(Players)
end)

RegisterNUICallback('UpdateKeyPermissions', function(Data, cb)
    local Sucess, Message = lib.callback.await('mani-housing:server:UpdatePermissions', false, Data)
    cb({})
end)

RegisterNUICallback('RemoveKeyholder', function(Data, cb)
    local Sucess, Message = lib.callback.await('mani-housing:server:RemoveKeyholder', false, Data)
    cb({
        Success = Sucess
    })
end)

RegisterNUICallback('PurchaseHouse', function(HouseId, cb)
    local Sucess, Message = lib.callback.await('mani-housing:server:PurchaseHouse', false, HouseId)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('PlaceWardrobe', function(_, cb)
    local HouseId = cache.inHouse
    if not HouseId then return end
    local Sucess, Message = lib.callback.await('mani-housing:server:PlaceWardrobe', false, {
        HouseId = HouseId,
        PlayerCoords = GetEntityCoords(cache.ped)
    })
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('PlaceStash', function(HouseId, cb)
    local HouseId = cache.inHouse
    if not HouseId then return end
    local Sucess, Message = lib.callback.await('mani-housing:server:PlaceStash', false, {
        HouseId = HouseId,
        PlayerCoords = GetEntityCoords(cache.ped)
    })
    SetNuiFocus(false, false)
    cb({})
end)