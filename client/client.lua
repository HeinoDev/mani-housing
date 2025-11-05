local Config = lib.load('config')

local HouseCache = lib.callback.await('mani-housing:server:GetHouses', false)
local HousePoints = {}

lib.locale()

RegisterCommand(Config.Commands['RealEstate'], function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenRealestate"
    })
end)

CreateThread(function()
    Wait(150)

    SendNUIMessage({
        action = "InitializeUI",
        data = Config
    })
end)

RegisterNUICallback('HideUI', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNetEvent('mani-housing:client:UpdateHouses', function(Houses, Action, NewData)
    HouseCache = Houses

    if Action == 'Create' then
        
    elseif Action == 'Remove' then
        
    end
end)

CreateThread(function()
    for HouseIndex, House in pairs(HouseCache) do

        local HouseCoords = House.Coords.Entrance

        HousePoints[HouseIndex] = {}

        HousePoints[HouseIndex]['Entrance'] = lib.points.new({
            coords = HouseCoords,
            distance = 3.0,
            onEnter = function(self)
                local PlayerData = exports['mani-bridge']:GetPlayerData()

                local IsOwner = House.Owner == PlayerData.Identifier
                local HasKey = House.Keyholders[PlayerData.Identifier] and House.Keyholders[PlayerData.Identifier]['Enter']

                if not IsOwner and not HasKey then return end

                local PlayerPed = cache.ped
                local PlayerCoords = GetEntityCoords(PlayerPed)

                if cache.currentHouse then
                    local CurrentHouseCoords = HouseCache[cache.currentHouse].Coords.Entrance

                    if #(PlayerCoords - HouseCoords) > #(PlayerCoords - CurrentHouseCoords) then return end
                end

                cache.currentHouse = HouseIndex
            end,
            onExit = function(self)
                if cache.currentHouse == HouseIndex then cache.currentHouse = nil end
            end
        })

        -- if House.Coords.Garage then
        --     HousePoints[HouseIndex]['Garage'] = lib.points.new({
        --         coords = House.Coords.Garage,
        --     })
        -- end
    end
end)