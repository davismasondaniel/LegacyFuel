Config = {}

-- 'none' = free (no framework needed), 'qbcore' = qb-core cash, 'qbox' = qbx_core cash.
Config.Framework = 'none'

Config.JerryCanCost = 100
Config.RefillCost = 50 -- Cost to refill a completely empty can (scaled by how empty it is)
Config.MaxPayment = 1000 -- Server rejects any single fuel payment above this

-- Fuel decor - leave it.
Config.FuelDecor = "_FUEL_LEVEL"

-- ox_target interaction distance
Config.TargetDistance = 2.5

-- Controls disabled while fueling.
Config.DisableKeys = {0, 22, 23, 24, 29, 30, 31, 37, 44, 56, 82, 140, 166, 167, 168, 170, 288, 289, 311, 323}

Config.EnableHUD = false
Config.EnableBar = false
Config.EnableSpeedHUD = false

Config.LowFuelLevel = 15

Config.ColorHUD = {r = 255, g = 255, b = 255, a = 255}
Config.ColorLowFuel = {r = 255, g = 50, b = 50, a = 255}
Config.ColorBar = {r = 255, g = 179, b = 0}
Config.ColorBarLow1 = {r = 255, g = 0, b = 0}
Config.ColorBarLow2 = {r = 255, g = 255, b = 255}

Config.HUDx = 0.01135
Config.HUDy = 0.002

Config.ShowNearestGasStationOnly = false
Config.ShowAllGasStations = true

Config.CostMultiplier = 1.0

Config.Strings = {
	Refuel = "Refuel vehicle",
	RefuelJerryCan = "Refuel with jerry can",
	BuyJerryCan = "Buy jerry can ($" .. Config.JerryCanCost .. ")",
	GrabJerryCan = "Grab jerry can",
	RefillJerryCan = "Refill jerry can",
	Fueling = "[E] Stop fueling",
	NoVehicle = "No vehicle nearby",
	FullTank = "Tank is full",
	JerryCanEmpty = "Jerry can is empty",
	JerryCanFull = "Jerry can is full",
	NotEnoughCash = "Not enough cash",
}

Config.PumpModels = {
	`prop_gas_pump_1d`,
	`prop_gas_pump_1a`,
	`prop_gas_pump_1b`,
	`prop_gas_pump_1c`,
	`prop_vintage_pump`,
	`prop_gas_pump_old2`,
	`prop_gas_pump_old3`,
}

-- Model blacklist (backtick hashes), e.g. `bmx`
Config.Blacklist = {}

-- Class blacklist https://docs.fivem.net/natives/?_0x29439776AAA00A62
Config.ClassBlacklist = {
	13, -- Cycles
	14, -- Boats
	21, -- Trains
}

Config.RemoveHUDForBlacklistedVehicle = true

Config.FuelUsage = 1.2
Config.RefuelRate = 1.0
Config.UnlimitedJerryCan = false

Config.GasStations = {
	vector3(49.4187, 2778.793, 58.043),
	vector3(263.894, 2606.463, 44.983),
	vector3(1039.958, 2671.134, 39.550),
	vector3(1207.260, 2660.175, 37.899),
	vector3(2539.685, 2594.192, 37.944),
	vector3(2679.858, 3263.946, 55.240),
	vector3(2005.055, 3773.887, 32.403),
	vector3(1687.156, 4929.392, 42.078),
	vector3(1701.314, 6416.028, 32.763),
	vector3(179.857, 6602.839, 31.868),
	vector3(-94.4619, 6419.594, 31.489),
	vector3(-2554.996, 2334.40, 33.078),
	vector3(-1800.375, 803.661, 138.651),
	vector3(-1437.622, -276.747, 46.207),
	vector3(-2096.243, -320.286, 13.168),
	vector3(-724.619, -935.1631, 19.213),
	vector3(-526.019, -1211.003, 18.184),
	vector3(-70.2148, -1761.792, 29.534),
	vector3(265.648, -1261.309, 29.292),
	vector3(819.653, -1028.846, 26.403),
	vector3(1208.951, -1402.567, 35.224),
	vector3(1181.381, -330.847, 69.316),
	vector3(620.843, 269.100, 103.089),
	vector3(2581.321, 362.039, 108.468),
	vector3(176.631, -1562.025, 29.263),
	vector3(-319.292, -1471.715, 30.549),
	vector3(1784.324, 3330.55, 41.253),
	vector3(357.0750, 5371.1548, 670.8790)
}
