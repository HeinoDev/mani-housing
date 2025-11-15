local Config = {}

Config.Debug = true

Config.WhitelistedJobs = {
	'realestate'
}

Config.Commands = {
    ['RealEstate'] = 'housing',
	['HouseInteraction'] = 'house'
}

Config.Distances = {
	['Main'] = 7.5, -- When the player can use house interactions.
	['Interact'] = 0.75 -- When the player can enter and use the garage.
}

Config.ZOffset = 1000 -- How high the player should be when they enter the house. (Set to -Number if you want to lower the player)

Config.Shells = {
    {
		Model = 'shell_garagem',
        Label = 'Medium Garage',
		Stash = {
			Weight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'shell_trailer',
        Label = 'Trailer',
		Stash = {
			Weight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'shell_warehouse1',
        Label = 'Warehouse',
		Stash = {
			Weight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'standardmotel_shell',
        Label = 'Standard Motel',
		Stash = {
			Weight = 1000000,
			Slots = 100
		},
		Offsets = {
			Exit = vec4(-0.25, -2.47, 0.56, 267.65)
		}
	},
    {
		Model = 'container_shell',
        Label = 'Container',
		Stash = {
			Weight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'shell_store1',
        Label = 'Store',
		Stash = {
			Weight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'furnitured_midapart',
        Label = 'Mid Apartment',
		Stash = {
			Weight = 1000000,
			Slots = 100
		}
	},
}

return Config