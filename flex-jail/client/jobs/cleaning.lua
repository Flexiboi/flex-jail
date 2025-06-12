local QBCore = exports['qb-core']:GetCoreObject()
local IsPlayerInJail = false
local IsWorking = false
local Props, CleanPed, CurrentObject = {}, nil, nil
local CleanJobZone, TargetZones, Interactions, currentBlip = nil, {}, {}, nil
local CurrentStage = 0

-- Spawn washing job ped
function CleaningPed()
    if CleanPed ~= nil then return end
    CleanPed = LoadPed(Config.Location.peds.cleaning.loc, Config.Location.peds.cleaning.model, Config.Location.peds.cleaning.scenario)
    exports.ox_target:addLocalEntity(CleanPed,{
        {
            name = Lang:t('target.job.howto'),
            label = Lang:t('target.job.howto'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    if IsInJail then
                        TriggerEvent('QBCore:Notify', Lang:t('info.job.cleaning.howto'), 'info', 6000)
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
                        SpawnCleanInteractions()
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
                        UnloadCleanTargets()
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
end

-- Spawn cleaning prop + interaction
function SpawnCleanInteractions()
    UnloadCleanTargets()

    CleanJobZone = PolyZone:Create(Config.Location.jobs.cleaning.area, { name = 'flex-jail:CleaningZone', debugPoly = Config.Debug })
    CleanJobZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
        else
            UnloadCleanTargets()
            IsWorking = false
        end
    end)

    local cleanInf = Config.Location.jobs.cleaning.jobs[math.random(1, #Config.Location.jobs.cleaning.jobs)]
    Interactions.Cleanloc = cleanInf.loc

    CreateThread(function()
        while IsWorking do
            Wait(1)
            local playerPos = GetEntityCoords(PlayerPedId())
            if #(playerPos - Interactions.Cleanloc.xyz) < 5 then
                DrawMarker(2, Interactions.Cleanloc.x, Interactions.Cleanloc.y, Interactions.Cleanloc.z+.2, 0, 0, 0, 0.0, 180.0, 0, 0.1, 0.1, 0.1, 255, 255, 255, 255, true, true, 2, false, nil, nil, false)
            end
        end
    end)

    if cleanInf.prop then
        lib.requestModel(cleanInf.prop)
        Props[#Props + 1] = CreateObject(cleanInf.prop, Interactions.Cleanloc.x, Interactions.Cleanloc.y, Interactions.Cleanloc.z, true, true, false)
        NetworkRegisterEntityAsNetworked(Props[#Props])
        SetEntityAsMissionEntity(Props[#Props], true, true)
        PlaceObjectOnGroundProperly(Props[#Props])
        SetEntityHeading(Props[#Props], Interactions.Cleanloc.w-180)
        
        if DoesEntityExist(Props[#Props]) then
            local netId = NetworkGetNetworkIdFromEntity(Props[#Props])
            SetNetworkIdCanMigrate(netId, true)
            if not NetworkHasControlOfEntity(Props[#Props]) then
                NetworkRequestControlOfEntity(Props[#Props])
                while not NetworkHasControlOfEntity(Props[#Props]) do
                    Wait(0)
                end
            end
        end

        Config.BlipSettings.job.coords = Interactions.Cleanloc
        currentBlip = createBlip(Config.BlipSettings.job)
        exports.ox_target:addLocalEntity(Props[#Props],{			
            {
                name = Lang:t('target.job.cleaning.clean'),
                label = Lang:t('target.job.cleaning.clean'),
                iconColor = 'purple',
                distance = Config.RayCastDistance.cleaning,
                icon = "fa-solid fa-broom",
                anim = cleanInf.anim,
                time = cleanInf.time,
                coords = Interactions.Cleanloc,
                canInteract = function(entity, coords, distance)
                    return IsWorking and (CurrentStage == 0)
                end,
                event = 'flex-jail:client:cleaning:Clean',
            },
        })
    else
        TargetZones[#TargetZones + 1] = exports.ox_target:addBoxZone({
            coords = Interactions.Cleanloc,
            size = vec3(1.0, 1.0, 1.0),
            rotation = Interactions.Cleanloc.w,
            debug = Config.Debug,
            drawSprite = true,
            options = {
                {
                    name = Lang:t('target.job.cleaning.clean'),
                    label = Lang:t('target.job.cleaning.clean'),
                    iconColor = 'purple',
                    distance = Config.RayCastDistance.cleaning,
                    icon = "fa-solid fa-broom",
                    anim = cleanInf.anim,
                    time = cleanInf.time,
                    coords = Interactions.Cleanloc,
                    canInteract = function(entity, coords, distance)
                        return IsWorking and (CurrentStage == 0)
                    end,
                    event = 'flex-jail:client:cleaning:Clean',
                }
            }
        })
    end
end

-- Start cleaning event
RegisterNetEvent('flex-jail:client:cleaning:Clean', function(data)
    lookEnt(data.coords)
    if lib.progressBar({
        duration = data.time * 1000,
        label = Lang:t('progress.job.cleaning.clean'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = data.anim.dic,
            clip = data.anim.anim,
        },
        prop = {
            model = data.anim.prop,
            bone = data.anim.bone,
            pos = {
                x = data.anim.PropPlacement[1],
                y = data.anim.PropPlacement[2],
                z = data.anim.PropPlacement[3]
            },
            rot = {
                x = data.anim.PropPlacement[4],
                y = data.anim.PropPlacement[5],
                z = data.anim.PropPlacement[6]
            },
        }
    }) then
        for k, v in pairs(Props) do
            if DoesEntityExist(v) then
                DeleteObject(v)
            end
            exports.ox_target:removeLocalEntity(v)
        end
        TriggerServerEvent('flex-jail:server:AddJailPoints', nil, 'cleaning')
        TriggerServerEvent('flex-jail:server:GiveReward', nil, 'washing')
        SpawnCleanInteractions()
    end
end)

-- Unload all zones
function UnloadCleanTargets()
    for k, v in pairs(TargetZones) do
        exports.ox_target:removeZone(v)
    end
    if CleanJobZone then
        CleanJobZone:destroy()
    end
    exports.ox_target:removeGlobalPed(CleanPed)
    if DoesBlipExist(currentBlip) then
        RemoveBlip(currentBlip)
    end
    for k, v in pairs(Props) do
        if DoesEntityExist(v) then
            DeleteObject(v)
        end
        exports.ox_target:removeLocalEntity(v)
    end
end

-- Clear all events when left jail
RegisterNetEvent('flex-jail:client:ClearEvents', function()
    UnloadCleanTargets()
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
    exports.ox_target:removeLocalEntity(CleanPed)
end)

-- On resource stop
AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        UnloadCleanTargets()
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
        exports.ox_target:removeLocalEntity(CleanPed)
    end
end)