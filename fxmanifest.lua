fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ManiMods'
description 'Trader System'
version '1.0.0'

ui_page 'http://localhost:5173/'
-- ui_page 'web/build/index.html'

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'open/sv_open.lua',
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
}

files {
    'config.lua',
    'locales/*.json',
    'open/cl_open.lua',
    'web/build/index.html',
    'web/build/**/*'
}