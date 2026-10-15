local framework = Config.Framework

if framework == 'qbcore' and GetResourceState('qb-core') ~= 'started' then
	print('^3[LegacyFuel] qb-core not started - fuel is free (Config.Framework = none)^0')
	framework = 'none'
elseif framework == 'qbox' and GetResourceState('qbx_core') ~= 'started' then
	print('^3[LegacyFuel] qbx_core not started - fuel is free (Config.Framework = none)^0')
	framework = 'none'
end

local QBCore = framework == 'qbcore' and exports['qb-core']:GetCoreObject() or nil

local function getPlayer(src)
	if framework == 'qbcore' then return QBCore.Functions.GetPlayer(src) end
	if framework == 'qbox' then return exports.qbx_core:GetPlayer(src) end
end

lib.callback.register('fuel:getCash', function(src)
	if framework == 'none' then return 1000000000 end
	local player = getPlayer(src)
	return player and player.PlayerData.money.cash or 0
end)

lib.callback.register('fuel:pay', function(src, amount)
	if type(amount) ~= 'number' or amount ~= amount then return false end

	amount = math.floor(amount + 0.5)
	if amount <= 0 then return true end
	if amount > Config.MaxPayment then return false end
	if framework == 'none' then return true end

	local player = getPlayer(src)
	return player and player.Functions.RemoveMoney('cash', amount, 'fuel') or false
end)
