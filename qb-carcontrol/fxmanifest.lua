fx_version 'adamant'

game 'gta5'

author 'QBCore Store Since 2020'
description 'only buy from discord.gg/qbcoreframework'
version '9 Special Edition'


shared_scripts {
	'config.lua',
	'functions.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/*.js',
    'html/*.css',
	'html/images/*.png',
	'html/images/*.svg',
}

dependency '2na_core'

lua54 'yes'

escrow_ignore {
    'config.lua'
}