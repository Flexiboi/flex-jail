Config = {}
Config.Debug = false
Config.Inv = 'ox_inventory/web/images/'

Config.DisableAmbient = true

Config.JobType = 'leo' -- type job of player needs to use commands
Config.JobName = 'doc' -- Name of the DOC job
Config.DocOfficerGrade = 0 -- Grade after the inmate grades
Config.MinimumDoc = 3
Config.MiniMumEscape = { -- Job or type + minimum people on duty needed
    ['leo'] = 1,
    ['doc'] = 3,
}

Config.PayEachMonthToDoc = { -- Does the DOC need to have an exra payment for each inmate each month?
    enable = false,
    payout = math.random(5,10),
}

Config.SpawnBackWhenBuggedOutPrison = false
Config.RespawnDistanceCheck = {
    min = 300,
    max = 1400,
}

Config.NewsPaper = true -- Publish in futte newspaper

Config.JailJobs = {
    removejob = true,
    default = {
        name = 'unemployed',
        rank = 0
    },
    lifer = {
        name = 'lifer',
        rank = 0
    },
}

Config.RemoveMultiJob = function(CID) -- Server Export to remoe multijob
    MySQL.query.await('DELETE FROM player_multijob WHERE identifier = ?', {CID})
end

Config.commands = {
    jailmenu = {
        command = 'jailmenu',
        enabled = false, -- false to use as item
        item = 'doc_tablet',
        all = false, -- ture = check on type false = type and jobname
    },
    jail = {
        command = 'jail',
        enabled = true,
        all = true, -- ture = check on type false = type and jobname
    },
    unjail = {
        command = 'unjail',
        enabled = true,
        all = true, -- ture = check on type false = type and jobname
    },
    jailtime = {
        command = 'jailtime',
        enabled = true,
    },
    jailpoints = {
        command = 'jp',
        enabled = true,
    },
    addjailpoints = {
        command = 'addjp',
        enabled = true,
    },
    removejailpoints = {
        command = 'removejp',
        enabled = true,
    },
    fixJailData = {
        command = 'fixjaildata',
        enabled = true,
    }
}

Config.PrisonClothes = {
    ['m'] = {
        outfitData = {
            ['t-shirt'] = { item = 15, texture = 0 },
            ['torso2'] = { item = 682, texture = 0 },
            ['arms'] = { item = 30, texture = 0 },
            ['pants'] = { item = 207, texture = 0 },
            ['shoes'] = { item = 195, texture = 0 },
        }
    },
    ['f'] = {
        outfitData = {
            ['t-shirt'] = { item = 14, texture = 0 },
            ['torso2'] = { item = 73, texture = 0 },
            ['arms'] = { item = 14, texture = 0 },
            ['pants'] = { item = 182, texture = 12 },
            ['shoes'] = { item = 132, texture = 0 },
        }
    },
}

Config.SecretStashProp = 'prop_paints_can04'
Config.UsableItems = {
    secretstash = 'jail_secretstash',
    crack = {
        pot = 'jail_pot',
    },
}

Config.Location = {
    center = vector3(1689.46, 2535.05, 61.34),
    jail = { -- Polyzone area of the whole prison
        vector2(1876.40, 2456.71),
        vector2(1820.51, 2356.95),
        vector2(1634.69, 2362.17),
        vector2(1502.74, 2444.74),
        vector2(1497.59, 2595.43),
        vector2(1569.56, 2732.24),
        vector2(1661.47, 2792.62),
        vector2(1780.51, 2813.39),
        vector2(1901.16, 2708.30),
        vector2(1899.47, 2530.42)
    },
    release = vector4(1846.02, 2585.89, 45.67, 265),
    armory = {
        [1] = vec3(1766.2708740234,2592.0661621094,46.244930267334),
    },
    evidence = {
        [1] = vec3(1764.0030517578,2591.4216308594,46.230964660645),
    },
    peds = {
        reception = { -- Ped of the reception
            loc = vector4(1838.02, 2581.39, 45.89, 271),
            model = 'u_m_m_doa_01',
            scenario = 'WORLD_HUMAN_CLIPBOARD',
        },
        release = { -- Ped of the reception
            loc = vector4(1780.90, 2554.82, 45.78, 181),
            model = 'u_m_m_doa_01',
            scenario = 'WORLD_HUMAN_CLIPBOARD',
        },
        washing = { -- Peds for the washing job
            loc = vector4(1596.47, 2548.77, 45.63, 85),
            model = 'u_m_m_doa_01',
            scenario = 'WORLD_HUMAN_CLIPBOARD',
        },
        mining = { -- Peds for the mining job
            loc = vector4(1585.54, 2560.46, 45.63, 274),
            model = 'u_m_m_doa_01',
            scenario = 'WORLD_HUMAN_CLIPBOARD',
        },
        cleaning = { -- Peds for the cleaning job
            loc = vector4(1740.19, 2565.67, 45.49, 2),
            model = 'u_m_m_doa_01',
            scenario = 'WORLD_HUMAN_JANITOR',
        },
        cantine = { -- Peds for the cantine
            loc = vector4(1732.61, 2589.46, 45.42, 178),
            model = 'u_m_m_doa_01',
            scenario = 'WORLD_HUMAN_GUARD_PATROL',
        },
        wood = { -- Peds for the wood job
            loc = vector4(1572.90, 2549.97, 45.63, 184),
            model = 'u_m_m_doa_01',
            scenario = 'WORLD_HUMAN_CLIPBOARD',
        },
    },
    jobs = {
        washing = { -- Washing job
            area = {
                vector2(1599.46, 2552.84),
                vector2(1617.74, 2530.82),
                vector2(1562.53, 2521.99),
                vector2(1556.69, 2579.42)
            },
            takeclothes = {
                vec4(1591.5065917969,2543.2663574219,46.365287780762, 358),
                vec4(1592.8308105469,2543.2180175781,46.322704315186, 358),
                vec4(1594.1604003906,2543.1599121094,46.271682739258, 358),
            },
            washclothes = {
                vec4(1588.9921875,2541.490234375,45.196727752686, 97),
                vec4(1588.9921875,2540.8208007812,45.317764282227, 97),
                vec4(1588.9921875,2540.1145019531,45.308044433594, 97),
                vec4(1588.9921875,2539.4074707031,45.267417907715, 97),
                vec4(1588.9921875,2538.7341308594,45.275241851807, 97),
                vec4(1588.9921875,2538.029296875,45.292640686035, 97),
                vec4(1588.9921875,2537.3952636719,45.262020111084, 97),
                vec4(1596.6236572266,2541.5798339844,45.364807128906, 279),
                vec4(1596.6234130859,2540.9045410156,45.285732269287, 279),
                vec4(1596.6234130859,2540.2102050781,45.313999176025, 279),
                vec4(1596.6235351562,2539.4736328125,45.284088134766, 279),
                vec4(1596.6234130859,2538.7756347656,45.30103302002, 279),
                vec4(1596.6234130859,2538.0656738281,45.282989501953, 279),
                vec4(1596.6236572266,2537.3864746094,45.31196975708, 279),
            },
            storeclothes = {
                vec4(1591.4359130859,2549.4716796875,45.382511138916, 5),
                vec4(1592.6354980469,2549.4716796875,45.406280517578, 5),
                vec4(1594.0797119141,2549.4716796875,45.417987823486, 5),
                vec4(1593.0445556641,2539.7302246094,45.791915893555, 5),
                vec4(1592.2945556641,2538.4196777344,45.732318878174, 5),
                vec4(1592.5603027344,2541.130859375,45.683055877686, 5),
            }
        },
        mining = { -- Mining job
            area = {
                vector2(1583.14, 2563.80),
                vector2(1597.48, 2563.81),
                vector2(1566.64, 2590.25),
                vector2(1638.89, 2600.08),
                vector2(1638.86, 2558.33),
                vector2(1610.27, 2544.69),
                vector2(1567.80, 2549.27)
            },
            rocks = {
                vec3(1603.8659667969, 2558.7280273438, 45.075950622559),
                vec3(1614.3203125, 2566.6359863281, 45.205776977539),
                vec3(1617.6231689453, 2571.3012695312, 46.022528076172),
                vec3(1618.6892089844, 2576.521484375, 45.31706237793),
            },
            drilling = {
                [1] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1596.1826171875,2558.02734375,45.404434051514, 185),
                },
                [2] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1594.5848388672,2558.0270996094,45.404434051514, 185),
                },
                [3] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1593.0588378906,2558.0270996094,45.404434051514, 185),
                },
                [4] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1591.4211425781,2558.0270996094,45.404434051514, 185),
                },
                [5] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1591.4530029297,2562.9406738281,45.404434051514, 185),
                },
                [6] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1593.0864257812,2562.9406738281,45.404434051514, 185),
                },
                [7] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1594.5970458984,2562.9406738281,45.404434051514, 185),
                },
                [8] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1596.3880615234,2562.9406738281,45.404434051514, 185),
                },
            },
            dropoff = {
                spawnprops = true,
                prop = 'prop_rub_cardpile_07',
                loc = {
                    vec4(1584.1499023438,2558.375,45.012321472168, 106),
                    vec4(1584.0715332031,2562.4677734375,45.009254455566, 106),
                },
            }
        },
        wood = { -- Wood job
            area = {
                vec2(1565.7742919922,2545.4528808594),
                vec2(1565.7742919922,2550.6965332031),
                vec2(1587.6887207031,2550.9809570312),
                vec2(1588.095703125,2545.7536621094)
            },
            takewood = vec4(1566.5893554688,2547.9555664062,45.759567260742, 87.0),
            sawing = {
                [1] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1581.8713378906, 2545.7873535156, 45.582084655762, 185.0),
                },
                [2] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1582.0561523438,2550.435546875,45.582141876221, 357.0),
                },
                [3] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1578.27734375,2545.76171875,45.582149505615, 185.0),
                },
                [4] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1578.3721923828,2550.4704589844,45.582202911377, 357.0),
                },
                [5] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1574.6545410156,2545.8234863281,45.581970214844, 185.0),
                },
                [6] = {
                    spawnprop = false,
                    prop = 'gr_prop_gr_speeddrill_01c',
                    loc = vec4(1574.7396240234,2550.447265625,45.582168579102, 357.0),
                },
            },
        },
        cleaning = { -- Cleaning job
            area = {
                vector2(3941.83, 59.29),
                vector2(3993.42, 55.04),
                vector2(3991.26, 28.88),
                vector2(3952.66, 31.76),
                vector2(3955.45, 24.60),
                vector2(3917.44, 13.51),
                vector2(3882.10, 18.27),
                vector2(3883.63, 36.37),
                vector2(3904.03, 34.91),
                vector2(3904.36, 42.27),
                vector2(3916.79, 41.80)
            },
            jobs = {
                [1] = {
                    loc = vector4(1732.9195556641,2576.59765625,44.419418334961, 203), -- Location of the task
                    anim = {
                        dic = "anim@amb@drug_field_workers@rake@male_a@idles", -- Anim dic
                        anim = 'idle_b', -- Anim
                        prop = 'prop_tool_broom', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            -0.0100,
                            0.0400,
                            -0.0300,
                            0.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_big_shit_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [2] = {
                    loc = vec4(1741.9332275391,2578.482421875,45.211139678955, 271), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "ng_proc_food_chips01c", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [3] = {
                    loc = vec4(1731.4073486328,2566.1723632812,45.211139678955, 113), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "v_res_tt_litter2", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [4] = {
                    loc = vec4(1726.7667236328,2586.6477050781,45.211280822754, 85), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_plate_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [5] = {
                    loc = vec4(1743.3217773438,2582.8774414062,44.871196746826, 184), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_plate_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [6] = {
                    loc = vec4(1741.4420166016,2587.283203125,45.483818054199, 3), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_plate_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [7] = {
                    loc = vec4(1745.4139404297,2574.9362792969,45.211280822754, 86), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_plate_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [8] = {
                    loc = vec4(1743.5977783203,2566.9418945312,44.871196746826, 176), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_plate_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [9] = {
                    loc = vec4(1751.9400634766,2585.5854492188,44.419418334961, 60), -- Location of the task
                    anim = {
                        dic = "anim@amb@drug_field_workers@rake@male_a@idles", -- Anim dic
                        anim = 'idle_b', -- Anim
                        prop = 'prop_tool_broom', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            -0.0100,
                            0.0400,
                            -0.0300,
                            0.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "m23_2_prop_m32_puddle_01a", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [10] = {
                    loc = vec4(1747.3493652344,2590.3637695312,44.419418334961, 235), -- Location of the task
                    anim = {
                        dic = "anim@amb@drug_field_workers@rake@male_a@idles", -- Anim dic
                        anim = 'idle_b', -- Anim
                        prop = 'prop_tool_broom', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            -0.0100,
                            0.0400,
                            -0.0300,
                            0.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "m23_2_prop_m32_puddle_01a", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [11] = {
                    loc = vec4(1739.1716308594,2593.3520507812,44.419418334961, 150), -- Location of the task
                    anim = {
                        dic = "anim@amb@drug_field_workers@rake@male_a@idles", -- Anim dic
                        anim = 'idle_b', -- Anim
                        prop = 'prop_tool_broom', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            -0.0100,
                            0.0400,
                            -0.0300,
                            0.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "m23_2_prop_m32_puddle_01a", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [12] = {
                    loc = vec4(1733.7760009766,2597.1604003906,44.419418334961, 323), -- Location of the task
                    anim = {
                        dic = "anim@amb@drug_field_workers@rake@male_a@idles", -- Anim dic
                        anim = 'idle_b', -- Anim
                        prop = 'prop_tool_broom', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            -0.0100,
                            0.0400,
                            -0.0300,
                            0.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "m23_2_prop_m32_puddle_01a", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [13] = {
                    loc = vec4(1736.7524414062,2588.7590332031,45.332462310791, 189), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "v_res_tt_litter2", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [14] = {
                    loc = vector4(3906.3625488281,34.973449707031,23.474477767944, 177), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "v_res_tt_litter2", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [15] = {
                    loc = vec4(1724.1286621094,2590.3369140625,44.419418334961, 341), -- Location of the task
                    anim = {
                        dic = "anim@amb@drug_field_workers@rake@male_a@idles", -- Anim dic
                        anim = 'idle_b', -- Anim
                        prop = 'prop_tool_broom', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            -0.0100,
                            0.0400,
                            -0.0300,
                            0.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_big_shit_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [16] = {
                    loc = vec4(1721.2734375,2584.5227050781,44.419418334961, 250), -- Location of the task
                    anim = {
                        dic = "anim@amb@drug_field_workers@rake@male_a@idles", -- Anim dic
                        anim = 'idle_b', -- Anim
                        prop = 'prop_tool_broom', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            -0.0100,
                            0.0400,
                            -0.0300,
                            0.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "prop_big_shit_02", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [17] = {
                    loc = vec4(1727.9958496094,2588.421875,44.869678497314, 179), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "ng_proc_food_chips01c", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
                [18] = {
                    loc = vec4(1736.1687011719,2597.4311523438,45.330654144287, 281), -- Location of the task
                    anim = {
                        dic = "timetable@floyd@clean_kitchen@base", -- Anim dic
                        anim = 'base', -- Anim
                        prop = 'prop_sponge_01', -- Prop of anim
                        bone = 28422,
                        PropPlacement = {
                            0.0,
                            0.0,
                            -0.01,
                            90.0,
                            0.0,
                            0.0
                        },
                    },
                    prop = "ng_proc_food_chips01c", -- The prop that spawn on ground
                    time = 5, -- How long the task is in seconds
                },
            }
        }
    },
    jailspawn = {
        [1] = {
            loc = vector4(1724.50, 2580.19, 45.42, 277),
            anim = {
                dic = nil, -- anim dic or nil for scenario
                anim = "WORLD_HUMAN_LEANING",
            },
        },
        [2] = {
            loc = vector4(1746.88, 2585.46, 45.42, 188),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [3] = {
            loc = vector4(1737.09, 2573.70, 45.42, 184),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [4] = {
            loc = vector4(1711.96, 2552.57, 45.56, 174),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [5] = {
            loc = vector4(1627.81, 2547.08, 45.56, 53),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [6] = {
            loc = vector4(1634.00, 2551.20, 45.56, 221),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [7] = {
            loc = vector4(1696.41, 2448.61, 45.65, 0),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [8] = {
            loc = vector4(1686.69, 2452.40, 45.65, 176),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [9] = {
            loc = vector4(1617.80, 2478.35, 45.65, 25),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [10] = {
            loc = vector4(1608.12, 2478.37, 45.65, 318),
            anim = {
                dic = "timetable@ron@ig_3_couch", -- anim dic or nil for scenario
                anim = "base",
            },
        },
        [11] = {
            loc = vector4(1629.80, 2472.36, 45.65, 56),
            anim = {
                dic = nil, -- anim dic or nil for scenario
                anim = "WORLD_HUMAN_LEANING",
            },
        },
        [12] = {
            loc = vector4(1622.53, 2499.50, 45.56, 279),
            anim = {
                dic = nil, -- anim dic or nil for scenario
                anim = "WORLD_HUMAN_LEANING",
            },
        },
        [13] = {
            loc = vector4(1665.79, 2567.74, 45.56, 83),
            anim = {
                dic = nil, -- anim dic or nil for scenario
                anim = "WORLD_HUMAN_LEANING",
            },
        },
        [14] = {
            loc = vector4(1758.58, 2568.88, 45.52, 189),
            anim = {
                dic = nil, -- anim dic or nil for scenario
                anim = "WORLD_HUMAN_LEANING",
            },
        },
    },
    stashes = {
        [1] = {
            stashname = 'Moestuin',
            job = {'doc', 'lifer'},
            location = vec4(1689.7108154297, 2552.6022949219, 45.637138366699, 0.0),
            boxzone = vec3(2.0, 2.0, 2.0),
            slots = 120,
            size = 220000,
        },
        [2] = {
            stashname = 'Moestuin2',
            job = {'doc', 'lifer'},
            location = vector4(1687.99, 2551.47, 45.65, 258),
            boxzone = vec3(2.0, 2.0, 2.0),
            slots = 120,
            size = 220000,
        },
    },
}

Config.BlipSettings = {
    job = { -- Blip for the jobs
        sprite = 274,
        color = 27,
        scale = 0.8,
        label = 'Huidige job',
    },
}

Config.JobSettings = {
    ['washing'] = {
        washtime = 30, -- Seconds to wash
        points = 1, -- Points / rep you get per job
        reducetimechance = 25, -- 25% chance to reduce time in jail
        reward = {
            checkifhas = false, -- Check if player already owns this
            chance = 9, -- this or lower out of 100
            reward = {
                item = 'black_money', -- Itemname or cash/bank/blackmoney
                amount = 1,
            }
        }
    },
    ['mining'] = {
        minetime = math.random(8,12), -- Time seconds to mine
        drilltime = math.random(10,15), -- Time in seconds
        points = 1, -- Points / rep you get per job
        reducetimechance = 25, -- 25% chance to reduce time in jail
        reward = {
            checkifhas = true, -- Check if player already owns this
            chance = 5, -- this or lower out of 100
            reward = {
                item = 'weapon_sknife', -- Itemname or cash/bank/blackmoney
                amount = 1,
            }
        }
    },
    ['cleaning'] = {
        points = 1, -- Points / rep you get per job
        reducetimechance = 25, -- 25% chance to reduce time in jail
        reward = {
            checkifhas = false, -- Check if player already owns this
            chance = nil, -- this or lower out of 100
            reward = {
                item = nil, -- Itemname or cash/bank/blackmoney
                amount = 1,
            }
        }
    },
    ['wood'] = {
        points = 1, -- Points / rep you get per job
        reducetimechance = 1, -- 25% chance to reduce time in jail
        reward = {
            checkifhas = false, -- Check if player already owns this
            chance = 100, -- this or lower out of 100
            reward = {
                item = 'woodenplanks', -- Itemname or cash/bank/blackmoney
                amount = math.random(3,5),
            }
        },
        sawtime = math.random(10,20), -- Time in seconds
        sellItemList = {
            ['wooden_fence'] = 1,
            ['wooden_box'] = 1,
            ['wooden_chair'] = 1,
        },
    }
}

Config.Sounds = {
    breakout = { -- Sound for when people break out
        soundname = 'prison_breakout', -- Unique name of the xsound
        url = 'https://www.youtube.com/watch?v=ZG7L9FJ61eo', -- Youtube url
        volume = 0.5, -- Volume 0.0 - 1.0
        pos = vector3(1689.46, 2535.05, 61.34), -- vector3 pos
        distance = 500, -- Distance sound can be heard
        soundlength = 43, -- Legth of the youtube audio
    }
}

Config.RayCastDistance = {
    default = 3.0,
    secretstash = 4.0,
    fireplace = 10.0,
    washing = 2.0,
    mining = 4.0,
    cleaning = 2.0,
    rope = 6.0,
}

Config.StashSizes = {
    Default = {
        maxweight = 4000000,
        slots = 30,
    },
    secret = {
        slots = 5,
        size = 75000,
    },
}

Config.Cameras = {
    [1] = {
        name = 'Balie',
        coords = vector4(1839.64, 2580.54, 49.19, 322),
        sabotaged = false,
    },
    [2] = {
        name = 'Tussen Balie & Bezoekers',
        coords = vector4(1803.79, 2596.97, 51.60, 115),
        sabotaged = false,
    },
    [3] = {
        name = 'Bezoekers Inkom',
        coords = vector4(1784.20, 2588.83, 49.70, 326),
        sabotaged = false,
    },
    [4] = {
        name = 'Bezoekers Bezoekers',
        coords = vector4(1789.67, 2587.05, 49.70, 134),
        sabotaged = false,
    },
    [5] = {
        name = 'Bezoekers Gevangenen',
        coords = vector4(1779.58, 2586.98, 49.70, 232),
        sabotaged = false,
    },
    [6] = {
        name = 'Ziekenhuisbedjes',
        coords = vector4(1762.66, 2578.47, 48.80, 41),
        sabotaged = false,
    },
    [7] = {
        name = 'Cantine 1',
        coords = vector4(1724.85, 2572.91, 49.42, 298),
        sabotaged = false,
    },
    [8] = {
        name = 'Cantine 2',
        coords = vector4(1724.84, 2579.45, 49.42, 247),
        sabotaged = false,
    },
    [9] = {
        name = 'Cantine Keuken',
        coords = vector4(1741.52, 2589.45, 48.42, 43),
        sabotaged = false,
    },
    [10] = {
        name = 'Blok 7 - DOC kamer',
        coords = vector4(1760.08, 2491.11, 51.32, 205),
        sabotaged = false,
    },
    [11] = {
        name = 'Blok 7 - Camera 1',
        coords = vector4(1753.83, 2471.50, 51.82, 338),
        sabotaged = false,
    },
    [12] = {
        name = 'Blok 6 - DOC kamer',
        coords = vector4(1692.47, 2457.36, 51.32, 178),
        sabotaged = false,
    },
    [13] = {
        name = 'Blok 6 - Camera 1',
        coords = vector4(1677.35, 2443.34, 51.82, 310),
        sabotaged = false,
    },
    [14] = {
        name = 'Blok 5 - DOC kamer',
        coords = vector4(1617.74, 2481.96, 51.32, 132),
        sabotaged = false,
    },
    [15] = {
        name = 'Blok 5 - Camera 1',
        coords = vector4(1596.72, 2480.97, 51.82, 273),
        sabotaged = false,
    },
    [16] = {
        name = 'Blok 4 - Inkom',
        coords = vector4(1583.99, 2551.64, 48.43, 312),
        sabotaged = false,
    },
    [17] = {
        name = 'Blok 4 - Boren',
        coords = vector4(1596.50, 2561.03, 49.43, 58),
        sabotaged = false,
    },
    [18] = {
        name = 'Blok 4 - Wassen 1',
        coords = vector4(1596.48, 2547.13, 48.83, 89),
        sabotaged = false,
    },
    [19] = {
        name = 'Blok 4 - Wassen 2',
        coords = vec4(1592.0763671875,2543.02109375,49.659760437012, 206),
        sabotaged = false,
    },
    [20] = {
        name = 'Blok 4 - Houtbewerking',
        coords = vec4(1566.03, 2548.16, 50.0, 267.0),
        sabotaged = false,
    },
    [21] = {
        name = 'Buitenplein 1',
        coords = vec4(1665.91, 2487.77, 53.56, 359.0),
        sabotaged = false,
    },
}

Config.Shops = {
    cantine = { -- Standard food shop
        [1] = {
            paytype = 'bank',
            name = 'jail_sandwichh',
            price = 1,
            amount = 10000,
            info = {},
            slot = 1,
        },
        [2] = {
            paytype = 'bank',
            name = 'jail_waterr',
            price = 1,
            amount = 10000,
            info = {},
            slot = 2,
        },
    },
    illegal = { -- Shop for the blackmoney
        [1] = {
            paytype = 'black_money',
            name = 'jail_secretstash',
            price = 10,
            amount = 5,
            info = {},
            slot = 1,
        },
        [2] = {
            paytype = 'black_money',
            name = 'jail_secretstash2',
            price = 10,
            amount = 5,
            info = {},
            slot = 1,
        },
    },
    jp = { -- Shop for the jail points
        [1] = {
            label = 'Een bezoekje aan een eet tent', -- Name shown in the menu
            points = 50, -- Cost
        },
        [2] = {
            label = 'Wandeling in een park naar keuze', -- Name shown in the menu
            points = 20, -- Cost
        },
        [3] = {
            label = 'Bezoekje aan de kerk', -- Name shown in the menu
            points = 20, -- Cost
        },
        [4] = {
            label = 'Bezoekje aan een club', -- Name shown in the menu
            points = 50, -- Cost
        },
        [5] = {
            label = 'Erkende gevangene', -- Name shown in the menu
            points = 750, -- Cost
        },
        [6] = {
            label = 'Eige inbreng (vertel aan DOC)', -- Name shown in the menu
            points = 2000, -- Cost
        },
        [7] = {
            label = 'Aanvraag eigen cel', -- Name shown in the menu
            points = 1000, -- Cost
        },
        [8] = {
            label = 'Pokertafel', -- Name shown in the menu
            points = 350, -- Cost
        },
    }
}

Config.DOCAlertFirst = true -- First check if DOC job is there before all police get an alert
Config.SendPoliceAlert = function(coords, title, code, message, job)
    -- TriggerServerEvent("SendAlert:police", {
    --     coords = coords,
    --     title = message,
    --     type = code,
    --     message = message,
    --     job = job,
    -- })
    local Data = {
        type = 'Emergency',
        header = 'Ontsnapping',
        text = message,
        code = '45-23',
    }
    exports['codem-dispatch']:CustomDispatch(Data)
end

Config.Crack = {
    props = {
        fireplace = 'prop_jail_logs',
        pan = 'prop_copper_pan',
    },
    settings = {
        baketime = 25, -- seconds
        fireplacetime = 60, -- Time in seconds a firepalce exists
    }
}

-- Air defence system
Config.AirDefenceDistanceCheck = 250
Config.AirDefenceTimer = 8 -- seconds to escape
Config.AirDefenceExplosionTimeout = math.random(2,3)
Config.MaxExplosionCount = math.random(5,9)

-- BREAKOUT
Config.BreakOut = {
    [1] = {
        targetcoords = vec4(1846.2669677734, 2604.7014160156, 45.536235809326, 90.0), -- Target position
        offset = vec3(1.2, 0.0, 1.45), -- coords where the anim wil play or prop will spawn
        closestmodel = 'prop_gate_prison_01', -- Closest (door) model for anim to work
        itemsNeeded = {
            ['jail_breakouttool'] = {amount = 1, remove = true},
            ['x_laptop'] = {amount = 1, remove = true},
            ['bag'] = {amount = 1, remove = false},
        },
        minigame = function()
            return exports["bl_ui"]:PrintLock(3, {grid = 5, duration = 8000, target = 5 })
        end,
        getDoorState = function()
            local state = lib.callback.await("flex-jail:server:breakout:GetDoorState", false, 808)
            return state
        end,
        callPolice = function()
            local ped = PlayerPedId()
            local loc = GetEntityCoords(ped)
            Config.SendPoliceAlert(loc, Lang:t('alert.breakout.title'), Lang:t('alert.breakout.code'), Lang:t('alert.breakout.message'), 'police')
            Config.SendPoliceAlert(loc, Lang:t('alert.breakout.title'), Lang:t('alert.breakout.code'), Lang:t('alert.breakout.message'), 'doc')
        end,
        door = function()
            TriggerServerEvent('flex-jail:server:SetDoorState', 808, false)
        end,
        rope = {
            isrope = false, -- If the breakout is a rope
            roperemovetime = 30, -- seconds
            isropeplace = false,
            release = vector4(1773.83, 2534.14, 45.57, 283),
        }
    },
    [2] = {
        targetcoords = vec4(1819.7238769531,2604.6867675781,45.509788513184, 90.0), -- Target position
        offset = vec3(1.2, 0.0, 1.45), -- coords where the anim wil play or prop will spawn
        closestmodel = 'prop_gate_prison_01', -- Closest (door) model for anim to work
        itemsNeeded = {
            ['jail_breakouttool'] = {amount = 1, remove = true},
            ['x_laptop'] = {amount = 1, remove = true},
            ['bag'] = {amount = 1, remove = false},
        },
        minigame = function()
            return exports["bl_ui"]:PrintLock(3, {grid = 5, duration = 8000, target = 5 })
        end,
        getDoorState = function()
            local state = lib.callback.await("flex-jail:server:breakout:GetDoorState", false, 809)
            return state
        end,
        callPolice = function()
            local ped = PlayerPedId()
            local loc = GetEntityCoords(ped)
            Config.SendPoliceAlert(loc, Lang:t('alert.breakout.title'), Lang:t('alert.breakout.code'), Lang:t('alert.breakout.message'), 'police')
            Config.SendPoliceAlert(loc, Lang:t('alert.breakout.title'), Lang:t('alert.breakout.code'), Lang:t('alert.breakout.message'), 'doc')
        end,
        door = function()
            TriggerServerEvent('flex-jail:server:SetDoorState', 809, false)
        end,
        rope = {
            isrope = false, -- If the breakout is a rope
            roperemovetime = 30, -- seconds
            isropeplace = false,
            release = vector4(1773.83, 2534.14, 45.57, 283),
        }
    },
    [3] = {
        targetcoords = vec4(1773.3266601562,2536.2431640625,47.163349151611, 239.0), -- Target position
        offset = vec3(0.0, 0.0, 0.1), -- coords where the anim wil play or prop will spawn
        closestmodel = 'prop_gate_prison_01', -- Closest (door) model for anim to work
        itemsNeeded = {
            ['jail_rope'] = {amount = 1, remove = true},
        },
        minigame = function()
        end,
        getDoorState = function()
        end,
        callPolice = function()
        end,
        door = function()
        end,
        rope = {
            isrope = true, -- If the breakout is a rope
            roperemovetime = 30, -- seconds
            isropeplace = false,
            release = vector4(1773.83, 2534.14, 45.57, 283),
        }
    },
    [4] = {
        targetcoords = vec4(1786.9217529297,2564.6823730469,54.903217315674, 0.0), -- Target position
        offset = vec3(0.0, 0.0, -2.1), -- coords where the anim wil play or prop will spawn
        closestmodel = 'prop_gate_prison_01', -- Closest (door) model for anim to work
        itemsNeeded = {
            ['jail_rope'] = {amount = 1, remove = true},
        },
        minigame = function()
        end,
        getDoorState = function()
        end,
        callPolice = function()
        end,
        door = function()
        end,
        rope = {
            isrope = true, -- If the breakout is a rope
            roperemovetime = 30, -- seconds
            isropeplace = false,
            release = vector4(1785.82, 2565.49, 55.47, 87),
        }
    },
    [5] = {
        targetcoords = vec4(1823.5043945312,2484.1325683594,50.010229949951, 280.0), -- Target position
        offset = vec3(0.0, 0.0, -2.1), -- coords where the anim wil play or prop will spawn
        closestmodel = 'prop_gate_prison_01', -- Closest (door) model for anim to work
        itemsNeeded = {
            ['jail_rope'] = {amount = 1, remove = true},
        },
        minigame = function()
        end,
        getDoorState = function()
        end,
        callPolice = function()
        end,
        door = function()
        end,
        rope = {
            isrope = true, -- If the breakout is a rope
            roperemovetime = 30, -- seconds
            isropeplace = false,
            release = vector4(1824.41, 2483.39, 45.50, 288),
        }
    },
}

Config.CurrupNPCDoors = {
    payamount = 1000,
    doors = {
        819,
        813,
        817,
        814,
        815,
        1125,
    }
}

Config.Armory = {
    label = "DOC Armory",
    slots = 30,
    items = {
        [1] = {
            name = "weapon_stungun",
            price = 0,
            amount = 1,
            info = {
                serie = "",
            },
            type = "weapon",
            slot = 1,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [2] = {
            name = "weapon_nightstick",
            price = 0,
            amount = 1,
            info = {},
            type = "weapon",
            slot = 2,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [3] = {
            name = "handcuffs",
            price = 0,
            amount = 1,
            info = {},
            type = "item",
            slot = 3,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [4] = {
            name = "weapon_flashlight",
            price = 0,
            amount = 1,
            info = {},
            type = "weapon",
            slot = 4,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [5] = {
            name = "radio", 
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 5,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [6] = {
            name = "vest_police",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 6,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = false, amount = 1}
        },
        [7] = {
            name = "weapon_pepperspray",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 7,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [8] = {
            name = "taser_cartridge",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 8,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [9] = {
            name = "weapon_beanbag",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 9,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [10] = {
            name = "gps_panel",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 10,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [11] = {
            name = "gps_panel",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 11,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [12] = {
            name = "vehicle_gps",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 12,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [13] = {
            name = "player_gps",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 13,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [14] = {
            name = "vestplate_police",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 14,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [15] = {
            name = "weapon_pistol",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 15,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 1}
        },
        [16] = {
            name = "ammo-9",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 16,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 5}
        },
        [17] = {
            name = "doc_tablet",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 17,
            authorizedJobGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
            quick = {equip = true, amount = 5}
        },
    }
}

Config.EatDrinkItems = {
    ['jail_crack'] = {
        addamount = math.random(5,10), --amount to add to food or drink
        stresreleave = 50,
        consumetime = 12, --seconds
        isalcohol = false, -- false for no alcohol
        effect = 'crackbaggyeffect', --check effect list
        effectAddAmount = {count = 15, amount = 4},
        runspeed = {
            stamina = 8, -- how many seconds it last. FALSE to disable
            multiply = 1.5, -- 1 is default speed
            losechance = 50, -- every second while stamina it checks lower than this number to lose it earlier
        },
        propinfo = {
            animation = 'drugs', -- EAT DRINK WARMDRINK SMOKE DRUGS
            proppos = {
                prop = 'prop_syringe_01', --propname
                bone = 57005,
                xPos = 0.13000,
                yPos = -0.030500,
                zPos = -0.01000,
                xRot = 90.0,
                yRot = 16.0,
                zRot = 0.0,
            }
        },
        reward = {
            item = nil,
            amount = 1
        },
        policeambu = {
            enable = false, --If only for ambu or police
            die = false -- if player die ture else ragdoll
        }
    },
    ['xtcbaggy'] = {
        addamount = math.random(5,10), --amount to add to food or drink
        stresreleave = 50,
        consumetime = 12, --seconds
        isalcohol = false, -- false for no alcohol
        effect = 'cokebaggyeffect', --check effect list
        effectAddAmount = {count = 15, amount = 4},
        runspeed = {
            stamina = 8, -- how many seconds it last. FALSE to disable
            multiply = 1.5, -- 1 is default speed
            losechance = 50, -- every second while stamina it checks lower than this number to lose it earlier
        },
        propinfo = {
            animation = 'drugs', -- EAT DRINK WARMDRINK SMOKE DRUGS
            proppos = {
                prop = 'prop_syringe_01', --propname
                bone = 57005,
                xPos = 0.13000,
                yPos = -0.030500,
                zPos = -0.01000,
                xRot = 90.0,
                yRot = 16.0,
                zRot = 0.0,
            }
        },
        reward = {
            item = nil,
            amount = 1
        },
        policeambu = {
            enable = false, --If only for ambu or police
            die = false -- if player die ture else ragdoll
        }
    },
}
