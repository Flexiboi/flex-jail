fx_version "bodacious"
game "gta5"
lua54 "yes"

author "flexiboi"
description "Flex-jail"
version "1.0.0"

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/nl.lua',
    'client/drugs/effects.lua',
    'client/functions/animations.lua',
    'client/functions/raycast.lua',
    'client/functions/camera.lua',
    'client/functions/functions.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**.lua',
}

client_scripts {
    'cl_weaponNames.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/**.lua',
}

dependencies {
	'qb-core'
}

files{
	'**/weaponcomponents.meta',
	'**/weaponarchetypes.meta',
	'**/weaponanimations.meta',
	'**/pedpersonality.meta',
	'**/weapons.meta',
    'meta/**/weapondagger.meta',
    'meta/**/weaponsnowball.meta',
    'meta/**/weaponmachete.meta',
    'stream/*.ydr',
    'stream/*.ytd',
    'stream/*.ytyp',
}

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'
data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'
data_file 'WEAPON_COMPONENTS_FILE' '**/weaponcomponents.meta'
data_file 'WEAPONINFO_FILE' 'meta/**/weapondagger.meta'
data_file 'WEAPONINFO_FILE' 'meta/**/weaponsnowball.meta'
data_file 'WEAPONINFO_FILE' 'meta/**/weaponmachete.meta'