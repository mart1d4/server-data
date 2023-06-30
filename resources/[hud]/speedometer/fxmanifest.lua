fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'mart1d4'
description 'Speedometer'
lua54 'yes'

ui_page 'web/dist/index.html'

shared_script '@system/imports.lua'

client_script 'client/**/*'
server_script 'server/**/*'

files 'web/dist/**/*'

dependency 'system'
