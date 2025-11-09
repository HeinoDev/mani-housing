RegisterNUICallback('HideUI', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('GetNearbyPlayers', function(_, cb)
    local Players = lib.callback.await('mani-housing:server:GetNearbyPlayers', false, GetEntityCoords(cache.ped))
    cb(Players)
end)

RegisterNUICallback('GiveKeys', function(Players, cb)
    local HouseId = cache.currentHouse or cache
    if not HouseId then return end
    local success, error = lib.callback.await('mani-housing:server:GiveKeys', false, Players, HouseId)
    cb({})
end)