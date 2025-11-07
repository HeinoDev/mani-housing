local Config, HouseClass = lib.load('config'), lib.load('server.class.house')

local HouseCache = {}

lib.locale()

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
                INDEX `identifier` (`identifier`) USING BTREE
            )
            COLLATE='utf8mb4_0900_ai_ci'
            ENGINE=InnoDB;
        ]])

        Keyholders = {}
    end

    for i = 1, #Houses do
        local House = Houses[i]
        
        HouseCache[House.houseid] = setmetatable({
            HouseId = House.houseid,
            Owner = House.owner,
            Coords = json.decode(House.coords),
            Shell = House.shell,
            Decor = json.decode(House.decor),
            SalesData = json.decode(House.salesdata),
            State = House.state,
            Keyholders = {}
        }, HouseClass)
    end

    for i = 1, #Keyholders do
        local Keyholder = Keyholders[i]
        local Keys = json.decode(Keyholder.keys)

        for HouseId, Data in pairs(Keys) do
            HouseCache[HouseId].Keyholders[Keyholder.identifier] = Data
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

    local House = HouseClass:new({
        Owner = '',
        Coords = HouseData.Coords,
        Decor = {},
        SalesData = HouseData.SalesData,
        State = 0,
    })

    HouseCache[HouseId] = House

    TriggerClientEvent('mani-housing:client:UpdateHouses', -1, HouseCache)

    return HouseId
end)