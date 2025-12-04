local Config = lib.load('config')

RegisterNUICallback('CreateHouse', function(Data, cb)
    SetNuiFocus(false, false)

    while not IsControlJustPressed(0, 38) do
        Wait(0)
    end

    local PlayerPed = cache.ped
    local PlayerCoords = GetEntityCoords(PlayerPed)
    local PlayerHeading = GetEntityHeading(PlayerPed)

    local EntranceCoords = vec4(PlayerCoords.xyz, PlayerHeading)

    local Zone = GetLabelText(GetNameOfZone(EntranceCoords.xyz)) or 'Unknown'

    local GarageCoords = nil

    if Data.includeGarage then
        SendNUIMessage({
            action = 'ChangeGuide',
            data = {
                Key = 'E',
                Text = locale('UI.SelectGarage')
            }
        })

        Wait(500)

        while not IsControlJustPressed(0, 38) do
            Wait(0)
        end
        
        PlayerCoords = GetEntityCoords(PlayerPed)
        PlayerHeading = GetEntityHeading(PlayerPed)

        GarageCoords = vec4(PlayerCoords.xyz, PlayerHeading)
    end

    SendNUIMessage({
        action = 'HideUI'
    })

    local Success, Message = lib.callback.await('mani-housing:server:CreateHouse', false, {
        Shell = Data.shell,
        HasGarage = Data.includeGarage,
        Price = Data.price,
        Entrance = EntranceCoords,
        Garage = GarageCoords,
        Zone = Zone
    })
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end
end)

RegisterNUICallback('SetGarage', function(HouseId, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'ChangeGuide',
        data = {
            Key = 'E',
            Text = locale('UI.SelectGarage')
        }
    })

    Wait(500)

    while not IsControlJustPressed(0, 38) do
        Wait(0)
    end

    local PlayerPed = cache.ped

    local PlayerCoords = GetEntityCoords(PlayerPed)

    local Success, Message = lib.callback.await('mani-housing:server:UpdateGarage', false, {
        Coords = PlayerCoords,
        HouseId = HouseId
    })

    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    SendNUIMessage({
        action = 'HideUI'
    })

    cb({})
end)

RegisterNUICallback('RemoveHouse', function(HouseId, cb)
    SetNuiFocus(false, false)

    local Success, Message = lib.callback.await('mani-housing:server:RemoveHouse', false, HouseId)
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    cb({})
end)

RegisterNUICallback('SellHouse', function(Data, cb)
    SetNuiFocus(false, false)

    local Success, Message = lib.callback.await('mani-housing:server:SellHouse', false, Data)
    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    cb({})
end)