local Config = lib.load('config')

local HouseCache = lib.callback.await('mani-housing:server:GetHouses', false)
local Util = lib.load('open.cl_open')
local HousePoints, GarageTick = {}, nil

local InHouse = { ShellModel = nil, Models = {}, Points = {} }

local JobCache = {}

lib.locale()

---@param HouseId number
---@param Identifier string
---@param Key string
---@return boolean
local function HasAccess(HouseId, Identifier, Key)
    local House = type(HouseId) == 'table' and HouseId or HouseCache[HouseId]
    if not House then return false end

    local IsOwner = House.Owner == Identifier
    local HasKey = House.Keyholders[Identifier] and House.Keyholders[Identifier].Permissions[Key or 'Enter']

    return IsOwner or HasKey
end

---@param x number
---@param y number
---@param z number
---@param text string
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

---@param Data table
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

local function RemoveProps()
    for i = 1, #InHouse['Models'] do
        DeleteEntity(InHouse['Models'][i])
    end

    InHouse['Models'] = {}
end

local function SpawnProps(Props)
    for i = 1, #Props do
        local Decor = Props[i]
        local ModelHash = Decor.Model

        lib.requestModel(ModelHash)

        local DecorObj = CreateObjectNoOffset(ModelHash, Decor.Position.x, Decor.Position.y, Decor.Position.z, false, false, false)
        SetEntityRotation(DecorObj, Decor.Rotation.x, Decor.Rotation.y, Decor.Rotation.z, 2, true)
        FreezeEntityPosition(DecorObj, true)

        SetModelAsNoLongerNeeded(ModelHash)

        InHouse['Models'][#InHouse['Models'] + 1] = DecorObj
    end
end

---@param House table
local function ExitHouse(House)
    if not cache.InHouse then return end
    cache.InHouse = nil

    lib.callback.await('mani-housing:server:ExitHouse', false, House.HouseId)

    local PlayerPed = cache.ped
    local EntranceCoords = vec4(House.Coords.Entrance.x, House.Coords.Entrance.y, House.Coords.Entrance.z, House.Coords.Entrance.w - 180)
    
    DoScreenFadeOut(500)
    Wait(500)

    exports['mani-bridge']:TeleportEntity(PlayerPed, EntranceCoords)

    CreateThread(function()
        DeleteEntity(InHouse['ShellModel'])

        RemoveProps()

        InHouse['Points']['Exit']:remove()
        if InHouse['Points']['Wardrobe'] then InHouse['Points']['Wardrobe']:remove() end
        if InHouse['Points']['Stash'] then InHouse['Points']['Stash']:remove() end

        InHouse['Points'] = {}
    end)

    if cache.Decorating then
        SendNUIMessage({ action = 'HideUi' })
        cache.Decorating = false
    end

    Wait(500)
    DoScreenFadeIn(500)
end

---@param Data table
local function EnterHouse(Data)
    if cache.InHouse then return end

    local PlayerPed = cache.ped

    local HouseCoords = Data.HouseCoords
    local House = Data.House

    if not HasAccess(House, Data.Identifier, 'Enter') then return end

    local ShellIndex = Config.ShellIndexes[House.Shell]
    if not ShellIndex then lib.print.error("Your shell doesn't exist - Contact support") return end
    local Shell = Config.Shells[ShellIndex]

    cache.InHouse = Data.HouseIndex

    lib.callback.await('mani-housing:server:EnterHouse', false, Data.HouseIndex)

    local ShellCoords = vec3(HouseCoords.x, HouseCoords.y, HouseCoords.z + Config.ZOffset)

    local ShellModel = GetHashKey(Shell.Model)

    lib.requestModel(ShellModel)

    DoScreenFadeOut(500)
    Wait(500)

    local ShellProp = CreateObjectNoOffset(ShellModel, ShellCoords, false, false, false)
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

    SpawnProps(House.Decor)

    Wait(500)
    DoScreenFadeIn(500)

    SetModelAsNoLongerNeeded(ShellModel)
end

---@param HouseId number
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

---@param HouseIndex number
---@param House table
---@param PlayerData table
local function CreateHouse(HouseIndex, House, PlayerData)
    cache.CurrentHouse = nil

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
            local PlayerCoords = GetEntityCoords(self.PlayerPed)
            local Distance = #(PlayerCoords - HouseCoords)

            self.Estate = House.State == 0 and self.PlayerData.Identifier ~= House.Owner

            if not self.Estate then
                if not HasAccess(House, self.PlayerData.Identifier, 'Enter') then return end

                if cache.CurrentHouse then
                    local CurrentHouseCoords = HouseCache[cache.CurrentHouse].Coords.Entrance

                    if Distance > #(PlayerCoords - vec3(CurrentHouseCoords.x, CurrentHouseCoords.y, CurrentHouseCoords.z)) then return end
                end
                
                Util.InDistance(House)
                
                cache.CurrentHouse = HouseIndex
            end
        end,
        nearby = function(self)
            if not self.Estate and cache.CurrentHouse ~= HouseIndex then return end

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
                            House = House,
                            Identifier = self.PlayerData.Identifier
                        })
                    end
                end
            end
        end,
        onExit = function(self)
            if cache.CurrentHouse == HouseIndex then cache.CurrentHouse = nil end
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

                self.HasAcess = HasAccess(House, PlayerData.Identifier, 'Garage')
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
                            data = {
                                House = House,
                                Houses = HouseCache
                            }
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

---@param PlayerData table
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
    local HouseIndex = cache.CurrentHouse or cache.InHouse
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
    local HouseId = cache.CurrentHouse or cache.InHouse
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
    elseif Action == 'UpdateDecoration' then
        HouseCache[House.HouseId] = House

        if cache.InHouse == House.HouseId then
            RemoveProps()
            SpawnProps(House.Decor)

            if cache.Decorating then
                SendNUIMessage({
                    action = 'UpdateDecorations',
                    data = House.Decor
                })
            end
        end
    end
end)

RegisterNetEvent('mani-housing:client:UpdatePoint', function(Coords, Point)
    local HouseId = cache.InHouse
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

---@param HouseId number
---@return table
exports('GetHouse', function(HouseId) return HouseCache[HouseId] end)

---@return table
exports('GetHouses', function() return HouseCache end)

---@param ReturnByIndex boolean
---@return table
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




-- Decoration Editing --




local Keybinds, Editing = {}, { Prop = nil, Cursor = false, Mode = 'translate', Relative = false, Snap = { Active = false, Angle = 15.0, GridSize = 0.5 } }

local dataview = lib.load('open.dataview')

local function MakeEntityMatrix(entity)
    local f, r, u, a = GetEntityMatrix(entity)
    local view = dataview.ArrayBuffer(60)

    view:SetFloat32(0, r[1])
        :SetFloat32(4, r[2])
        :SetFloat32(8, r[3])
        :SetFloat32(12, 0)
        :SetFloat32(16, f[1])
        :SetFloat32(20, f[2])
        :SetFloat32(24, f[3])
        :SetFloat32(28, 0)
        :SetFloat32(32, u[1])
        :SetFloat32(36, u[2])
        :SetFloat32(40, u[3])
        :SetFloat32(44, 0)
        :SetFloat32(48, a[1])
        :SetFloat32(52, a[2])
        :SetFloat32(56, a[3])
        :SetFloat32(60, 1)

    return view
end

local function ApplyEntityMatrix(entity, view)
    local x1, y1, z1 = view:GetFloat32(16), view:GetFloat32(20), view:GetFloat32(24)
    local x2, y2, z2 = view:GetFloat32(0), view:GetFloat32(4), view:GetFloat32(8)
    local x3, y3, z3 = view:GetFloat32(32), view:GetFloat32(36), view:GetFloat32(40)
    local tx, ty, tz = view:GetFloat32(48), view:GetFloat32(52), view:GetFloat32(56)

    SetEntityMatrix(entity,
        x1, y1, z1,
        x2, y2, z2,
        x3, y3, z3,
        tx, ty, tz
    )
end

local function UseGizmo()
    if not Editing['Prop'] then return LeaveCursorMode() end
    local Entity = Editing['Prop']
    if not Entity or not DoesEntityExist(Entity) then return LeaveCursorMode() end

    EnterCursorMode()
    Editing['Cursor'] = true

    SetCursorLocation(0.5, 0.5)

    SetEntityDrawOutline(Entity, true)
    SetEntityDrawOutlineColor(Entity, 255, 255, 0, 255)

    while Editing['Prop'] == Entity and DoesEntityExist(Entity) do
        DisableControlAction(0, 24, true)  -- lmb
        DisableControlAction(0, 25, true)  -- rmb
        DisableControlAction(0, 140, true) -- r
        DisablePlayerFiring(cache.playerId, true)

        SetEntityCollision(Entity, false, true)

        local matrixBuffer = MakeEntityMatrix(Entity)
        local changed = DrawGizmo(matrixBuffer:Buffer(), 'Editor2', Citizen.ReturnResultAnyway())

        if changed then
            ApplyEntityMatrix(Entity, matrixBuffer)
            if Editing['Snap'].Active then
                local Pos = GetEntityCoords(Entity)
                local GridSize = Editing['Snap'].GridSize
                local SnappedX = (math.floor((Pos.x / GridSize) + 0.5)) * GridSize
                local SnappedY = (math.floor((Pos.y / GridSize) + 0.5)) * GridSize
                local SnappedZ = (math.floor((Pos.z / GridSize) + 0.5)) * GridSize
                SetEntityCoordsNoOffset(Entity, SnappedX, SnappedY, SnappedZ, true, true, true)

                local Rot = GetEntityRotation(Entity, 2)
                local SnapAngle = Editing['Snap'].Angle
                local SnappedRotX = (math.floor((Rot.x / SnapAngle) + 0.5)) * SnapAngle
                local snappedRotY = (math.floor((Rot.y / SnapAngle) + 0.5)) * SnapAngle
                local snappedRotZ = (math.floor((Rot.z / SnapAngle) + 0.5)) * SnapAngle
                SetEntityRotation(Entity, SnappedRotX, snappedRotY, snappedRotZ, 2, true)
            end
        end

        Wait(0)
    end

    local Data = {
        Position = GetEntityCoords(Entity),
        Rotation = GetEntityRotation(Entity, 2)
    }

    SetTimeout(500, function()
        DeleteEntity(Entity)
    end)

    return Data
end

local function ToggleKeybinds(Toggle)
    for i = 1, #Keybinds do
        local Keybind = Keybinds[i]
        Keybind:disable(Toggle)
    end
end

local function RemoveEdit()
    local TempData = Editing
    Editing = { Prop = nil, Cursor = false, Mode = 'translate', Relative = false, Snap = { Active = false, Angle = 15.0, GridSize = 0.5 } }
    
    if TempData['Cursor'] then LeaveCursorMode() end
end

local function ToggleFocus()
    if Editing['Prop'] then
        if Editing['Cursor'] then
            LeaveCursorMode()
        else
            EnterCursorMode()
            SetCursorLocation(0.5, 0.5)
        end
        Editing['Cursor'] = not Editing['Cursor']
    else
        local Focus = not IsNuiFocused()

        SetNuiFocus(Focus, Focus)
    end
end

RegisterNUICallback('StartDecorating', function(_, cb)
    if not cache.InHouse then cb({ Success = false }) return end
    local House = HouseCache[cache.InHouse]
    if not House then cb({ Success = false }) return end

    ToggleKeybinds(false)

    cache.Decorating = true

    cb({
        Success = true,
        Decorations = House.Decor
    })
end)

RegisterNUICallback('StopDecorating', function(_, cb)
    SetNuiFocus(false, false)

    RemoveEdit()

    ToggleKeybinds(true)

    cache.Decorating = false

    if cache.SelectedProp then
        local Props = InHouse['Models']
        local OldProp = Props[cache.SelectedProp]
        if DoesEntityExist(OldProp) then
            SetEntityDrawOutline(OldProp, false)
        end
    end
    cache.SelectedProp = nil

    cb({})
end)

RegisterNUICallback('PlaceFurniture', function(Data, cb)
    local PlayerPed = cache.ped

    local HouseId = cache.InHouse
    if not HouseId then return end

    RemoveEdit()

    SetNuiFocus(false, false)

    local ModelHash = GetHashKey(Data.Model)

    lib.requestModel(ModelHash)

    local StartOffset = GetEntityCoords(PlayerPed) + GetEntityForwardVector(PlayerPed) * 2

    Editing['Prop'] = CreateObjectNoOffset(ModelHash, StartOffset.x, StartOffset.y, StartOffset.z, false, false, false)

    SetModelAsNoLongerNeeded(ModelHash)
    
    local GizmoData = UseGizmo()

    SetNuiFocus(true, true)

    local Success, Message = lib.callback.await('mani-housing:server:UploadDecoration', false, {
        HouseId = HouseId,
        Model = ModelHash,
        Label = Data.Label,
        Price = Data.Price,
        Position = GizmoData.Position,
        Rotation = GizmoData.Rotation
    })

    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    cb(true)
end)

RegisterNUICallback('SelectProp', function(PropIndex, cb)
    local HouseId = cache.InHouse
    if not HouseId then return end

    local Props = InHouse['Models']
    local Prop = Props[PropIndex]
    if not Prop then return end

    if cache.SelectedProp then
        local OldProp = Props[cache.SelectedProp]
        if DoesEntityExist(OldProp) then
            SetEntityDrawOutline(OldProp, false)
        end
    end

    cache.SelectedProp = PropIndex

    SetEntityDrawOutline(Prop, true)
    SetEntityDrawOutlineColor(Prop, 255, 255, 0, 255)

    cb({})
end)

RegisterNUICallback('EditProp', function(PropIndex, cb)
    local HouseId = cache.InHouse
    if not HouseId then return end

    local Props = InHouse['Models']
    local Prop = Props[PropIndex]
    if not Prop then return end

    RemoveEdit()

    SetNuiFocus(false, false)

    Editing['Prop'] = Prop

    local GizmoData = UseGizmo()

    SetNuiFocus(true, true)

    local Success, Message = lib.callback.await('mani-housing:server:EditDecoration', false, {
        HouseId = HouseId,
        DecorIndex = PropIndex,
        Position = GizmoData.Position,
        Rotation = GizmoData.Rotation
    })

    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    cb({})
end)

RegisterNUICallback('DuplicateProp', function(PropIndex, cb)
    local HouseId = cache.InHouse
    if not HouseId then return end

    local House = HouseCache[HouseId]
    if not House then return end

    local Props = InHouse['Models']
    local Prop = Props[PropIndex]
    if not Prop then return end

    local PropData = House.Decor[PropIndex]
    if not PropData then return end

    RemoveEdit()

    SetNuiFocus(false, false)

    local ModelHash = PropData.Model

    lib.requestModel(ModelHash)

    local StartPosition = PropData.Position

    Editing['Prop'] = CreateObjectNoOffset(ModelHash, StartPosition.x, StartPosition.y, StartPosition.z, false, false, false)
    SetEntityRotation(Editing['Prop'], PropData.Rotation.x, PropData.Rotation.y, PropData.Rotation.z, 2, true)

    SetModelAsNoLongerNeeded(ModelHash)
    
    local GizmoData = UseGizmo()

    local Success, Message = lib.callback.await('mani-housing:server:UploadDecoration', false, {
        HouseId = HouseId,
        Model = ModelHash,
        Label = PropData.Label,
        Price = PropData.Price,
        Position = GizmoData.Position,
        Rotation = GizmoData.Rotation
    })

    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    SetNuiFocus(true, true)

    cb({})
end)

RegisterNUICallback('SellProp', function(PropIndex, cb)
    local HouseId = cache.InHouse
    if not HouseId then return end

    local Props = InHouse['Models']
    local Prop = Props[PropIndex]
    if not Prop then return end

    local Success, Message = lib.callback.await('mani-housing:server:SellDecoration', false, {
        HouseId = HouseId,
        DecorIndex = PropIndex,
    })

    if not Success then exports['mani-bridge']:Notify(locale('Notify.Error'), Message, 'error', 5000) end

    cb({})
end)

RegisterNUICallback('ToggleFocus', function(_, cb)
    ToggleFocus()

    cb({})
end)

CreateThread(function()
    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateFocus',
        description = 'Press Right MouseButton to Toggle Focus While Decorating',
        defaultMapper = 'MOUSE_BUTTON',
        defaultKey = 'MOUSE_RIGHT',
        disabled = true,
        onPressed = ToggleFocus
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateRotation',
        description = 'Sets mode for the gizmo to rotation',
        defaultKey = 'R',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Mode'] = 'Rotate'
            ExecuteCommand('+gizmoRotation')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoRotation')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSnap',
        description = 'Hold to snap decoration object',
        defaultKey = 'LSHIFT',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Snap'].Active = true
        end,
        onReleased = function (self)
            if not Editing['Prop'] then return end
            Editing['Snap'].Active = false
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSnapIncrease',
        description = 'Increase snapping size',
        defaultKey = 'Up',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Snap'].Angle = Editing['Snap'].Angle + 5.0
            Editing['Snap'].GridSize = Editing['Snap'].GridSize + 0.1
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSnapDecrease',
        description = 'Decrease snapping size',
        defaultKey = 'Down',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Snap'].Angle = Editing['Snap'].Angle - 5.0
            Editing['Snap'].GridSize = Editing['Snap'].GridSize - 0.1
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSelect',
        description = 'Selects the currently highlighted gizmo',
        defaultMapper = 'MOUSE_BUTTON',
        defaultKey = 'MOUSE_LEFT',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            ExecuteCommand('+gizmoSelect')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoSelect')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateTranslation',
        description = 'Sets mode of the gizmo to translation',
        defaultKey = 'W',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Mode'] = 'Translate'
            ExecuteCommand('+gizmoTranslation')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoTranslation')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateLocal',
        description = 'Toggle gizmo to be local to the entity instead of world',
        defaultKey = 'Q',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Relative'] = not Editing['Relative']
            ExecuteCommand('+gizmoLocal')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoLocal')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateConfirm',
        description = 'Confirm Gizmo',
        defaultKey = 'RETURN',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            RemoveEdit()
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSnapToGround',
        description = 'snap current gizmo object to floor/surface',
        defaultKey = 'LMENU',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            PlaceObjectOnGroundProperly_2(Editing['Prop'])
        end
    })
end)