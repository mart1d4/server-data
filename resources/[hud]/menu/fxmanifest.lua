fx_version 'cerulean'
games { 'gta5' }

author 'mart1d4'
description 'Simple menu for doing things.'
version '1.0.0'

client_scripts {
    'client/**/*.lua',
}

server_scripts {
	'server/**/*.lua',
}

files {
	'web/dist/**/*',
}

ui_page 'web/dist/index.html'
