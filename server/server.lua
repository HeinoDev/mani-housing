local Config, Util = lib.load('config'), lib.load('open.sv_open')

local HouseCache, PlayerCache, Initialized = {}, {}, false

local HouseClass = {}
HouseClass.__index = HouseClass

lib.locale()

function HouseClass:New(Data)
    return setmetatable({
        HouseId = Data.HouseId,
        Owner = Data.Owner,
        Coords = Data.Coords,
        Shell = Data.Shell,
        Decor = Data.Decor,
        SalesData = Data.SalesData,
        State = Data.State,
        Keyholders = {},
        Inside = {}
    }, self)
end

CreateThread(function()
    local HouseSuccess, Houses = pcall(function() return MySQL.query.await('SELECT * FROM `mani_houses`') end)
    if not HouseSuccess then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `mani_houses` (
                `houseid` INT(11) NOT NULL AUTO_INCREMENT,
                `owner` VARCHAR(60) NULL DEFAULT '' COLLATE 'utf8mb4_0900_ai_ci',
                `coords` LONGTEXT NOT NULL DEFAULT '[]' COLLATE 'utf8mb4_0900_ai_ci',
                `shell` VARCHAR(25) NULL DEFAULT '' COLLATE 'utf8mb4_0900_ai_ci',
                `decor` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_0900_ai_ci',
                `salesdata` LONGTEXT NOT NULL DEFAULT '[]' COLLATE 'utf8mb4_0900_ai_ci',
                `state` INT(1) NOT NULL DEFAULT '0',
                INDEX `houseid` (`houseid`) USING BTREE
            )
            COLLATE='utf8mb4_0900_ai_ci'
            ENGINE=InnoDB;
        ]])

        Houses = {}
    end

    local KeySuccess, Keyholders = pcall(function() return MySQL.query.await('SELECT * FROM `mani_housekeys`') end)
    if not KeySuccess then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `mani_housekeys` (
                `identifier` VARCHAR(60) NOT NULL DEFAULT '' COLLATE 'utf8mb4_0900_ai_ci',
                `keys` LONGTEXT NOT NULL DEFAULT '[]' COLLATE 'utf8mb4_0900_ai_ci',
                `character` VARCHAR(60) NULL DEFAULT '' COLLATE 'utf8mb4_0900_ai_ci',
                UNIQUE INDEX `identifier` (`identifier`) USING BTREE,
                CONSTRAINT `keys` CHECK (json_valid(`keys`))
            )
            COLLATE='utf8mb4_0900_ai_ci'
            ENGINE=InnoDB;
        ]])

        Keyholders = {}
    end

    for i = 1, #Houses do
        local House = Houses[i]

        HouseCache[House.houseid] = HouseClass:New({
            HouseId = House.houseid,
            Owner = House.owner,
            Coords = json.decode(House.coords),
            Shell = House.shell,
            Decor = json.decode(House.decor),
            SalesData = json.decode(House.salesdata),
            State = House.state,
            Keyholders = {}
        })
    end

    for i = 1, #Keyholders do
        local Keyholder = Keyholders[i]
        local Keys = json.decode(Keyholder.keys)

        PlayerCache[Keyholder.identifier] = PlayerCache[Keyholder.identifier] or {}
        PlayerCache[Keyholder.identifier].Keys = PlayerCache[Keyholder.identifier].Keys or {}

        for HouseId, Data in pairs(Keys) do
            PlayerCache[Keyholder.identifier].Keys[HouseId] = Data
            HouseCache[HouseId].Keyholders[Keyholder.identifier] = {
                Character = Keyholder.character,
                Permissions = Data
            }
        end
    end

    lib.print.info(('[Mani-Housing] Loaded %s Houses'):format(#Houses))

    Initialized = true

    local WhitelistedJobs = Config.WhitelistedJobs
    Config.WhitelistedJobs = {}

    for _, Job in ipairs(WhitelistedJobs) do
        Config.WhitelistedJobs[Job] = true
    end
end)

lib.callback.register('mani-housing:server:GetHouses', function()
    while not Initialized do Wait(100) end
    return HouseCache
end)

lib.callback.register('mani-housing:server:GetNearbyPlayers', function(Source, Coords, HouseId)
    local Players = lib.getNearbyPlayers(Coords, 7.5)
    local PlayerTable = {}

    local House = HouseCache[HouseId]
    if not House then return {} end

    for i = 1, #Players do
        local Player = Players[i]
        if Config.Debug or Player.id ~= Source then
            local PlayerData = exports['mani-bridge']:GetPlayerData(Player.id)
            if not House.Keyholders[PlayerData.Identifier] then
                PlayerTable[#PlayerTable + 1] = {
                    Name = PlayerData.Character.Fullname,
                    Source = Player.id
                }
            end
        end
    end

    return PlayerTable
end)

lib.callback.register('mani-housing:server:GiveKeys', function(Source, Players, HouseId)
    local House = HouseCache[HouseId]
    if not House then return false, 'no house exist' end

    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return false, 'something wrong' end

    if not House:HasAccess(PlayerData.Identifier, 'Admin') then return false, 'no access' end

    for i = 1, #Players do
        local PlayerSource = Players[i]
        House:AddKeyholder(PlayerSource, {
            Enter = true,
            Garage = false,
            Admin = false
        })
    end

    return true
end)

lib.callback.register('mani-housing:server:UpdatePermissions', function(Source, Data)
    local House = HouseCache[Data.HouseId]
    if not House then return false, 'no house exist' end

    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return end

    if not House:HasAccess(PlayerData.Identifier, 'Admin') then return false, 'no access' end

    House:UpdatePermissions(Data.Identifier, Data.Permissions)

    return true
end)

lib.callback.register('mani-housing:server:RemoveKeyholder', function(Source, Data)
    local House = HouseCache[Data.HouseId]
    if not House then return false, 'no house exist' end

    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return false, 'no playerdata' end

    if not House:HasAccess(PlayerData.Identifier, 'Admin') then return false, 'no access' end

    House:RemoveKeyholder(Data.Identifier)

    return true
end)

lib.callback.register('mani-housing:server:CreateHouse', function(Source, Data)
    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)

    -- if not Config.WhitelistedJobs[PlayerData.Job.name] then return false, 'Error No ablo job' end

    local HouseData = {
        Coords = {
            Entrance = Data.Entrance,
            Garage = Data.Garage,
            Zone = Data.Zone
        },
        SalesData = {
            Price = Data.Price,
            Salesman = PlayerData.Character.Fullname,
            SalesmanIdentifier = PlayerData.Identifier,
            SalesmanJob = PlayerData.Job.name,
            SalesmanJobLabel = PlayerData.Job.label
            
        }
    }

    local HouseId = MySQL.insert.await('INSERT INTO `mani_houses` (`coords`, `salesdata`, `shell`) VALUES (?, ?, ?)', {
        json.encode(HouseData.Coords),
        json.encode(HouseData.SalesData),
        Data.Shell
    })

    if not HouseId then return false, 'ewow id no work' end

    local House = HouseClass:New({
        HouseId = HouseId,
        Owner = '',
        Coords = HouseData.Coords,
        Shell = Data.Shell,
        Decor = {},
        SalesData = HouseData.SalesData,
        State = 0,
        Keyholders = {}
    })

    HouseCache[HouseId] = House

    TriggerClientEvent('mani-housing:client:UpdateHouse', -1, House, 'Update')

    return HouseId
end)

lib.callback.register('mani-housing:server:PurchaseHouse', function(Source, HouseId)
    local House = HouseCache[HouseId]
    if not House then return end

    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return end

    if not House.State == 0 then return end

    local SalesData = House.SalesData
    local SellerJob = SalesData.SalesmanJob
    local Price = SalesData.Price

    if not exports['mani-bridge']:RemoveMoneyAuto(Source, { 'money', 'bank' }, Price) then return false, 'no hablo money' end

    Util.AddMoneyForJob(SellerJob, Price)

    House:SetOwner(PlayerData.Identifier)
end)

lib.callback.register('mani-housing:server:PlaceWardrobe', function(Source, Data)
    local House = HouseCache[Data.HouseId]
    if not House then return end

    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return end

    if not House:HasAccess(PlayerData.Identifier, 'Admin') then return false, 'no access' end

    House:PlaceWardrobe(Data.PlayerCoords)
end)

lib.callback.register('mani-housing:server:EnterHouse', function(Source, HouseId)
    if not HouseCache[HouseId] then return end

    HouseCache[HouseId].Inside[Source] = true
end)

lib.callback.register('mani-housing:server:ExitHouse', function(Source, HouseId)
    if not HouseCache[HouseId] then return end

    HouseCache[HouseId].Inside[Source] = false
end)

function HouseClass:AddKeyholder(Source, Permissions)
    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return end

    if PlayerData.Identifier == self.Owner then return end
    if self.Keyholders[PlayerData.Identifier] then return end

    self.Keyholders[PlayerData.Identifier] = {
        Character = PlayerData.Character.Fullname,
        Permissions = Permissions
    }

    PlayerCache[PlayerData.Identifier] = PlayerCache[PlayerData.Identifier] or {}
    PlayerCache[PlayerData.Identifier].Keys = PlayerCache[PlayerData.Identifier].Keys or {}

    PlayerCache[PlayerData.Identifier].Keys[self.HouseId] = Permissions

    MySQL.Async.execute('REPLACE INTO `mani_housekeys` (`identifier`, `keys`, `character`) VALUES (@identifier, @metadata, @character)', {
        ['@identifier'] = PlayerData.Identifier,
        ['@metadata'] = json.encode(PlayerCache[PlayerData.Identifier].Keys),
        ['@character'] = PlayerData.Character.Fullname
    })

    TriggerClientEvent('mani-housing:client:UpdateHouse', -1, self, 'Update')
end

function HouseClass:UpdatePermissions(Identifier, Permissions)
    if not self.Keyholders[Identifier] then return end
    self.Keyholders[Identifier].Permissions = Permissions

    PlayerCache[Identifier] = PlayerCache[Identifier] or {}
    PlayerCache[Identifier].Keys = PlayerCache[Identifier].Keys or {}

    PlayerCache[Identifier].Keys[self.HouseId] = Permissions

    MySQL.Async.execute('REPLACE INTO `mani_housekeys` (`identifier`, `keys`, `character`) VALUES (@identifier, @metadata, @character)', {
        ['@identifier'] = Identifier,
        ['@metadata'] = json.encode(PlayerCache[Identifier].Keys),
        ['@character'] = PlayerCache[Identifier].Character
    })

    TriggerClientEvent('mani-housing:client:UpdateHouse', -1, self, 'Update')
end

function HouseClass:RemoveKeyholder(Identifier)
    if not self.Keyholders[Identifier] then return end
    self.Keyholders[Identifier] = nil

    PlayerCache[Identifier] = PlayerCache[Identifier] or {}
    PlayerCache[Identifier].Keys = PlayerCache[Identifier].Keys or {}

    PlayerCache[Identifier].Keys[self.HouseId] = nil

    MySQL.Async.execute('REPLACE INTO `mani_housekeys` (`identifier`, `keys`, `character`) VALUES (@identifier, @metadata, @character)', {
        ['@identifier'] = Identifier,
        ['@metadata'] = json.encode(PlayerCache[Identifier].Keys),
        ['@character'] = PlayerCache[Identifier].Character
    })

    TriggerClientEvent('mani-housing:client:UpdateHouse', -1, self, 'Update')
end

function HouseClass:HasAccess(Identifier, Key)
    local IsOwner = self.Owner == Identifier
    local HasKey = self.Keyholders[Identifier] and self.Keyholders[Identifier].Permissions[Key or 'Enter']

    return IsOwner or HasKey
end

function HouseClass:SetOwner(Identifier)
    self.Owner = Identifier
    self.State = 1

    MySQL.update.await('UPDATE mani_houses SET owner = ?, state = 1 WHERE houseid = ?', {
        Identifier, self.HouseId
    })

    TriggerClientEvent('mani-housing:client:UpdateHouse', -1, self, 'Update')
end

function HouseClass:PlaceWardrobe(Coords)
    self.Coords.Wardrobe = Coords

    MySQL.update.await('UPDATE mani_houses SET coords = ? WHERE houseid = ?', {
        json.encode(self.Coords), self.HouseId
    })

    TriggerClientEvent('mani-housing:client:UpdateHouse', -1, self, 'Update')

    self:RunAction(function(HouseSource)
        TriggerClientEvent('mani-housing:client:UpdatePoint', HouseSource, self.Coords.Wardrobe, 'Wardrobe')
    end)
end

function HouseClass:RunAction(Action)
    for Source, State in pairs(self.Inside) do
        if State then Action(Source) end
    end
end