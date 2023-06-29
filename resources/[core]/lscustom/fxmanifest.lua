fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'
description 'Los Santos Customs'
version '1.0.0'

shared_scripts {
	'@system/imports.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}

ui_page 'web/dist/index.html'

files {
	'web/dist/**/*',
}

dependency 'system'
