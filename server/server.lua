local Config = lib.load('config')

local HouseCache, KeyholderCache, PlayerCache = {}, {}, {}

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
        Keyholders = {}
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

    local WhitelistedJobs = Config.WhitelistedJobs
    Config.WhitelistedJobs = {}

    for _, Job in ipairs(WhitelistedJobs) do
        Config.WhitelistedJobs[Job] = true
    end
end)

lib.callback.register('mani-housing:server:GetHouses', function() return HouseCache end)

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
            SalesmanJob = PlayerData.Job.label
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

function HouseClass:AddKeyholder(Source, Permissions)
    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return end

    self.Keyholders[PlayerData.Identifier] = {
        Character = PlayerData.Character.Fullname,
        Permissions = Permissions
    }

    PlayerCache[PlayerData.Identifier] = PlayerCache[PlayerData.Identifier] or {}
    PlayerCache[PlayerData.Identifier].Keys = PlayerCache[PlayerData.Identifier].Keys or {}

    PlayerCache[PlayerData.Identifier].Keys[self.HouseId] = Permissions

    MySQL.Async.execute('REPLACE INTO `mani_housekeys` (`identifier`, `keys`) VALUES (@identifier, @metadata)', {
        ['@identifier'] = PlayerData.Identifier,
        ['@metadata'] = json.encode(PlayerCache[PlayerData.Identifier].Keys),
    })

    TriggerClientEvent('mani-housing:client:UpdateHouse', -1, self, 'Update')
end

-- House:AddKeyholder(Source, {
--     Enter = true,
--     Garage = false
-- })