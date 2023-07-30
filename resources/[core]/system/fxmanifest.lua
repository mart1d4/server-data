fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'mart1d4'
description 'All the core logic for the server.'
lua54 'yes'

shared_script 'shared/config.lua'

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

files {
	'imports.lua',
	'web/dist/**/*',
}

ui_page 'web/dist/index.html'

dependencies {
	'/native:0x6AE51D4B',
	'oxmysql',
}
