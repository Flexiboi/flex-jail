local QBCore = nil 
local ESX = nil

local qb_target = Config.XTC.qb_target 
local ox_target = Config.XTC.ox_target

local isCrafting = false

if Config.XTC.framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.XTC.framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end

if Config.XTC.target == "qb" then
    qb_target = true
    ox_target = false
elseif Config.XTC.target == "ox" then
    qb_target = false
    ox_target = true
end


-- load anim

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

Citizen.CreateThread(function()
    
    RequestModel(Config.XTC.ped.model)
    while not HasModelLoaded(Config.XTC.ped.model) do
        Wait(0)
    end
    local ped = CreatePed(0, Config.XTC.ped.model, Config.XTC.ped.coords.x, Config.XTC.ped.coords.y, Config.XTC.ped.coords.z, Config.XTC.ped.coords.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
 
    Wait(500)
    if qb_target then 
        exports['qb-target']:AddBoxZone("prisontrade", vector3(Config.XTC.ped.coords.x, Config.XTC.ped.coords.y, Config.XTC.ped.coords.z+1), Config.XTC.ped.length, Config.XTC.ped.width, {
        name = "PrisonTrade",
        heading = Config.XTC.ped.heading,
        debugPoly = Config.XTC.ped.debugPoly,
        minZ = Config.XTC.ped.minZ,
        maxZ = Config.XTC.ped.maxZ,
        }, {
            options = {
                {
                    num = 1,
                    type = "client",
                    event = "solos-xtc:client:prisontrade",
                    icon = 'fa-solid fa-repeat',
                    label = 'Wil je iets omruilen?',
                }
            },
            distance = 1.5,
        })
    elseif ox_target then
        local pedoptions = {
            {
                name = 'prisonped',
                icon = 'fa-solid fa-repeat',
                label = 'Wil je iets omruilen?',
                onSelect = function(action, recipes)
                    TriggerEvent('solos-xtc:client:prisontrade') 
                end,
            },
        }

        exports.ox_target:addBoxZone({
            coords = Config.XTC.ped.coords,
            size = Config.XTC.ped.size,
            rotation = Config.XTC.ped.heading,
            debug = Config.XTC.ped.debugPoly,
            options = pedoptions,
        })
    end
 end)

RegisterNetEvent('solos-xtc:client:prisontrade', function()
    local ped = PlayerPedId()
    if QBCore then 
        local hasItem = exports.ox_inventory:Search('count', Config.XTC.tradeitem) or QBCore.Functions.HasItem(Config.XTC.tradeitem)
        lookEnt(Config.XTC.ped.coords)
        if not hasItem then
            hasItem = 0
        end
        if hasItem and hasItem > 0 then 
            QBCore.Functions.Progressbar("spawn_object", ("Wisselen.."), 1000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "anim@narcotics@trash",
                anim = "drop_front",
                flags = 16,
            }, {}, {}, function() -- Done
                StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)

                TriggerServerEvent('solos-xtc:server:itemremove', Config.XTC.tradeitem, 1, true) 
                TriggerServerEvent('solos-xtc:server:itemremove', Config.XTC.bagitem, 1, true) 
                if GetResourceState('ox_inventory') == 'missing' then
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.XTC.tradeitem], "remove") -- notify
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.XTC.bagitem], "remove") -- notify
                end
                Wait(1000)
                TriggerServerEvent('solos-xtc:server:itemadd', 'aluminumoxide', 1, false) -- add aluminum oxide
                if GetResourceState('ox_inventory') == 'missing' then
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["aluminumoxide"], "add") -- notify aluminumoxide added
                end
            end)
        else
            TriggerEvent('solos-xtc:client:tradeerror')
        end
    elseif ESX then
        local hasitem = ESX.SearchInventory(Config.XTC.tradeitem)
        if hasitem then 
            ESX.Progressbar("Wisselen..", 1000,{
                FreezePlayer = false, 
                animation = {
                    type = "anim",
                    dict = "anim@narcotics@trash",
                    lib = "drop_front",
                },
                onFinish = function()
                    StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)

                    TriggerServerEvent('solos-xtc:server:itemremove', Config.XTC.tradeitem, 1, true) 
                    Wait(1000)
                    TriggerServerEvent('solos-xtc:server:itemadd', 'aluminumoxide', 1, false) -- add aluminum oxide
                end, onCancel = function()
                    ClearPedTasksImmediately(PlayerPedId())
                end 
            })
        else
            TriggerEvent('solos-xtc:client:tradeerror')
        end
    end
    
end)

-- toilet craft
RegisterNetEvent('solos-xtc:client:xtccraft', function()
    lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
        if time then
            if time > 0 then
                QBCore.Functions.Notify(Lang:t("error.notworthy"), 'error', 3000)
            elseif time == -1 then
                if QBCore then 
                    local hasItem1 = exports.ox_inventory:Search('count', Config.XTC.oxide) or QBCore.Functions.HasItem(Config.XTC.oxide)
                    local hasItem2 = exports.ox_inventory:Search('count', Config.XTC.tradeitem) or QBCore.Functions.HasItem(Config.XTC.tradeitem)
                    local hasItem3 = exports.ox_inventory:Search('count', Config.XTC.bagitem) or QBCore.Functions.HasItem(Config.XTC.bagitem)
                        
                    if hasItem1 and hasItem2 and hasItem3 and not isCrafting and hasItem1 > 0 and hasItem2 > 0 and hasItem3 > 0 then
                        lookEnt(Config.XTC.toiletcraft.coords)
                        isCrafting = true
                        QBCore.Functions.Progressbar("spawn_object", ("Maken.."), Config.XTC.toiletcraft.time, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "amb@prop_human_bum_bin@idle_a",
                            anim = "idle_a",
                            flags = 11,
                        }, {}, {}, function() -- Done
                            StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
                                -- remove aluminumoxide
                            TriggerServerEvent('solos-xtc:server:itemremove', 'aluminumoxide', 1, true) 
                            if GetResourceState('ox_inventory') == 'missing' then
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["aluminumoxide"], "remove") -- notify
                            end
                                -- remove unknown pills
                            TriggerServerEvent('solos-xtc:server:itemremove', 'painkillers', 1, true) 
                            if GetResourceState('ox_inventory') == 'missing' then
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["painkillers"], "remove") -- notify
                            end
                                -- remove empty baggies
                            TriggerServerEvent('solos-xtc:server:itemremove', 'empty_weed_bag', 1, true) 
                            if GetResourceState('ox_inventory') == 'missing' then
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["empty_weed_bag"], "remove") -- notify
                            end
                            Wait(1500)
                            -- Receive xtc
                            if GetResourceState('ox_inventory') == 'missing' then
                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["xtcbaggy"], "add") -- notify xtc added
                            end
                            TriggerServerEvent('solos-xtc:server:itemadd', 'xtcbaggy', 1, false) -- add empty_weed_bag
                            SetTimeout(1000, function()
                                isCrafting = false
                            end)
                        end, function() --cancel
                            StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
                            SetTimeout(1000, function()
                                isCrafting = false
                            end)
                        end)
                    else --If missing - error
                        QBCore.Functions.Notify("Je mist nog iets..", "error")
                    end
                elseif ESX then
                    local hasitem1 = ESX.SearchInventory('aluminumoxide')
                    local hasitem2 = ESX.SearchInventory('painkillers')
                    local hasitem3 = ESX.SearchInventory(Config.XTC.bagitem)
                    if hasitem1 and hasitem2 and hasitem3 then 
                        ESX.Progressbar("Maken..", Config.XTC.toiletcraft.time,{
                            FreezePlayer = false, 
                            animation = {
                                type = "anim",
                                dict = "amb@prop_human_bum_bin@idle_a",
                                lib = "idle_a",
                            },
                            onFinish = function()
                                StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
                                -- remove aluminumoxide
                                TriggerServerEvent('solos-xtc:server:itemremove', 'aluminumoxide', 1, true) 
                                -- remove unknown pills
                                TriggerServerEvent('solos-xtc:server:itemremove', 'painkillers', 1, true) 
                                -- remove empy baggies
                                TriggerServerEvent('solos-xtc:server:itemremove', 'empty_weed_bag', 1, true) 
                                Wait(1500)
                                -- Receive xtc
                                TriggerServerEvent('solos-xtc:server:itemadd', 'xtcbaggy', 1, false) -- add empty_weed_bag
                            end, onCancel = function()
                                StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
                            end 
                        })
                    else
                        TriggerEvent('solos-xtc:client:crafterror')
                    end
                end
            end
        end
    end, id)
end)

local function AddWeed()
    TriggerServerEvent('solos-xtc:server:itemadd', Config.XTC.bagitem, 1, false) -- add empty bag
    if QBCore then 
        if GetResourceState('ox_inventory') == 'missing' then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.XTC.bagitem], "add") -- notify empty bag added
        end
    end
end

-- empty weed bag add
RegisterNetEvent('solos-xtc:client:addweedbag', function()
    lookEnt(Config.XTC.weedbag.coords)
    if QBCore then 
        QBCore.Functions.Progressbar("spawn_object", ("Zoeken.."), Config.XTC.weedbag.time, false, true, {   
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@idle_a",
            anim = "idle_a",
            flags = 11,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
            AddWeed()
        end, function() --cancel
            StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
        end)
    elseif ESX then
        ESX.Progressbar("Zoeken..", Config.XTC.weedbag.time, {
            FreezePlayer = false, 
            animation = {
                type = "anim",
                dict = "amb@prop_human_bum_bin@idle_a",
                lib = "idle_a",
            },
            onFinish = function()
                StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
                AddWeed()
            end, onCancel = function()
                StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
            end 
        })
    end
end)


-- Unknown Pills add
RegisterNetEvent('solos-xtc:client:addpills', function()
    lookEnt(Config.XTC.pills.coords)
    if QBCore then 
        QBCore.Functions.Progressbar("spawn_object", ("Doorzoeken.."), Config.XTC.pills.time, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@idle_a",
            anim = "idle_a",
            flags = 11,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
            TriggerServerEvent('solos-xtc:server:itemadd', 'painkillers', 1, false) -- add painkillers
            if GetResourceState('ox_inventory') == 'missing' then
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["painkillers"], "add") -- notify painkillers
            end
        end, function() --cancel
            StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
        end)
    elseif ESX then 
        ESX.Progressbar("Doorzoeken..", Config.XTC.pills.time, {
            FreezePlayer = false, 
            animation = {
                type = "anim",
                dict = "amb@prop_human_bum_bin@idle_a",
                lib = "idle_a",
            },
            onFinish = function()
                StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
                TriggerServerEvent('solos-xtc:server:itemadd', 'painkillers', 1, false) -- add painkillers
            end, onCancel = function()
                StopAnimTask(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0)
            end 
        })
    end
    
end)

Citizen.CreateThread(function()
    if QBCore then 
        -- toilet craft circle zone
        exports['qb-target']:AddBoxZone("toiletcraft", vector3(Config.XTC.toiletcraft.coords.x, Config.XTC.toiletcraft.coords.y, Config.XTC.toiletcraft.coords.z), Config.XTC.toiletcraft.length, Config.XTC.toiletcraft.width, {
            name = "WC Doorzoeken",
            heading = Config.XTC.toiletcraft.heading,
            maxZ = Config.XTC.toiletcraft.maxZ,
            minZ = Config.XTC.toiletcraft.minZ,
            debugPoly = Config.XTC.toiletcraft.debugPoly,
        }, {
            options = {
                {
                    type = "client",
                    event = "solos-xtc:client:xtccraft",
                    icon = "fa-solid fa-toilet",
                    label = "Maken",
                },
            },
            distance = 2.0
        })

        -- trash bin zone
        exports['qb-target']:AddCircleZone("prisonbin", Config.XTC.weedbag.coords, Config.XTC.weedbag.radius, {
            name = "Vuilbak",
            heading = Config.XTC.weedbag.heading,
            debugPoly = Config.XTC.weedbag.debugPoly,
        }, {
            options = {
                {
                    type = "client",
                    event = "solos-xtc:client:addweedbag",
                    icon = "fa-solid fa-magnifying-glass",
                    label = "Zoeken",
                },
            },
            distance = 2.0
        })

        -- find pills zone
        exports['qb-target']:AddBoxZone("findpills", Config.XTC.pills.coords, Config.XTC.pills.length, Config.XTC.pills.width, {
            name = "Zoek Pillen",
            heading = Config.XTC.pills.heading,
            maxZ = Config.XTC.pills.maxZ,
            minZ = Config.XTC.pills.minZ,
            debugPoly = Config.XTC.pills.debugPoly,
        }, {
            options = {
                {
                    type = "client",
                    event = "solos-xtc:client:addpills",
                    icon = "fa-solid fa-magnifying-glass",
                    label = " Zoeken",
                },
            },
            distance = 2.0
        })
    elseif ESX then 
        local toiletoptions = {
            {
                event = "solos-xtc:client:xtccraft",
                icon = "fas fa-toilet",
                label = "Maken",
            },
        }
        local pillsoptions = {
            {
                event = "solos-xtc:client:addpills",
                icon = "fas fa-magnifying-glass",
                label = "Zoeken",
            },
        }
        local bagoptions = {
            {
                event = "solos-xtc:client:addweedbag",
                icon = "fas fa-magnifying-glass",
                label = "Zoeken",
            },
        }

        exports.ox_target:addBoxZone({
            coords = Config.XTC.toiletcraft.coords,
            size = Config.XTC.toiletcraft.size,
            rotation = Config.XTC.toiletcraft.heading,
            debug = Config.XTC.toiletcraft.debugPoly,
            options = toiletoptions,
        })
        exports.ox_target:addBoxZone({
            coords = Config.XTC.pills.coords,
            size = Config.XTC.pills.size,
            rotation = Config.XTC.pills.heading,
            debug = Config.XTC.pills.debugPoly,
            options = pillsoptions,
        })
        exports.ox_target:addBoxZone({
            coords = Config.XTC.weedbag.coords,
            size = Config.XTC.weedbag.size,
            rotation = Config.XTC.weedbag.heading,
            debug = Config.XTC.weedbag.debugPoly,
            options = bagoptions,
        })
    end
end)


local function XTCEffect()
    local startStamina = 30
    SetFlash(0, 0, 500, 7000, 500)
    while startStamina > 0 do
        Wait(1000)
        startStamina -= 1
        RestorePlayerStamina(PlayerId(), 1.0)
        if math.random(1, 100) < 51 then
            SetFlash(0, 0, 500, 7000, 500)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
        end
    end
    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
    end
end

exports('usextc', function(data, slot)
    local ped = PlayerPedId()
    
    exports.ox_inventory:useItem(data, function(data)
        -- The item has been used, so trigger the effects
        if data then
            XTCEffect()
        end
    end)
    
end)

local QBCore = nil 
local ESX = nil

if Config.XTC.framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.XTC.framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end

RegisterNetEvent('solos-xtc:client:tradeerror', function()
    if QBCore then 
        QBCore.Functions.Notify("Je hebt niet wat ik nodig heb..", "error")
    elseif ESX then
        ESX.ShowNotification("Je hebt niet wat ik nodig heb..")
    end
end)

RegisterNetEvent('solos-xtc:client:crafterror', function()
    if QBCore then 
        QBCore.Functions.Notify("Je hebt de juiste spullen niet..", "error")
    elseif ESX then
        ESX.ShowNotification("Je hebt de juiste spullen niet..")
    end
end)
