fx_version 'cerulean'
game 'gta5'

--  █████╗ ██╗    █████╗ ███╗   ██╗ ██████╗ 
-- ██╔══██╗██║██╗ ██╔══██╗████╗  ██║██╔═══██╗
-- ███████║██║██║ ███████║██╔██╗ ██║██║   ██║
-- ██╔══██║██║██║ ██╔══██║██║╚██╗██║██║   ██║
-- ██║  ██║██║██║ ██║  ██║██║ ╚████║╚██████╔╝
-- ╚═╝  ╚═╝╚═╝╚═╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ 

author 'Aliano'
description 'Système de consommation d\'alcool avec effets roleplay. || Alcohol consumption system with roleplay\'s effects.'
version '1.0.0'

repository 'https://github.com/alinmb/aliano_alcohol_effects'

shared_script 'shared/config.lua'
client_script 'client/client.lua'
server_script 'server/server.lua'

files {
    'locales/*.json',
}

dependencies {
    'ox_inventory'
}