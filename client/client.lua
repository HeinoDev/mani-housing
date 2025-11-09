local Config = lib.load('config')

Wait(250)

local HouseCache = lib.callback.await('mani-housing:server:GetHouses', false)
local Util = lib.load('open.cl_open')
local HousePoints, Models, GarageTick = {}, {}, nil

lib.locale()

RegisterCommand(Config.Commands['HouseInteraction'], function()
    local HouseIndex = cache.currentHouse or cache.inHouse
    if not HouseIndex then return end
    
    local House = HouseCache[HouseIndex]
    if not House then return end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenHouseInteraction",
        data = House
    })
end, false)

local function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local scale = 0.35

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

local function ExitHouse(House)
    if not cache.inHouse then return end
    cache.inHouse = nil

    local PlayerPed = cache.ped
    local EntranceCoords = vec4(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z, House.Coords.Entrance.w - 180)
    
    DoScreenFadeOut(500)
    Wait(500)

    exports['mani-bridge']:TeleportEntity(PlayerPed, EntranceCoords)

    CreateThread(function()
        for i = 1, #Models do
            DeleteEntity(Models[i])
        end

        Models = {}
    end)

    Wait(500)
    DoScreenFadeIn(500)
end

local function EnterHouse(Data)
    if cache.inHouse then return end

    local PlayerPed = cache.ped

    local HouseCoords = Data.HouseCoords
    local House = Data.House

    local ShellIndex = Config.ShellIndexes[House.Shell]
    if not ShellIndex then lib.print.error("Your shell doesn't exist - Contact support") return end
    local Shell = Config.Shells[ShellIndex]

    cache.inHouse = Data.HouseIndex

    local ShellCoords = vec3(HouseCoords.x, HouseCoords.y, HouseCoords.z + Config.ZOffset)

    local ShellModel = GetHashKey(Shell.Model)

    lib.requestModel(ShellModel)

    DoScreenFadeOut(500)
    Wait(500)

    local ShellProp = CreateObject(ShellModel, ShellCoords, false, false, false)
    FreezeEntityPosition(ShellProp, true)
    Models[#Models + 1] = ShellProp

    while not DoesEntityExist(ShellProp) do Wait(50) end

    local EnterCoords = vec4(ShellCoords.x + Shell.Offsets.Exit.x, ShellCoords.y + Shell.Offsets.Exit.y, ShellCoords.z + Shell.Offsets.Exit.z, Shell.Offsets.Exit.w)
    exports['mani-bridge']:TeleportEntity(PlayerPed, EnterCoords)

    CreateThread(function()
        while cache.inHouse do
            local Interval = 250

            local PlayerCoords = GetEntityCoords(PlayerPed)
            local Distance = #(PlayerCoords - EnterCoords.xyz)

            if Distance < Config.Distances['Interact'] then
                Interval = 0

                Draw3DText(EnterCoords.x, EnterCoords.y, EnterCoords.z + 0.50, 'Klik ~g~E~w~ for at gå ud')

                if IsControlJustReleased(0, 38) then
                    ExitHouse(House)
                end
            end

            Wait(Interval)
        end
    end)

    Wait(500)
    DoScreenFadeIn(500)

    SetModelAsNoLongerNeeded(ShellModel)
end

CreateThread(function()
    Wait(250)

    for HouseIndex, House in pairs(HouseCache) do

        local HouseCoords = vec3(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z)

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
                local Distance = #(PlayerCoords - HouseCoords)

                if cache.currentHouse then
                    local CurrentHouseCoords = HouseCache[cache.currentHouse].Coords.Entrance

                    if Distance > #(PlayerCoords - CurrentHouseCoords) then return end
                end

                cache.currentHouse = HouseIndex

                Util.InDistance(House)

                CreateThread(function()
                    while cache.currentHouse == HouseIndex do
                        local Interval = 250

                        PlayerCoords = GetEntityCoords(PlayerPed)
                        Distance = #(PlayerCoords - HouseCoords)

                        if Distance < Config.Distances['Interact'] then
                            Interval = 0

                            Draw3DText(HouseCoords.x, HouseCoords.y, HouseCoords.z, 'Klik ~g~E~w~ for at gå indenfor')

                            if IsControlJustReleased(0, 38) then
                                EnterHouse({
                                    HouseIndex = HouseIndex,
                                    HouseCoords = HouseCoords,
                                    House = House
                                })
                            end
                        end
                        
                        Wait(Interval)
                    end
                end)
            end,
            onExit = function(self)
                if cache.currentHouse == HouseIndex then cache.currentHouse = nil end
            end
        })

        if House.Coords.Garage then

            local GarageCoords = vec3(House.Coords.Garage.x, House.Coords.Garage.y, House.Coords.Garage.z)

            HousePoints[HouseIndex]['Garage'] = lib.points.new({
                coords = GarageCoords,
                distance = Config.Distances['Interact'],
                onEnter = function(self)
                    local PlayerData = exports['mani-bridge']:GetPlayerData()

                    local IsOwner = House.Owner == PlayerData.Identifier
                    local HasKey = House.Keyholders[PlayerData.Identifier] and House.Keyholders[PlayerData.Identifier]['Garage']

                    if not IsOwner and not HasKey then return end

                    local PlayerPed = cache.ped
                    local PlayerCoords = GetEntityCoords(PlayerPed)

                    GarageTick = SetInterval(function()
                        Draw3DText(GarageCoords.x, GarageCoords.y, GarageCoords.z, 'Klik ~g~E~w~ for at bruge garagen')

                            if IsControlJustReleased(0, 38) then
                                Util.InteractGarage(House)
                            end
                    end, 0)
                end,
                onExit = function(self)
                    if GarageTick then GarageTick = ClearInterval(GarageTick) end
                end
            })
        end
    end
end)

CreateThread(function()
    Config.ShellIndexes = {}

    for i = 1, #Config.Shells do
        local Shell = Config.Shells[i]
        Config.ShellIndexes[Shell.Model] = i
    end

    Wait(150)

    SendNUIMessage({
        action = "InitializeUI",
        data = Config
    })
end)

RegisterNetEvent('mani-housing:client:UpdateHouse', function(House, Action)
    if Action == 'Update' then
        HouseCache[House.HouseId] = House
        print(json.encode(House, { indent = true }))
    elseif Action == 'Create' then
        HouseCache[House.HouseId] = House
        -- Lav creation point
    elseif Action == 'Remove' then
        HouseCache[House.HouseId] = nil
        -- Fjern point
    end
end)