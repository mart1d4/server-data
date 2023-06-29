fx_version 'cerulean'

games { 'gta5' }

description 'Weapon core system'
lua54 'yes'
version '1.0.0'

shared_scripts {
	'@system/imports.lua',
	'config.lua'
}

server_scripts {
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

dependency 'system'
