SV_Config = {}

MySQL.query([=[
    CREATE TABLE IF NOT EXISTS `flex_jail` (
        `identifier` VARCHAR(100) NOT NULL,
        `status` BOOLEAN NOT NULL DEFAULT 0,
        `cangooutside` BOOLEAN NOT NULL DEFAULT 0,
        `jailtime` INT(11) NOT NULL DEFAULT '0',
        `prisonnumber` INT(11) NOT NULL DEFAULT '0',
        `items` longtext DEFAULT NULL,
        `data` longtext DEFAULT NULL,
        PRIMARY KEY (`identifier`) USING BTREE
    );
]=])

SV_Config.Crack = {
    Objects = {
        replacetime = 25, -- Time in minutes before it respawns
        objects = {
            [1] = {
                coords = vec4(1763.4470019531,2581.5051757812,49.986569824219, 105),
                prop = -576515524,
                spawned = true,
                reward = {
                    item = 'jail_medicine1',
                    amount = 1,
                },
            },
            [2] = {
                coords = vec4(1760.2491455078,2571.053613281,49.716539154053, 101),
                prop = 'v_med_bottles3',
                spawned = true,
                reward = {
                    item = 'jail_medicine2',
                    amount = 1,
                },
            },
            [3] = {
                coords = vec4(1737.3629150391,2596.6569824219,45.330947875977, 206),
                prop = 'prop_copper_pan',
                spawned = true,
                reward = {
                    item = 'jail_pot',
                    amount = 1,
                },
            },
            [4] = {
                coords = vector4(1686.44, 2553.46, 44.56, 129),
                prop = 'prop_stag_do_rope',
                spawned = true,
                reward = {
                    item = 'nylonrope',
                    amount = 1,
                },
            },
        },
        stageitems = { -- Items needed for each stage
            [1] = {
                [1] = {
                    item = 'campfire',
                    amount = 1,
                },
            },
            [2] = {
                [1] = {
                    item = 'jail_pot',
                    amount = 1,
                },
            },
            [3] = {
                [1] = {
                    item = 'jail_medicine1',
                    amount = 1,
                },
                [2] = {
                    item = 'jail_medicine2',
                    amount = 1,
                },
                [3] = {
                    item = 'rolling_paper',
                    amount = 1,
                },
            },
            [4] = {
                [1] = {
                    item = 'jail_crack',
                    amount = 1,
                }
            },
        },
    }
} 