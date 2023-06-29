fx_version 'cerulean'

games { 'gta5' }

description 'Enables players to sit on various chairs and benches.'
lua54 'yes'
version '1.0.0'

shared_script '@system/imports.lua'

server_scripts {
	'config.lua',
	'lists/seat.lua',
	'server.lua'
}

client_scripts {
	'config.lua',
	'lists/seat.lua',
	'client.lua'
}

dependencies {
	'system',
}
