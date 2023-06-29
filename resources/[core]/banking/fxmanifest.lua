fx_version 'cerulean'

games { 'gta5' }

description 'Core banking system.'
lua54 'yes'
version '1.0.0'

shared_scripts {
	'@system/imports.lua',
	'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

ui_page 'web/dist/index.html'

files {
	'web/dist/**/*',
}

dependency 'system'
