fx_version 'cerulean'
games {'gta5'}

lua54 'yes'

name         'tofatmrobbery'
version      '1.0.0'
description  'ATM Robbery system'
author       'ChrisToF#0851'
repository   'https://github.com/ChrisToFLuA/tofatmrobbery'

dependency 'ox_lib'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
    'shared/*.lua'
}

server_scripts {
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

files{
    'locales/*.json'
}
