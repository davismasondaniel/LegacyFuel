local PETROL_CAN = `WEAPON_PETROLCAN`
local CAN_MAX_AMMO = 4500
local ANIM_DICT, ANIM_NAME = "timetable@gardener@filling_can", "gar_ig_5_filling_can"

local isFueling = false
local inBlacklisted = false

local function notify(msg, kind)
	lib.notify({ description = msg, type = kind or 'inform' })
end

---------------------------------------------------------------------
-- Fuel usage (1 Hz, only while driving)
---------------------------------------------------------------------
local lastVehicle, petrolVolume = nil, 0.0

local function manageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		SetFuel(vehicle, math.random(400, 800) / 10)
		return
	end

	if IsVehicleEngineOn(vehicle) then
		local fuel = GetFuel(vehicle) - (Config.FuelUsage or 1.0) * GetVehicleCurrentRpm(vehicle)
			* lerp(0.1, 1.0, GetVehicleThrottleOffset(vehicle)) * 5 / petrolVolume
		SetFuel(vehicle, fuel)

		if fuel <= 0.0 then
			SetVehicleEngineOn(vehicle, false, false, true)
		end
	end
end

CreateThread(function()
	DecorRegister(Config.FuelDecor, 1)

	while true do
		Wait(1000)

		local vehicle = cache.vehicle
		if vehicle then
			if vehicle ~= lastVehicle then
				lastVehicle = vehicle
				petrolVolume = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
				inBlacklisted = IsBlacklisted(vehicle) or petrolVolume <= 0.0
			end

			if not inBlacklisted and cache.seat == -1 then
				manageFuelUsage(vehicle)
			end
		else
			lastVehicle = nil
			inBlacklisted = false
		end
	end
end)

---------------------------------------------------------------------
-- Refueling
---------------------------------------------------------------------
local function startRefuel(vehicle, pump)
	if isFueling or not DoesEntityExist(vehicle) then return end

	local ped = cache.ped
	local volume = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
	if volume <= 0.0 then return end

	local paid = pump and Config.Framework ~= 'none'
	local cash = paid and lib.callback.await('fuel:getCash', false) or 0
	if paid and cash <= 0 then return notify(Config.Strings.NotEnoughCash, 'error') end

	isFueling = true

	TaskTurnPedToFaceEntity(ped, vehicle, 1000)
	Wait(1000)
	SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
	lib.requestAnimDict(ANIM_DICT)
	TaskPlayAnim(ped, ANIM_DICT, ANIM_NAME, 2.0, 8.0, -1, 50, 0, 0, 0, 0)
	TakeControl(vehicle)

	local fuel, cost, nextTick = GetFuel(vehicle), 0.0, 0
	local useCan = not pump and not Config.UnlimitedJerryCan

	while isFueling do
		for i = 1, #Config.DisableKeys do
			DisableControlAction(0, Config.DisableKeys[i], true)
		end

		local now = GetGameTimer()
		if now >= nextTick then
			nextTick = now + 500

			local add = math.random(18, 20) * Config.RefuelRate * 5 / volume
			local extra = add / 1.5 * Config.CostMultiplier * volume / 5
			local ok = true

			if useCan then
				local ammo = GetAmmoInPedWeapon(ped, PETROL_CAN)
				if ammo - add * 100 >= 0 then
					SetPedAmmo(ped, PETROL_CAN, math.floor(ammo - add * 12 * volume / 5))
				else
					ok = false
				end
			end

			if paid and cost + extra > cash then ok = false end

			if ok then
				fuel = fuel + add
				if paid then cost = cost + extra end

				if fuel >= 100.0 then
					fuel = 100.0
					isFueling = false
				end

				TakeControl(vehicle)
				SetFuel(vehicle, fuel)

				local text = ('%s  |  %.1f%%'):format(Config.Strings.Fueling, fuel)
				if paid then text = text .. (' | $%.1f'):format(cost) end
				if useCan then text = text .. (' | Can: %.0f%%'):format(GetAmmoInPedWeapon(ped, PETROL_CAN) / CAN_MAX_AMMO * 100) end
				lib.showTextUI(text)
			else
				isFueling = false
			end
		end

		if not IsEntityPlayingAnim(ped, ANIM_DICT, ANIM_NAME, 3) then
			TaskPlayAnim(ped, ANIM_DICT, ANIM_NAME, 2.0, 8.0, -1, 50, 0, 0, 0, 0)
		end

		if IsControlJustReleased(0, 38)
			or IsEntityDead(ped)
			or not DoesEntityExist(vehicle)
			or DoesEntityExist(GetPedInVehicleSeat(vehicle, -1))
			or (pump and GetEntityHealth(pump) <= 0) then
			isFueling = false
		end

		Wait(0)
	end

	lib.hideTextUI()
	ClearPedTasks(ped)
	RemoveAnimDict(ANIM_DICT)

	if paid and cost > 0 and not lib.callback.await('fuel:pay', false, cost) then
		notify(Config.Strings.NotEnoughCash, 'error')
	end
end

local function getNearbyVehicle()
	local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)
	if not vehicle or DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) then return end
	return vehicle
end

local function hasCan()
	return HasPedGotWeapon(cache.ped, PETROL_CAN, false)
end

---------------------------------------------------------------------
-- ox_target
---------------------------------------------------------------------
exports.ox_target:addModel(Config.PumpModels, {
	{
		name = 'fuel_pump_refuel',
		icon = 'fas fa-gas-pump',
		label = Config.Strings.Refuel,
		distance = Config.TargetDistance,
		canInteract = function(entity)
			return not isFueling and not cache.vehicle and GetEntityHealth(entity) > 0
		end,
		onSelect = function(data)
			local vehicle = getNearbyVehicle()
			if not vehicle then return notify(Config.Strings.NoVehicle, 'error') end
			if IsBlacklisted(vehicle) then return end
			if GetFuel(vehicle) >= 100 then return notify(Config.Strings.FullTank) end

			startRefuel(vehicle, data.entity)
		end
	},
	{
		name = 'fuel_pump_buycan',
		icon = 'fas fa-oil-can',
		label = Config.Framework == 'none' and Config.Strings.GrabJerryCan or Config.Strings.BuyJerryCan,
		distance = Config.TargetDistance,
		canInteract = function(entity)
			return not isFueling and not cache.vehicle and not hasCan() and GetEntityHealth(entity) > 0
		end,
		onSelect = function()
			if Config.Framework ~= 'none' and not lib.callback.await('fuel:pay', false, Config.JerryCanCost) then
				return notify(Config.Strings.NotEnoughCash, 'error')
			end

			GiveWeaponToPed(cache.ped, PETROL_CAN, CAN_MAX_AMMO, false, true)
		end
	},
	{
		name = 'fuel_pump_refillcan',
		icon = 'fas fa-oil-can',
		label = Config.Strings.RefillJerryCan,
		distance = Config.TargetDistance,
		canInteract = function(entity)
			return not isFueling and not cache.vehicle and hasCan()
				and GetAmmoInPedWeapon(cache.ped, PETROL_CAN) < CAN_MAX_AMMO and GetEntityHealth(entity) > 0
		end,
		onSelect = function()
			local ped = cache.ped
			local cost = Round(Config.RefillCost * (1 - GetAmmoInPedWeapon(ped, PETROL_CAN) / CAN_MAX_AMMO))

			if cost > 0 and Config.Framework ~= 'none' and not lib.callback.await('fuel:pay', false, cost) then
				return notify(Config.Strings.NotEnoughCash, 'error')
			end

			SetPedAmmo(ped, PETROL_CAN, CAN_MAX_AMMO)
		end
	},
})

exports.ox_target:addGlobalVehicle({
	{
		name = 'fuel_vehicle_jerrycan',
		icon = 'fas fa-gas-pump',
		label = Config.Strings.RefuelJerryCan,
		distance = 2.0,
		canInteract = function(entity)
			if isFueling or cache.vehicle then return false end
			if not hasCan() then return false end
			if not Config.UnlimitedJerryCan and GetAmmoInPedWeapon(cache.ped, PETROL_CAN) < 100 then return false end
			return not IsBlacklisted(entity) and GetFuel(entity) < 100
		end,
		onSelect = function(data)
			startRefuel(data.entity, nil)
		end
	},
})

---------------------------------------------------------------------
-- Blips
---------------------------------------------------------------------
if Config.ShowNearestGasStationOnly then
	CreateThread(function()
		local blip, current

		while true do
			local coords = GetEntityCoords(cache.ped)
			local closest, closestCoords = 1000.0, nil

			for i = 1, #Config.GasStations do
				local c = Config.GasStations[i]
				local dist = #(coords - c)
				if dist < closest then
					closest, closestCoords = dist, c
				end
			end

			if closestCoords ~= current then
				if blip then RemoveBlip(blip) end
				blip = closestCoords and CreateBlip(closestCoords) or nil
				current = closestCoords
			end

			Wait(10000)
		end
	end)
elseif Config.ShowAllGasStations then
	CreateThread(function()
		for i = 1, #Config.GasStations do
			CreateBlip(Config.GasStations[i])
		end
	end)
end

---------------------------------------------------------------------
-- HUD
---------------------------------------------------------------------
if Config.EnableHUD then
	local function drawText(x, y, w, h, scale, text, r, g, b, a)
		SetTextFont(6)
		SetTextProportional(false)
		SetTextScale(scale, scale)
		SetTextJustification(1)
		SetTextColour(r, g, b, a)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextOutline()
		BeginTextCommandDisplayText("STRING")
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandDisplayText(x - 0.1 + w, y - 0.02 + h)
	end

	local displayHud = false
	local mph, kmh, fuelText = "0", "0", "0"
	local fuelNum = 0.0
	local barX1, barX2, barY = 0.0, 0.0, 0.0

	CreateThread(function()
		while true do
			local vehicle = cache.vehicle

			if vehicle and not (Config.RemoveHUDForBlacklistedVehicle and inBlacklisted) and not IsHudHidden() then
				local speed = GetEntitySpeed(vehicle)

				fuelNum = GetFuel(vehicle)
				mph = tostring(math.ceil(speed * 2.236936))
				kmh = tostring(math.ceil(speed * 3.6))
				fuelText = tostring(math.ceil(fuelNum))

				if Config.EnableBar then
					local x1, y1, x2 = getMinimapTop()
					if IsRadarHidden() then
						barX1, barX2, barY = x1 + 0.005, x2 - 0.005, 0.955
					else
						barX1, barX2, barY = x1 + 0.005, x2 - 0.005, y1 - 0.005
					end
				end

				displayHud = true
				Wait(100)
			else
				displayHud = false
				Wait(500)
			end
		end
	end)

	CreateThread(function()
		local hud = Config.ColorHUD

		while true do
			if displayHud then
				local t = GetGameTimer() % 1000
				local low = fuelNum < Config.LowFuelLevel

				if Config.EnableSpeedHUD then
					drawText(0.130 - Config.HUDx, 0.77 - Config.HUDy, 0.005, 0.0028, 0.6, mph, hud.r, hud.g, hud.b, hud.a)
					drawText(0.174 - Config.HUDx, 0.77 - Config.HUDy, 0.005, 0.0028, 0.6, kmh, hud.r, hud.g, hud.b, hud.a)
					drawText(0.148 - Config.HUDx, 0.7765 - Config.HUDy, 0.005, 0.0028, 0.4, "mp/h              km/h", hud.r, hud.g, hud.b, hud.a)
				end

				if Config.EnableBar then
					local width = barX2 - barX1
					local centerY = barY + 0.008
					local fill = width * (fuelNum / 100)

					DrawRect(barX1 + width / 2, centerY, width, 0.016, 0, 0, 0, 100)

					local c = Config.ColorBar
					local r, g, b = c.r, c.g, c.b

					if low then
						local v = t / 500
						if v > 1.0 then v = 2.0 - v end
						r = lerp(Config.ColorBarLow1.r, Config.ColorBarLow2.r, v)
						g = lerp(Config.ColorBarLow1.g, Config.ColorBarLow2.g, v)
						b = lerp(Config.ColorBarLow1.b, Config.ColorBarLow2.b, v)
					end

					DrawRect(barX1 + fill / 2, centerY, fill, 0.008, r, g, b, 150)
				else
					local col = (low and t < 500) and Config.ColorLowFuel or hud
					drawText(0.2195 - Config.HUDx, 0.77 - Config.HUDy, 0.005, 0.0028, 0.6, fuelText, col.r, col.g, col.b, col.a)
					drawText(0.2397 - Config.HUDx, 0.7766 - Config.HUDy, 0.005, 0.0028, 0.4, "Fuel", col.r, col.g, col.b, col.a)
				end
			else
				Wait(500)
			end

			Wait(0)
		end
	end)
end
