Config                            = {}
Config.DrawDistance               = 15
Config.MarkerColor                = { r = 120, g = 120, b = 240 }

Config.Blip = {
	Pos = vector3(-38.72, -1109.82, 26.25),
	Sprite = 326,
	Display = 4,
	Scale = 0.8,
	ShortRange = true,
	Name = 'Car Dealership'
}

Config.Zones = {
	PurchaseVehicle = {
		pos   = vector3(-56.8929, -1096.4774, 25.25),
		size  = { x = 1.75, y = 1.75, z = 0.5 },
		tooltip = 'Press ~INPUT_CONTEXT~ to view the catalog',
		menuType = 'ChooseVehicle',
		type  = 1
	},
	ResellVehicle = {
		pos   = vector3(-34.6992, -1089.2735, 25.3),
		size  = { x = 3.0, y = 3.0, z = 0.5 },
		tooltip = 'Press ~INPUT_CONTEXT~ to sell your vehicle',
		menuType = 'SellVehicle',
		onVehicle = true,
		type  = 1
	},
	BossActions = {
		pos   = vector3(-29.3812, -1103.9708, 25.5),
		size  = { x = 1.5, y = 1.5, z = 0.5 },
		tooltip = 'Press ~INPUT_CONTEXT~ to access the dealership management',
		menuType = 'BossActions',
		type  = 1
	}
}

Config.DisplayVehicles = {
	{
		pos   = vector3(-36.3505, -1102.2270, 26.2579),
		heading = 164.5072,
		model = 'srt8'
	},
	{
		pos   = vector3(-41.1982, -1099.6090, 25.9660),
		heading = 139.9875,
		model = 'e63s'
	},
	{
		pos   = vector3(-46.5228, -1098.0993, 26.2062),
		heading = 117.3469,
		model = 'rsq8m'
	},
	{
		pos   = vector3(-49.9113, -1094.3090, 25.6921),
		heading = 94.0905,
		model = 'm5f10',
		isModel = true
	},
	{
		pos   = vector3(-50.6905, -1116.4816, 25.8934),
		heading = 1.8822,
		model = 'rs62'
	}
}

Config.VehicleExitPos = {
	pos = vector3(-28.2147, -1084.8037, 25.35),
	heading = 357.8681
}
