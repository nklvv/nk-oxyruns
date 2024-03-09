fx_version 'cerulean'
game 'gta5'
lua54 'yes'

server_scripts {
	'server/sv_main.lua'
} 

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/cl_main.lua'
}

shared_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@ox_lib/init.lua',
	'sh_config.lua'
}