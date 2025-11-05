local Config = {}

Config.WhitelistedJobs = {
	'realestate'
}

Config.Commands = {
    ['RealEstate'] = 'housing'
}

Config.Shells = {
    {
		Model = 'shell_garagem',
        Label = 'Medium Garage',
		Stash = {
			MaxWeight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'shell_trailer',
        Label = 'Trailer',
		Stash = {
			MaxWeight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'shell_warehouse1',
        Label = 'Warehouse',
		Stash = {
			MaxWeight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'standardmotel_shell',
        Label = 'Standard Motel',
		Stash = {
			MaxWeight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'container_shell',
        Label = 'Container',
		Stash = {
			MaxWeight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'shell_store1',
        Label = 'Store',
		Stash = {
			MaxWeight = 1000000,
			Slots = 100
		}
	},
    {
		Model = 'furnitured_midapart',
        Label = 'Mid Apartment',
		Stash = {
			MaxWeight = 1000000,
			Slots = 100
		}
	},
}

return Config