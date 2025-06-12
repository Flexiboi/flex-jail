local QBCore = exports['qb-core']:GetCoreObject()
local IsPlayerInJail = false
local IsWorking = false
local WashingJobZone, TargetZones, Interactions, WashPed = nil, {}, {}, nil
local CurrentObject = nil
local CurrentStage = 0

-- Spawn washing job ped
function WashingPed()
    if WashPed ~= nil then return end
    WashPed = LoadPed(Config.Location.peds.washing.loc, Config.Location.peds.washing.model, Config.Location.peds.washing.scenario)
    exports.ox_target:addLocalEntity(WashPed,{		
        {
            name = Lang:t('target.job.howto'),
            label = Lang:t('target.job.howto'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    if IsInJail then
                        TriggerEvent('QBCore:Notify', Lang:t('info.job.washing.howto'), 'info', 6000)
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
                        IsPlayerInJail = IsInJail
                        SpawnWashInteractions()
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
                        UnloadWashTargets()
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

-- Spawn washing interactions
function SpawnWashInteractions()
    UnloadWashTargets()

    WashingJobZone = PolyZone:Create(Config.Location.jobs.washing.area, { name = 'flex-jail:washingzone', debugPoly = Config.Debug })
    WashingJobZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
        else
            UnloadWashTargets()
            IsWorking = false
        end
    end)

    Interactions.Take = Config.Location.jobs.washing.takeclothes[math.random(1, #Config.Location.jobs.washing.takeclothes)]
    Interactions.Wash = Config.Location.jobs.washing.washclothes[math.random(1, #Config.Location.jobs.washing.washclothes)]
    Interactions.Store = Config.Location.jobs.washing.storeclothes[math.random(1, #Config.Location.jobs.washing.storeclothes)]

    CreateThread(function()
        while IsWorking do
            Wait(1)
            local playerPos = GetEntityCoords(PlayerPedId())
            if #(playerPos - Interactions.Take.xyz) < 5 and CurrentStage == 0 then
                DrawMarker(2, Interactions.Take.x, Interactions.Take.y, Interactions.Take.z+.6, 0, 0, 0, 0.0, 180.0, 0, 0.1, 0.1, 0.1, 255, 255, 255, 255, true, true, 2, false, nil, nil, false)
            end
            if #(playerPos - Interactions.Wash.xyz) < 5 and (CurrentStage == 1 or CurrentStage == 3) then
                DrawMarker(2, Interactions.Wash.x, Interactions.Wash.y, Interactions.Wash.z+.2, 0, 0, 0, 0.0, 180.0, 0, 0.1, 0.1, 0.1, 255, 255, 255, 255, true, true, 2, false, nil, nil, false)
            end
            if #(playerPos - Interactions.Store.xyz) < 5 and CurrentStage == 4 then
                DrawMarker(2, Interactions.Store.x, Interactions.Store.y, Interactions.Store.z+.2, 0, 0, 0, 0.0, 180.0, 0, 0.1, 0.1, 0.1, 255, 255, 255, 255, true, true, 2, false, nil, nil, false)
            end
        end
    end)

    TargetZones[#TargetZones + 1] = exports.ox_target:addBoxZone({
        coords = Interactions.Take,
        size = vec3(1.0, 1.0, 1.0),
        rotation = Interactions.Take.w,
        debug = Config.Debug,
        drawSprite = true,
        options = {
            {
                iconColor = 'purple',
                distance = Config.RayCastDistance.washing,
                name = Lang:t('target.job.washing.take'),
                event = 'flex-jail:client:washing:TakeClothes',
                icon = "fa-solid fa-shirt",
                label = Lang:t('target.job.washing.take'),
                canInteract = function(entity, coords, distance)
                    return IsWorking and (CurrentStage == 0)
                end,
            }
        }
    })

    TargetZones[#TargetZones + 1] = exports.ox_target:addBoxZone({
        coords = Interactions.Wash,
        size = vec3(1.3, 1.3, 1.3),
        rotation = Interactions.Wash.w,
        debug = Config.Debug,
        drawSprite = true,
        options = {
            {
                iconColor = 'purple',
                distance = Config.RayCastDistance.washing,
                name = Lang:t('target.job.washing.wash'),
                event = 'flex-jail:client:washing:PutTakeOutMachine',
                icon = "fa-solid fa-hand-point-up",
                label = Lang:t('target.job.washing.startwash'),
                coords = Interactions.Wash,
                canInteract = function(entity, coords, distance)
                    return IsWorking and (CurrentStage == 1)
                end,
            },
            {
                iconColor = 'purple',
                distance = Config.RayCastDistance.washing,
                name = Lang:t('target.job.washing.wash'),
                event = 'flex-jail:client:washing:PutTakeOutMachine',
                icon = "fa-solid fa-hand-back-fist",
                label = Lang:t('target.job.washing.stopwash'),
                coords = Interactions.Wash,
                canInteract = function(entity, coords, distance)
                    return IsWorking and (CurrentStage == 3)
                end,
            }
        }
    })

    TargetZones[#TargetZones + 1] = exports.ox_target:addBoxZone({
        coords = Interactions.Store,
        size = vec3(1.0, 1.0, 1.0),
        rotation = Interactions.Store.w,
        debug = Config.Debug,
        drawSprite = true,
        options = {
            {
                iconColor = 'purple',
                distance = Config.RayCastDistance.washing,
                name = Lang:t('target.job.washing.store'),
                event = 'flex-jail:client:washing:StoreClothes',
                icon = "fa-solid fa-box-archive",
                label = Lang:t('target.job.washing.store'),
                canInteract = function(entity, coords, distance)
                    return IsWorking and (CurrentStage == 4)
                end,
            }
        }
    })
end

-- Event to take clothes
RegisterNetEvent('flex-jail:client:washing:TakeClothes', function()
    if CurrentStage == 0 then
        CurrentStage = 1
        local ped = PlayerPedId()
        PlayAnim("anim@heists@box_carry@", "idle", true)
        local coords = GetEntityCoords(ped)
        lib.requestModel("prop_ld_tshirt_01")
        CurrentObject = CreateObject("prop_ld_tshirt_01", coords.x, coords.y, coords.z, true, true, false)
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
            while CurrentStage == 1 do
                Wait(1000)
                if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                    PlayAnim("anim@heists@box_carry@", "idle", true)
                end
            end
        end)
    end
end)

-- Event to put clothes inside machine
RegisterNetEvent('flex-jail:client:washing:PutTakeOutMachine', function(data)
    if CurrentStage == 1 then
        CurrentStage = 2
        local ped = PlayerPedId()
        PlayAnim('mp_car_bomb', 'car_bomb_mechanic', false)
        Wait(1300)
        ClearPedTasks(PlayerPedId())
        if DoesEntityExist(CurrentObject) then
            DeleteObject(CurrentObject)
        end
        local time = Config.JobSettings.washing.washtime
        CreateThread(function()
            while CurrentStage == 2 do
                Wait(1000)
                time -= 1
            end
        end)
        CreateThread(function()
            while CurrentStage == 2 do
                DrawText3Ds(data.coords, Lang:t('info.job.washing.washtime',{value = time}))
                Wait(1)
            end
        end)
        SetTimeout(1000*Config.JobSettings.washing.washtime, function()
            CurrentStage = 3
        end)
    elseif CurrentStage == 3 then
        CurrentStage = 4
        local ped = PlayerPedId()
        PlayAnim('mp_car_bomb', 'car_bomb_mechanic', false)
        Wait(1300)
        ClearPedTasks(PlayerPedId())
        PlayAnim("anim@heists@box_carry@", "idle", true)
        local coords = GetEntityCoords(ped)
        lib.requestModel("prop_ld_tshirt_01")
        CurrentObject = CreateObject("prop_ld_tshirt_01", coords.x, coords.y, coords.z, true, true, false)
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
            while CurrentStage == 1 do
                Wait(1000)
                if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                    PlayAnim("anim@heists@box_carry@", "idle", true)
                end
            end
        end)
    end
end)

-- Event to store clothes
RegisterNetEvent('flex-jail:client:washing:StoreClothes', function()
    if CurrentStage == 4 then
        CurrentStage = 0
        local ped = PlayerPedId()
        PlayAnim('mp_car_bomb', 'car_bomb_mechanic', false)
        Wait(1300)
        ClearPedTasks(PlayerPedId())
        if DoesEntityExist(CurrentObject) then
            DeleteObject(CurrentObject)
        end
        TriggerServerEvent('flex-jail:server:AddJailPoints', nil, 'washing')
        TriggerServerEvent('flex-jail:server:GiveReward', nil, 'washing')
        SpawnWashInteractions()
    end
end)

-- Unload all zones
function UnloadWashTargets()
    for k, v in pairs(TargetZones) do
        exports.ox_target:removeZone(v)
    end
    if WashingJobZone then
        WashingJobZone:destroy()
    end
    exports.ox_target:removeGlobalPed(WashPed)
end

-- Clear all events when left jail
RegisterNetEvent('flex-jail:client:ClearEvents', function()
    UnloadWashTargets()
    if CurrentStage ~= 0 then
        ClearPedTasks(PlayerPedId())
        if DoesEntityExist(CurrentObject) then
            DeleteObject(CurrentObject)
        end
    end
end)

-- On resource stop
AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        UnloadWashTargets()
        if CurrentStage ~= 0 then
            ClearPedTasks(PlayerPedId())
            if DoesEntityExist(CurrentObject) then
                DeleteObject(CurrentObject)
            end
        end
    end
end)