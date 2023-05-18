fx_version "bodacious"
game "gta5"

ui_page_preload "yes"
ui_page "ui/index.html"

shared_script "config.lua"

client_scripts {
    "client/*.lua"
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "server/*.lua"
}

files {
    'ui/script.js',
    "ui/index.html",
    "ui/style.css",
    'ui/img/*',
}