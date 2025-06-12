local QBCore = exports['qb-core']:GetCoreObject()
local IsPlayerInJail = false
local IsWorking = false
local Props, MinePed, CurrentObject = {}, nil, nil
local MiningJobZone, TargetZones, DrillingZones, Interactions, currentBlip = nil, {}, {}, {}, nil
local CurrentStage = 0

-- Spawn washing job ped
function MiningPed()
    if MinePed ~= nil then return end
    MinePed = LoadPed(Config.Location.peds.mining.loc, Config.Location.peds.mining.model, Config.Location.peds.mining.scenario)
    exports.ox_target:addLocalEntity(MinePed,{		
        {
            name = Lang:t('target.job.howto'),
            label = Lang:t('target.job.howto'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    if IsInJail then
                        TriggerEvent('QBCore:Notify', Lang:t('info.job.mining.howto'), 'info', 6000)
                    end
                end)
            end,
        },		
        {
            name = Lang:t('target.job.startwork'),
            label = Lang:t('target.job.startwork'),
            distance = 3.0,
            icon = 'fas fa-hand',
            canInteract = function(entity, coords, distance)
                return not IsWorking
            end,
            onSelect = function(args)
                if IsWorking then return end
                IsWorking = true
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    if IsInJail then
                        CurrentStage = 0
                        IsPlayerInJail = IsInJail
                        SpawnMineInteractions()
                        TriggerEvent('QBCore:Notify', Lang:t('info.job.startwork'), 'info')
                    end
                end)
            end,
        },
        {
            name = Lang:t('target.job.stopwork'),
            label = Lang:t('target.job.stopwork'),
            distance = 3.0,
            icon = 'fas fa-hand',
            canInteract = function(entity, coords, distance)
                return IsWorking
            end,
            onSelect = function(args)
                if not IsWorking then return end
                IsWorking = false
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    if IsInJail then
                        TriggerEvent('QBCore:Notify', Lang:t('info.job.stopwork'), 'info')
                        IsPlayerInJail = IsInJail
                        CurrentStage = 0
                        UnloadMineTargets()
                        if DoesEntityExist(CurrentObject) then
                            DeleteObject(CurrentObject)
                        end
                        Wait(1000)
                        ClearPedTasks(PlayerPedId())
                    end
                end)
            end,
        },
    })

    if Config.Location.jobs.mining.dropoff.spawnprops then
        for k, v in pairs(Config.Location.jobs.mining.dropoff.loc) do
            lib.requestModel(Config.Location.jobs.mining.dropoff.prop)
            Props[#Props + 1] = CreateObject(Config.Location.jobs.mining.dropoff.prop, v.x, v.y, v.z, false, true, false)
            SetEntityAsMissionEntity(Props[#Props], true, true)
            SetEntityHeading(Props[#Props], v.w)
            PlaceObjectOnGroundProperly(Props[#Props])
            FreezeEntityPosition(Props[#Props],true)
        end
    end
    for k, v in pairs(Config.Location.jobs.mining.drilling) do
        if v.spawnprop then
            lib.requestModel(v.prop)
            Props[#Props + 1] = CreateObject(v.prop, v.loc.x, v.loc.y, v.loc.z, false, true, false)
            SetEntityAsMissionEntity(Props[#Props], true, true)
            PlaceObjectOnGroundProperly(Props[#Props])
            SetEntityHeading(Props[#Props], v.loc.w-180)
            exports.ox_target:addLocalEntity(Props[#Props],{			
                {
                    name = Lang:t('target.job.mining.drilling'),
                    label = Lang:t('target.job.mining.drilling'),
                    iconColor = 'purple',
                    distance = Config.RayCastDistance.washing,
                    icon = "fa-solid fa-scissors",
                    coords = v.loc,
                    canInteract = function(entity, coords, distance)
                        return IsWorking and (CurrentStage == 1)
                    end,
                    event = 'flex-jail:client:mining:Drill',
                },
            })
        else
            DrillingZones[#DrillingZones + 1] = exports.ox_target:addBoxZone({
                coords = v.loc,
                size = vec3(1.0, 1.0, 3.0),
                rotation = 0.0,
                debug = Config.Debug,
                drawSprite = true,
                options = {
                    {
                        name = Lang:t('target.job.mining.drilling'),
                        label = Lang:t('target.job.mining.drilling'),
                        event = 'flex-jail:client:mining:Drill',
                        icon = "fa-solid fa-hammer",
                        iconColor = 'purple',
                        distance = Config.RayCastDistance.washing,
                        coords = v.loc,
                        canInteract = function(entity, coords, distance)
                            return IsWorking and (CurrentStage == 1)
                        end,
                    }
                }
            })
        end
    end
end

-- Spawn Mine interactions
function SpawnMineInteractions()
    UnloadMineTargets()

    MiningJobZone = PolyZone:Create(Config.Location.jobs.mining.area, { name = 'flex-jail:MiningZone', debugPoly = Config.Debug })
    MiningJobZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
        else
            UnloadMineTargets()
            -- TriggerEvent('flex-jail:client:ClearEvents')
            IsWorking = false
        end
    end)

    Interactions.Rock = Config.Location.jobs.mining.rocks[math.random(1, #Config.Location.jobs.mining.rocks)]


    CreateThread(function()
        while IsWorking do
            Wait(1)
            local playerPos = GetEntityCoords(PlayerPedId())
            if #(playerPos - Interactions.Rock.xyz) < 5 then
                DrawMarker(2, Interactions.Rock.x, Interactions.Rock.y, Interactions.Rock.z+.2, 0, 0, 0, 0.0, 180.0, 0, 0.1, 0.1, 0.1, 255, 255, 255, 255, true, true, 2, false, nil, nil, false)
            end
        end
    end)

    Config.BlipSettings.job.coords = Interactions.Rock
    currentBlip = createBlip(Config.BlipSettings.job)
    TargetZones[#TargetZones + 1] = exports.ox_target:addBoxZone({
        coords = Interactions.Rock,
        size = vec3(2.0, 2.0, 2.0),
        rotation = 0.0,
        debug = Config.Debug,
        drawSprite = true,
        options = {
            {
                name = Lang:t('target.job.mining.mine'),
                event = 'flex-jail:client:mining:Mine',
                icon = "fa-solid fa-hammer",
                label = Lang:t('target.job.mining.mine'),
                iconColor = 'purple',
                distance = Config.RayCastDistance.mining,
                canInteract = function(entity, coords, distance)
                    return IsWorking and (CurrentStage == 0)
                end,
            }
        }
    })
end

RegisterNetEvent('flex-jail:client:mining:Mine', function(data)
    local ped = PlayerPedId()
    CurrentStage = 1
    lookEnt(data.coords)
    Wait(1000)
    if lib.progressBar({
        duration = Config.JobSettings.mining.minetime * 1000,
        label = Lang:t('progress.job.mining.mine'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = 'melee@hatchet@streamed_core',
            clip = 'plyr_rear_takedown_b',
        },
        prop = {
            model = 'prop_tool_pickaxe',
            bone = 57005,
            pos = {
                x = 0.12,
                y = -0.05,
                z = -0.02
            },
            rot = {
                x = -78.0,
                y = 53.0,
                z = 28.0
            },
        }
    }) then
        PlayAnim("anim@heists@box_carry@", "idle", true)
        local coords = GetEntityCoords(ped)
        local props = {
            "prop_rock_5_smash2",
            "prop_ld_rubble_02",
            "prop_rock_5_smash1",
            "prop_rock_5_smash3",
        }
        local prop = props[math.random(1,#props)]
        lib.requestModel(prop)
        CurrentObject = CreateObject(prop, coords.x, coords.y, coords.z, true, true, false)
        NetworkRegisterEntityAsNetworked(CurrentObject)
        SetEntityAsMissionEntity(CurrentObject, true, true)
        SetEntityCollision(CurrentObject, false, false)

        if DoesEntityExist(CurrentObject) then
            local netId = NetworkGetNetworkIdFromEntity(CurrentObject)
            SetNetworkIdCanMigrate(netId, true)
            if not NetworkHasControlOfEntity(CurrentObject) then
                NetworkRequestControlOfEntity(CurrentObject)
                while not NetworkHasControlOfEntity(CurrentObject) do
                    Wait(0)
                end
            end
        end

        AttachEntityToEntity(CurrentObject, ped, GetPedBoneIndex(ped, 60309), 0.025, 0.00, 0.255, -5.0, 290.0, 0.0, false, false, false, false, 2, true)
        CreateThread(function()
            while true do
                Wait(1000)
                if CurrentStage == 1 then
                    if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                        PlayAnim("anim@heists@box_carry@", "idle", true)
                    end
                else
                    ClearPedTasks(PlayerPedId())
                    return
                end
            end
        end)
        if DoesBlipExist(currentBlip) then
            RemoveBlip(currentBlip)
        end
        SpawnMineInteractions()
    end
end)

-- Drilling event
RegisterNetEvent('flex-jail:client:mining:Drill', function(data)
    if CurrentStage ~= 1  then return end
    CurrentStage = 2
    DetachEntity(CurrentObject,true,true)
    SetEntityCoords(CurrentObject, data.coords.x, data.coords.y, data.coords.z)
    FreezeEntityPosition(CurrentObject, 1)
    lookEnt(data.coords)
    if lib.progressBar({
        duration = Config.JobSettings.mining.drilltime * 1000,
        label = Lang:t('progress.job.mining.mine'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = 'anim@amb@business@cfm@cfm_machine_oversee@',
            clip = 'watch_production_v2_operator',
        },
    }) then
        if DoesEntityExist(CurrentObject) then
            DeleteObject(CurrentObject)
        end
        local ped = PlayerPedId()
        PlayAnim("anim@heists@box_carry@", "idle", true)
        local coords = GetEntityCoords(ped)
        CurrentObject = CreateObject('gr_prop_gr_2s_drillcrate_01a', coords.x, coords.y, coords.z, true, true, false)
        NetworkRegisterEntityAsNetworked(CurrentObject)
        SetEntityAsMissionEntity(CurrentObject, true, true)
        SetEntityCollision(CurrentObject, false, false)

        if DoesEntityExist(CurrentObject) then
            local netId = NetworkGetNetworkIdFromEntity(CurrentObject)
            SetNetworkIdCanMigrate(netId, true)
            if not NetworkHasControlOfEntity(CurrentObject) then
                NetworkRequestControlOfEntity(CurrentObject)
                while not NetworkHasControlOfEntity(CurrentObject) do
                    Wait(0)
                end
            end
        end
        
        AttachEntityToEntity(CurrentObject, ped, GetPedBoneIndex(ped, 60309), 0.025, 0.00, 0.255, 90.0, 190.0, 0.0, false, false, false, false, 2, true)
        CreateThread(function()
            while true do
                Wait(1000)
                if CurrentStage == 2 then
                    if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                        PlayAnim("anim@heists@box_carry@", "idle", true)
                    end
                else
                    ClearPedTasks(PlayerPedId())
                    return
                end
            end
        end)
        TriggerServerEvent('flex-jail:server:GiveReward', nil, 'mining')

        Interactions.DropOff = Config.Location.jobs.mining.dropoff.loc[math.random(1, #Config.Location.jobs.mining.dropoff.loc)]
        TargetZones[#TargetZones + 1] = exports.ox_target:addBoxZone({
            coords = Interactions.DropOff,
            size = vec3(3.5, 3.5, 3.0),
            rotation = 0.0,
            debug = Config.Debug,
            drawSprite = true,
            options = {
                {
                    iconColor = 'purple',
                    distance = Config.RayCastDistance.mining,
                    name = Lang:t('target.job.mining.dropoff'),
                    event = 'flex-jail:client:mining:DropOff',
                    icon = "fa-solid fa-dolly",
                    label = Lang:t('target.job.mining.dropoff'),
                    canInteract = function(entity, coords, distance)
                        return IsWorking and (CurrentStage == 2)
                    end,
                }
            }
        })
    end
end)

-- Drop of stone crate event
RegisterNetEvent('flex-jail:client:mining:DropOff', function(data)
    if CurrentStage == 2 then
        CurrentStage = 0
        lookEnt(data.coords)
        local ped = PlayerPedId()
        PlayAnim('mp_car_bomb', 'car_bomb_mechanic', false)
        Wait(1300)
        ClearPedTasks(PlayerPedId())
        if DoesEntityExist(CurrentObject) then
            DeleteObject(CurrentObject)
        end
        SpawnMineInteractions()
        TriggerServerEvent('flex-jail:server:AddJailPoints', nil, 'mining')
    end
end)

-- Unload all zones
function UnloadMineTargets()
    for k, v in pairs(TargetZones) do
        exports.ox_target:removeZone(v)
    end
    if MiningJobZone then
        MiningJobZone:destroy()
    end
    exports.ox_target:removeGlobalPed(MinePed)
    if DoesBlipExist(currentBlip) then
        RemoveBlip(currentBlip)
    end
end

-- Clear all events when left jail
RegisterNetEvent('flex-jail:client:ClearEvents', function()
    UnloadMineTargets()
    for k, v in pairs(Props) do
        if DoesEntityExist(v) then
            DeleteObject(v)
        end
        exports.ox_target:removeLocalEntity(v)
    end
    if CurrentStage ~= 0 then
        ClearPedTasks(PlayerPedId())
        if DoesEntityExist(CurrentObject) then
            DeleteObject(CurrentObject)
        end
    end
    for k, v in pairs(DrillingZones) do
        exports.ox_target:removeZone(v)
    end
    exports.ox_target:removeLocalEntity(MinePed)
end)

-- On resource stop
AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        UnloadMineTargets()
        for k, v in pairs(Props) do
            if DoesEntityExist(v) then
                DeleteObject(v)
            end
            exports.ox_target:removeLocalEntity(v)
        end
        if CurrentStage ~= 0 then
            ClearPedTasks(PlayerPedId())
            if DoesEntityExist(CurrentObject) then
                DeleteObject(CurrentObject)
            end
        end
        for k, v in pairs(DrillingZones) do
            exports.ox_target:removeZone(v)
        end
        exports.ox_target:removeLocalEntity(MinePed)
    end
end)