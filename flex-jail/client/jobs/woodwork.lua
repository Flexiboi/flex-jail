local QBCore = exports['qb-core']:GetCoreObject()
local IsPlayerInJail = false
local IsWorking = false
local Props, WoodPed = {}, nil
local WoodWorkZones, sawingZones, TargetZones = {}, {}, {}
local CurrentStage = 0

-- Spawn washing job ped
function WoodWorkPed()
    if WoodPed ~= nil then return end
    WoodPed = LoadPed(Config.Location.peds.wood.loc, Config.Location.peds.wood.model, Config.Location.peds.wood.scenario)
    exports.ox_target:addLocalEntity(WoodPed,{		
        {
            name = Lang:t('target.job.howto'),
            label = Lang:t('target.job.howto'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    if IsInJail then
                        TriggerEvent('QBCore:Notify', Lang:t('info.job.wood.howto'), 'info', 6000)
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
                        SpawnWoodInteractions()
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
        {
            name = Lang:t('target.job.wood.sell'),
            label = Lang:t('target.job.wood.sell'),
            distance = 3.0,
            icon = "fa-solid fa-money-bill",
            onSelect = function(args)
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    if IsInJail then
                        lookEnt(Config.Location.peds.wood.loc.xyz)
                        TriggerServerEvent('flex-jail:server:wood:Sell')
                        -- PlayAnim("givetake1_a", "mp_common", false)
                    end
                end)
            end,
        },		
    })
    for k, v in pairs(Config.Location.jobs.wood.sawing) do
        if v.spawnprop then
            lib.requestModel(v.prop)
            Props[#Props + 1] = CreateObject(v.prop, v.loc.x, v.loc.y, v.loc.z, true, true, false)
            SetEntityAsMissionEntity(Props[#Props], true, true)
            PlaceObjectOnGroundProperly(Props[#Props])
            SetEntityHeading(Props[#Props], v.loc.w-180)
            exports.ox_target:addLocalEntity(Props[#Props],{			
                {
                    name = Lang:t('target.job.wood.sawing'),
                    label = Lang:t('target.job.wood.sawing'),
                    iconColor = 'purple',
                    distance = Config.RayCastDistance.washing,
                    icon = "fa-solid fa-scissors",
                    coords = v.loc,
                    canInteract = function(entity, coords, distance)
                        return IsWorking and (CurrentStage == 1)
                    end,
                    event = 'flex-jail:client:woodwork:Saw',
                },
            })
        else
            sawingZones[#sawingZones + 1] = exports.ox_target:addBoxZone({
                coords = v.loc,
                size = vec3(1.0, 1.0, 3.0),
                rotation = 0.0,
                debug = Config.Debug,
                drawSprite = true,
                options = {
                    {
                        name = Lang:t('target.job.wood.sawing'),
                        label = Lang:t('target.job.wood.sawing'),
                        event = 'flex-jail:client:woodwork:Saw',
                        icon = "fa-solid fa-scissors",
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
function SpawnWoodInteractions()

    WoodJobZone = PolyZone:Create(Config.Location.jobs.wood.area, { name = 'flex-jail:MiningZone', debugPoly = Config.Debug })
    WoodJobZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
        else
            IsWorking = false
        end
    end)

    TargetZones[#TargetZones + 1] = exports.ox_target:addBoxZone({
        coords = Config.Location.jobs.wood.takewood.xyz,
        size = vec3(1.0, 2.0, 2.0),
        rotation = Config.Location.jobs.wood.takewood.w,
        debug = Config.Debug,
        drawSprite = true,
        options = {
            {
                name = Lang:t('target.job.wood.takewood'),
                label = Lang:t('target.job.wood.takewood'),
                event = 'flex-jail:client:wood:TakeWood',
                icon = "fa-solid fa-hand",
                iconColor = 'purple',
                distance = Config.RayCastDistance.washing,
                coords = Config.Location.jobs.wood.takewood,
                canInteract = function(entity, coords, distance)
                    return IsWorking and (CurrentStage == 0)
                end,
            }
        }
    })
end

-- Take wood event
RegisterNetEvent('flex-jail:client:wood:TakeWood', function(data)
    CurrentStage = 1
    local ped = PlayerPedId()
    lookEnt(data.coords)
    PlayAnim('mp_car_bomb', 'car_bomb_mechanic', false)
    Wait(1300)
    ClearPedTasks(PlayerPedId())
    PlayAnim("anim@heists@box_carry@", "idle", true)
    local coords = GetEntityCoords(ped)
    lib.requestModel("prop_snow_fncwood_14a")
    CurrentObject = CreateObject("prop_snow_fncwood_14a", coords.x, coords.y, coords.z, true, true, false)
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

    AttachEntityToEntity(CurrentObject, ped, GetPedBoneIndex(ped, 60309), 0.01, 0.00, -0.005, 0.0, 10.0, 0.0, false, false, false, false, 2, true)
    CreateThread(function()
        while CurrentStage == 1 do
            Wait(1000)
            if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                PlayAnim("anim@heists@box_carry@", "idle", true)
            end
        end
    end)
end)

-- Sawing event
RegisterNetEvent('flex-jail:client:woodwork:Saw', function(data)
    if CurrentStage ~= 1  then return end
    CurrentStage = 2
    DetachEntity(CurrentObject,true,true)
    SetEntityCoords(CurrentObject, data.coords.x, data.coords.y, data.coords.z+.05)
    SetEntityRotation(CurrentObject, 0.0, 90.0, 0.0)
    FreezeEntityPosition(CurrentObject, 1)
    lookEnt(data.coords)
    if lib.progressBar({
        duration = Config.JobSettings.wood.sawtime * 1000,
        label = Lang:t('progress.job.wood.saw'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false,
        },
        prop = {
            model = 'prop_tool_consaw',
            bone = 28422,
            pos = {
                x = 0.0,
                y = -0.0400,
                z = 0.0600,
            },
            rot = {
                x = 0.0,
                y = 0.0,
                z = 90.0,
            },
        },
        anim = {
            dict = 'anim@heists@fleeca_bank@drilling',
            clip = 'drill_straight_end',
        },
    }) then
        if DoesEntityExist(CurrentObject) then
            DeleteObject(CurrentObject)
        end
        TriggerServerEvent('flex-jail:server:AddJailPoints', nil, 'wood')
        TriggerServerEvent('flex-jail:server:GiveReward', nil, 'wood')
        CurrentStage = 0
    end
end)

-- Unload all zones
function UnloadWoodTargets()
    for k, v in pairs(TargetZones) do
        exports.ox_target:removeZone(v)
    end
    if WoodJobZone then
        WoodJobZone:destroy()
    end
    exports.ox_target:removeGlobalPed(WoodPed)
    if DoesBlipExist(currentBlip) then
        RemoveBlip(currentBlip)
    end
end

-- Clear all events when left jail
RegisterNetEvent('flex-jail:client:ClearEvents', function()
    UnloadWoodTargets()
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
    for k, v in pairs(sawingZones) do
        exports.ox_target:removeZone(v)
    end
    exports.ox_target:removeLocalEntity(WoodPed)
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
        for k, v in pairs(WoodWorkZones) do
            exports.ox_target:removeZone(v)
        end
        exports.ox_target:removeLocalEntity(WoodPed)
    end
end)