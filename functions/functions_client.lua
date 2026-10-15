local blacklistModels = {}
local blacklistClasses = {}

for i = 1, #Config.Blacklist do blacklistModels[Config.Blacklist[i]] = true end
for i = 1, #Config.ClassBlacklist do blacklistClasses[Config.ClassBlacklist[i]] = true end

function IsBlacklisted(vehicle)
	return blacklistModels[GetEntityModel(vehicle)] or blacklistClasses[GetVehicleClass(vehicle)] or false
end

function GetFuel(vehicle)
	return DecorGetFloat(vehicle, Config.FuelDecor)
end

function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' then
		DecorSetFloat(vehicle, Config.FuelDecor, math.max(0, math.min(100, fuel)) + 0.0)
	end
end

function Round(num, places)
	local mult = 10 ^ (places or 0)
	return math.floor(num * mult + 0.5) / mult
end

function lerp(a, b, v)
	return a + (b - a) * v
end

function CreateBlip(coords)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

	SetBlipSprite(blip, 361)
	SetBlipScale(blip, 0.75)
	SetBlipColour(blip, 6)
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Gas Station")
	EndTextCommandSetBlipName(blip)

	return blip
end

-- https://docs.fivem.net/docs/cookbook/2019/08/12/useful-snippet-getting-the-top-left-of-the-minimap-in-screen-coordinates/
function getMinimapTop()
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	local x, y = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
	ResetScriptGfxAlign()
	return x, y, x + 0.150, y
end

function TakeControl(entity)
	if NetworkHasControlOfEntity(entity) then return true end
	local timeout = GetGameTimer() + 500
	while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
		NetworkRequestControlOfEntity(entity)
		Wait(0)
	end
	return NetworkHasControlOfEntity(entity)
end
