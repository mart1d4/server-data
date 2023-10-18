fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'mart1d4'
description 'Provides baseline chat functionality using a NUI-based interface.'

ui_page 'web/dist/index.html'

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'web/dist/**/*',
}
