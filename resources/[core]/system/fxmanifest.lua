fx_version 'cerulean'
games { 'gta5' }

author 'mart1d4'
description 'All the core logic for the server, initialized on startup.'
version '1.0.0'
lua54 'yes'

shared_scripts {
	'shared/config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/common.lua',
	'server/player.lua',
	'server/functions.lua',

	'server/main.lua',

	'shared/**/*.lua',
}

client_scripts {
	'client/common.lua',
	'client/functions.lua',
	'client/main.lua',
	
	'shared/**/*.lua',

	'client/commands.lua',
	'client/events.lua',
}

ui_page {
	'web/dist/index.html'
}

files {
	'imports.lua',
	'web/dist/**/*',
}

dependencies {
	'/native:0x6AE51D4B',
	'oxmysql',
}
