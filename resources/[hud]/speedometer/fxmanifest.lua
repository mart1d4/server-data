fx_version "cerulean"

description "Speedometer"
author "mart1d4"
version '1.0.0'

lua54 'yes'

game "gta5"

ui_page 'web/dist/index.html'

shared_scripts {
	'@system/imports.lua',
}

client_script "client/**/*"
server_script "server/**/*"

files {
	'web/dist/**/*',
}

dependency 'system'
