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
	['Interact'] = 0.75 -- When the player can enter and interact with interactions.
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

Config.FreeFurnitue = true

Config.Furniture = {
	['Walls'] = {
		{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
				{
			Model = 'prop_wall1',
			Label = 'Dusty Wall',
			Price = 100,
		},
		{
			Model = 'prop_wall2',
			Label = 'Modern Wall',
			Price = 100,
		},
	},
	['Doors'] = {
		{
			Model = 'prop_door',
			Label = 'Dusty Door',
			Price = 100,
		},
		{
			Model = 'prop_door2',
			Label = 'Modern Door',
			Price = 100,
		}
	}
}

return Config