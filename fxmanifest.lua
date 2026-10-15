fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'InZidiuZ & Drift_91'
description "Drift_91's fork of Legacy Fuel - optimised, ox_target"
version '3.0'

dependencies { 'ox_lib', 'ox_target' }

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua'
}

client_scripts {
	'functions/functions_client.lua',
	'source/fuel_client.lua'
}

server_scripts {
	'source/fuel_server.lua'
}

exports {
	'GetFuel',
	'SetFuel'
}

provide 'LegacyFuel'
