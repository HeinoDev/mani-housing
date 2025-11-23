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
            Model = 'prop_wall1_2',
            Label = 'Dusty Wall 2',
            Price = 100,
        },
        {
            Model = 'prop_wall2_2',
            Label = 'Modern Wall 2',
            Price = 100,
        },
        {
            Model = 'prop_wall1_3',
            Label = 'Dusty Wall 3',
            Price = 100,
        },
        {
            Model = 'prop_wall2_3',
            Label = 'Modern Wall 3',
            Price = 100,
        },
        {
            Model = 'prop_wall1_4',
            Label = 'Dusty Wall 4',
            Price = 100,
        },
        {
            Model = 'prop_wall2_4',
            Label = 'Modern Wall 4',
            Price = 100,
        },
        {
            Model = 'prop_wall1_5',
            Label = 'Dusty Wall 5',
            Price = 100,
        },
        {
            Model = 'prop_wall2_5',
            Label = 'Modern Wall 5',
            Price = 100,
        },
        {
            Model = 'prop_wall1_6',
            Label = 'Dusty Wall 6',
            Price = 100,
        },
        {
            Model = 'prop_wall2_6',
            Label = 'Modern Wall 6',
            Price = 100,
        },
        {
            Model = 'prop_wall1_7',
            Label = 'Dusty Wall 7',
            Price = 100,
        },
        {
            Model = 'prop_wall2_7',
            Label = 'Modern Wall 7',
            Price = 100,
        },
        {
            Model = 'prop_wall1_8',
            Label = 'Dusty Wall 8',
            Price = 100,
        },
        {
            Model = 'prop_wall2_8',
            Label = 'Modern Wall 8',
            Price = 100,
        },
        {
            Model = 'prop_wall1_9',
            Label = 'Dusty Wall 9',
            Price = 100,
        },
        {
            Model = 'prop_wall2_9',
            Label = 'Modern Wall 9',
            Price = 100,
        },
        {
            Model = 'prop_wall1_10',
            Label = 'Dusty Wall 10',
            Price = 100,
        },
        {
            Model = 'prop_wall2_10',
            Label = 'Modern Wall 10',
            Price = 100,
        },
        {
            Model = 'prop_wall1_11',
            Label = 'Dusty Wall 11',
            Price = 100,
        },
        {
            Model = 'prop_wall2_11',
            Label = 'Modern Wall 11',
            Price = 100,
        },
        {
            Model = 'prop_wall1_12',
            Label = 'Dusty Wall 12',
            Price = 100,
        },
        {
            Model = 'prop_wall2_12',
            Label = 'Modern Wall 12',
            Price = 100,
        },
        {
            Model = 'prop_wall2_13',
            Label = 'Modern Wall 13',
            Price = 100,
        },
        {
            Model = 'prop_wall1_13',
            Label = 'Dusty Wall 13',
            Price = 100,
        },
        {
            Model = 'prop_wall2_14',
            Label = 'Modern Wall 14',
            Price = 100,
        },
        {
            Model = 'prop_wall1_14',
            Label = 'Dusty Wall 14',
            Price = 100,
        },
        {
            Model = 'prop_wall2_15',
            Label = 'Modern Wall 15',
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
        },

    }
}

return Config