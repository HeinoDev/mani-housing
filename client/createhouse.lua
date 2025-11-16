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

    local zone = GetLabelText(GetNameOfZone(EntranceCoords.xyz)) or 'Unknown'

    local GarageCoords = nil

    if Data.includeGarage then
        SendNUIMessage({
            action = 'ChangeGuide',
            data = {
                Key = 'E',
                Text = 'to select garage'
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

    local Success, Error = lib.callback.await('mani-housing:server:CreateHouse', false, {
        Shell = Data.shell,
        HasGarage = Data.includeGarage,
        Price = Data.price,
        Entrance = EntranceCoords,
        Garage = GarageCoords,
        Zone = zone
    })
end)

RegisterNUICallback('SetGarage', function(HouseId, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'ChangeGuide',
        data = {
            Key = 'E',
            Text = 'to select garage'
        }
    })

    Wait(500)

    while not IsControlJustPressed(0, 38) do
        Wait(0)
    end

    local PlayerPed = cache.ped

    local PlayerCoords = GetEntityCoords(PlayerPed)
    local PlayerHeading = GetEntityHeading(PlayerPed)

    local GarageCoords = vec4(PlayerCoords.xyz, PlayerHeading)

    local success, error = lib.callback.await('mani-housing:server:UpdateGarage', false, {
        Coords = GarageCoords,
        HouseId = HouseId
    })

    SendNUIMessage({
        action = 'HideUI'
    })

    -- notify

    cb({})
end)

RegisterNUICallback('RemoveHouse', function(HouseId, cb)
    SetNuiFocus(false, false)

    local success, error = lib.callback.await('mani-housing:server:RemoveHouse', false, HouseId)

    -- notify

    cb({})
end)

RegisterNUICallback('SellHouse', function(Data, cb)
    SetNuiFocus(false, false)

    local success, error = lib.callback.await('mani-housing:server:SellHouse', false, Data)

    -- notify

    cb({})
end)