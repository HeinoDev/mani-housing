local Config = lib.load('config')

local HouseCache = lib.callback.await('mani-housing:server:GetHouses', false)
local Util = lib.load('open.cl_open')
local HousePoints, GarageTick = {}, nil

local InHouse = { ShellModel = nil, Models = {}, Points = {} }

local JobCache = {}

lib.locale()

local function HasAccess(HouseId, Identifier, Key)
    local House = type(HouseId) == 'table' and HouseId or HouseCache[HouseId]
    if not House then return false end

    local IsOwner = House.Owner == Identifier
    local HasKey = House.Keyholders[Identifier] and House.Keyholders[Identifier].Permissions[Key or 'Enter']

    return IsOwner or HasKey
end

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

local function CreateBlip(Data)
    local Blip = AddBlipForCoord(Data.Coords.xyz)
    SetBlipSprite(Blip, Data.Sprite)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, Data.Scale or 0.8)
    SetBlipColour(Blip, Data.Color)
    SetBlipAsShortRange(Blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Data.Name or '')
    EndTextCommandSetBlipName(Blip)

    return Blip
end

local function ExitHouse(House)
    if not cache.inHouse then return end
    cache.inHouse = nil

    lib.callback.await('mani-housing:server:ExitHouse', false, House.HouseId)

    local PlayerPed = cache.ped
    local EntranceCoords = vec4(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z, House.Coords.Entrance.w - 180)
    
    DoScreenFadeOut(500)
    Wait(500)

    exports['mani-bridge']:TeleportEntity(PlayerPed, EntranceCoords)

    CreateThread(function()
        DeleteEntity(InHouse['ShellModel'])

        for i = 1, #InHouse['Models'] do
            DeleteEntity(InHouse['Models'][i])
        end

        InHouse['Models'] = {}

        InHouse['Points']['Exit']:remove()
        if InHouse['Points']['Wardrobe'] then InHouse['Points']['Wardrobe']:remove() end
        if InHouse['Points']['Stash'] then InHouse['Points']['Stash']:remove() end

        InHouse['Points'] = {}
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

    lib.callback.await('mani-housing:server:EnterHouse', false, Data.HouseIndex)

    local ShellCoords = vec3(HouseCoords.x, HouseCoords.y, HouseCoords.z + Config.ZOffset)

    local ShellModel = GetHashKey(Shell.Model)

    lib.requestModel(ShellModel)

    DoScreenFadeOut(500)
    Wait(500)

    local ShellProp = CreateObject(ShellModel, ShellCoords, false, false, false)
    FreezeEntityPosition(ShellProp, true)
    InHouse['ShellModel'] = ShellProp

    while not DoesEntityExist(ShellProp) do Wait(50) end

    local EnterCoords = vec4(ShellCoords.x + Shell.Offsets.Exit.x, ShellCoords.y + Shell.Offsets.Exit.y, ShellCoords.z + Shell.Offsets.Exit.z, Shell.Offsets.Exit.w)

    exports['mani-bridge']:TeleportEntity(PlayerPed, EnterCoords)

    InHouse['Points']['Exit'] = lib.points.new({
        coords = EnterCoords,
        distance = Config.Distances['Interact'],
        nearby = function(self)
            Draw3DText(EnterCoords.x, EnterCoords.y, EnterCoords.z + 0.50, locale('3DText.ExitHouse'))

            if IsControlJustReleased(0, 38) then
                ExitHouse(House)
            end
        end
    })

    if House.Coords.Wardrobe then
        House.Coords.Wardrobe = vec3(House.Coords.Wardrobe.x, House.Coords.Wardrobe.y, House.Coords.Wardrobe.z)

        InHouse['Points']['Wardrobe'] = lib.points.new({
            coords = House.Coords.Wardrobe,
            distance = Config.Distances['Interact'],
            nearby = function(self)
                Draw3DText(House.Coords.Wardrobe.x, House.Coords.Wardrobe.y, House.Coords.Wardrobe.z, locale('3DText.Wardrobe'))

                if IsControlJustReleased(0, 38) then
                    Util.OpenWardrobe()
                end
            end
        })
    end

    if House.Coords.Stash then
        House.Coords.Stash = vec3(House.Coords.Stash.x, House.Coords.Stash.y, House.Coords.Stash.z)

        InHouse['Points']['Stash'] = lib.points.new({
            coords = House.Coords.Stash,
            distance = Config.Distances['Interact'],
            nearby = function(self)
                Draw3DText(House.Coords.Stash.x, House.Coords.Stash.y, House.Coords.Stash.z, locale('3DText.Stash'))

                if IsControlJustReleased(0, 38) then
                    Util.OpenStash(House)
                end
            end
        })
    end

    Wait(500)
    DoScreenFadeIn(500)

    SetModelAsNoLongerNeeded(ShellModel)
end

local function SeeOffer(HouseId)
    local House = HouseCache[HouseId]
    if not House then return end
    if House.State ~= 0 then return end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenHouseOffer",
        data = House
    })
end

local function CreateHouse(HouseIndex, House, PlayerData)
    local HouseCoords = vec3(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z)

    HousePoints[HouseIndex] = HousePoints[HouseIndex] or {}

    if HousePoints[HouseIndex]['Entrance'] then HousePoints[HouseIndex]['Entrance']:remove() end
    HousePoints[HouseIndex]['Entrance'] = lib.points.new({
        coords = HouseCoords,
        distance = 3.0,
        onEnter = function(self)
            House = HouseCache[House.HouseId]
            if not House then return end

            self.PlayerData = exports['mani-bridge']:GetPlayerData()
            if not self.PlayerData then return end

            self.PlayerPed = cache.ped
            local PlayerCoords = GetEntityCoords(PlayerPed)
            local Distance = #(PlayerCoords - HouseCoords)

            self.Estate = House.State == 0 and self.PlayerData.Identifier ~= House.Owner

            if not self.Estate then
                if not HasAccess(House, self.PlayerData.Identifier, 'Enter') then return end

                if cache.currentHouse then
                    local CurrentHouseCoords = HouseCache[cache.currentHouse].Coords.Entrance

                    if Distance > #(PlayerCoords - CurrentHouseCoords.xyz) then return end
                end
                
                Util.InDistance(House)
                
                cache.currentHouse = HouseIndex
            end
        end,
        nearby = function(self)
            if not self.Estate and cache.currentHouse ~= HouseIndex then return end

            local PlayerCoords = GetEntityCoords(self.PlayerPed)
            local Distance = #(PlayerCoords - HouseCoords)

            if Distance < Config.Distances['Interact'] then
                Draw3DText(HouseCoords.x, HouseCoords.y, HouseCoords.z, self.Estate and locale('3DText.SeeOffer') or locale('3DText.EnterHouse'))

                if IsControlJustReleased(0, 38) then
                    if self.Estate then
                        SeeOffer(HouseIndex)
                    else
                        EnterHouse({
                            HouseIndex = HouseIndex,
                            HouseCoords = HouseCoords,
                            House = House
                        })
                    end
                end
            end
        end,
        onExit = function(self)
            if cache.currentHouse == HouseIndex then cache.currentHouse = nil end
        end
    })

    if House.Coords.Garage then
        local GarageCoords = vec3(House.Coords.Garage.x, House.Coords.Garage.y, House.Coords.Garage.z)

        if HousePoints[HouseIndex]['Garage'] then HousePoints[HouseIndex]['Garage']:remove() end
        HousePoints[HouseIndex]['Garage'] = lib.points.new({
            coords = GarageCoords,
            distance = Config.Distances['Interact'],
            onEnter = function(self)
                House = HouseCache[House.HouseId]
                local PlayerData = exports['mani-bridge']:GetPlayerData()
                if not PlayerData then return end

                self.HasAcess = HasAccess(House, self.PlayerData.Identifier, 'Garage')
            end,
            nearby = function(self)
                if not self.HasAcess then return end

                Draw3DText(GarageCoords.x, GarageCoords.y, GarageCoords.z, locale('3DText.Garage'))

                if IsControlJustReleased(0, 38) then
                    Util.InteractGarage(House)
                end
            end
        })
    end

    if HousePoints[House.HouseId]['Blip'] then
        RemoveBlip(HousePoints[House.HouseId]['Blip'])
    end

    local PlayerData = PlayerData or exports['mani-bridge']:GetPlayerData()

    if House.Owner == PlayerData.Identifier then
        HousePoints[HouseIndex]['Blip'] = CreateBlip({
            Coords = vec3(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z),
            Sprite = Config.Blips['Owned'].Sprite,
            Color = Config.Blips['Owned'].Color,
            Name =  ('%s (%s)'):format(Config.Blips['Owned'].Name, House.HouseId)
        })
    elseif House.Keyholders[PlayerData.Identifier] then
        HousePoints[HouseIndex]['Blip'] = CreateBlip({
            Coords = vec3(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z),
            Sprite = Config.Blips['Keyholder'].Sprite,
            Color = Config.Blips['Keyholder'].Color,
            Name =  ('%s (%s)'):format(Config.Blips['Keyholder'].Name, House.HouseId)
        })
    elseif House.State == 0 then
        HousePoints[HouseIndex]['Blip'] = CreateBlip({
            Coords = vec3(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z),
            Sprite = Config.Blips['ForSale'].Sprite,
            Color = Config.Blips['ForSale'].Color,
            Name =  Config.Blips['ForSale'].Name
        })
    end
end

local function SetupJobBlips()
    for HouseIndex, House in pairs(HouseCache) do
        JobCache[HouseIndex] = {}

        JobCache[HouseIndex]['Point'] = lib.points.new({
            coords = vec3(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z),
            distance = Config.Distances['JobMode'],
            nearby = function(self)
                DrawMarker(
                    20, -- Marker type
                    House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z,
                    0.0, 0.0, 0.0, -- Direction
                    0.0, 0.0, 0.0, -- Rotation
                    0.5, 0.5, 0.5, -- Scale
                    0, 150, 255, 150, -- RGBA color (light blue)
                    false, true, 2, false, nil, nil, false
                )

                if House.Coords.Garage then
                    DrawMarker(
                        36, -- Marker type
                        House.Coords.Garage.x, House.Coords.Garage.y, House.Coords.Garage.z,
                        0.0, 0.0, 0.0, -- Direction
                        0.0, 0.0, 0.0, -- Rotation
                        1.0, 1.0, 1.0, -- Scale
                        0, 150, 255, 150, -- RGBA color (light blue)
                        false, true, 2, false, nil, nil, false
                    )

                    DrawLine(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z, House.Coords.Garage.x, House.Coords.Garage.y, House.Coords.Garage.z, 0, 150, 255, 255)

                    local midX = (House.Coords.Entrance.x + House.Coords.Garage.x) / 2
                    local midY = (House.Coords.Entrance.y + House.Coords.Garage.y) / 2
                    local midZ = (House.Coords.Entrance.z  + House.Coords.Garage.z) / 2

                    Draw3DText(midX, midY, midZ, "Garage")
                end

                if self.currentDistance < Config.Distances['Interact'] then
                    Draw3DText(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z + 0.5, locale('3DText.HouseInformation'))

                    if IsControlJustPressed(0, 74) then
                        SetNuiFocus(true, true)

                        SendNUIMessage({
                            action = "OpenHouseStats",
                            data = House
                        })
                    end
                end
            end
        })

        if House.State ~= 0 then
            JobCache[HouseIndex]['Blip'] = CreateBlip({
                Coords = vec3(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z),
                Sprite = Config.Blips['JobMode'].Sprite,
                Color = Config.Blips['JobMode'].Color,
                Name =  Config.Blips['JobMode'].Name
            })
        end
    end
end

local function RemoveJobBlips()
    for HouseIndex, Data in pairs(JobCache) do
        if Data['Point'] then
            Data['Point']:remove()
        end

        if Data['Blip'] then
            RemoveBlip(Data['Blip'])
        end
    end

    JobCache = {}
end

local function LoadAllHouses(PlayerData)
    for HouseIndex, House in pairs(HouseCache) do
        CreateHouse(HouseIndex, House, PlayerData)
    end
end

RegisterNetEvent('mani-bridge:client:PlayerLoaded', LoadAllHouses)

CreateThread(function()
    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    Wait(400)

    LoadAllHouses(PlayerData)
end)

CreateThread(function()
    Config.ShellIndexes = {}

    for i = 1, #Config.Shells do
        local Shell = Config.Shells[i]
        Config.ShellIndexes[Shell.Model] = i
    end

    local WhitelistedJobs = Config.WhitelistedJobs
    Config.WhitelistedJobs = {}

    for _, Job in ipairs(WhitelistedJobs) do
        Config.WhitelistedJobs[Job] = true
    end

    Wait(500)

    SendNUIMessage({
        action = "InitializeUI",
        data = {
            Config = Config,
            Locales = lib.getLocales()
        }
    })
end)

RegisterCommand(Config.Commands['HouseInteraction'], function()
    local HouseIndex = cache.currentHouse or cache.inHouse
    if not HouseIndex then return end
    
    local House = HouseCache[HouseIndex]
    if not House then return end    

    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    if not HasAccess(House, PlayerData.Identifier, 'Admin') then return end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'OpenHouseInteraction',
        data = House
    })
end, false)

RegisterCommand(Config.Commands['RealEstate'], function()
    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    local Job = PlayerData.Job.Name
    if not Config.WhitelistedJobs[Job] then return end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'OpenRealestate',
        data = HouseCache
    })
end, false)

RegisterNUICallback('GiveKeys', function(Players, cb)
    local HouseId = cache.currentHouse or cache.inHouse
    if not HouseId then return end
    local Success, Message = lib.callback.await('mani-housing:server:GiveKeys', false, Players, HouseId)

    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    cb({
        Success = Success,
        Keyholders = HouseCache[HouseId].Keyholders
    })
end)

RegisterNUICallback('ViewLocation', function(HouseId, cb)
    SetNuiFocus(false, false)

    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    local Job = PlayerData.Job.Name
    if not Config.WhitelistedJobs[Job] then return end

    local House = HouseCache[HouseId]
    if not House then return end

    SetNewWaypoint(House.Coords.Entrance.x, House.Coords.Entrance.y)

    cb({})
end)

RegisterNUICallback('RealEstateMode', function(_, cb)
    cb({})

    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    local Job = PlayerData.Job.Name

    if not Config.WhitelistedJobs[Job] then return end

    cache.jobMode = not cache.jobMode

    if cache.jobMode then
        SetupJobBlips()
    else
        RemoveJobBlips()
    end
end)

RegisterNetEvent('mani-housing:client:UpdateHouse', function(House, Action)
    if Action == 'Update' then
        HouseCache[House.HouseId] = House
        CreateHouse(House.HouseId, House)
    elseif Action == 'Remove' then
        if HousePoints[House.HouseId] then
            if HousePoints[House.HouseId]['Entrance'] then
                HousePoints[House.HouseId]['Entrance']:remove()
            end

            if HousePoints[House.HouseId]['Garage'] then
                HousePoints[House.HouseId]['Garage']:remove()
            end

            if HousePoints[House.HouseId]['Blip'] then
                RemoveBlip(HousePoints[House.HouseId]['Blip'])
            end
        end

        HousePoints[House.HouseId] = nil
        HouseCache[House.HouseId] = nil
    end
end)

RegisterNetEvent('mani-housing:client:UpdatePoint', function(Coords, Point)
    local HouseId = cache.inHouse
    if not HouseId then return end

    if InHouse['Points'][Point] then InHouse['Points'][Point]:remove() end

    local IsWardrobe = Point == 'Wardrobe'
    local IsStash = Point == 'Stash'

    InHouse['Points'][Point] = lib.points.new({
        coords = Coords,
        distance = Config.Distances['Interact'],
        nearby = function(self)
            Draw3DText(Coords.x, Coords.y, Coords.z, IsWardrobe and locale('3DText.Wardrobe') or locale('3DText.Stash'))

            if IsControlJustReleased(0, 38) then
                if IsWardrobe then
                    Util.OpenWardrobe()
                elseif IsStash then
                    Util.OpenStash(HouseCache[HouseId])
                end
            end
        end
    })
end)

exports('HasAccess', HasAccess)

exports('GetHouse', function(HouseId) return HouseCache[HouseId] end)

exports('GetHouses', function() return HouseCache end)

exports('GetPlayerHouses', function(ReturnByIndex)
    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return {} end
    local Identifier = PlayerData.Identifier

    local Houses = {}

    for HouseId, House in pairs(HouseCache) do
        if House.Owner == Identifier or House.Keyholders[Identifier] then
            Houses[ReturnByIndex and HouseId or #Houses + 1] = House
        end
    end

    return Houses
end)