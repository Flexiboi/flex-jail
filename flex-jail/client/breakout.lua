local QBCore = exports['qb-core']:GetCoreObject()
local BreakOutZones, Entities, Ropes = {}, {}, {}

function AnimateHacking(door, id)
    local animDict = "anim@heists@ornate_bank@hack"

    RequestAnimDict(animDict)
    RequestModel(GetHashKey("hei_prop_hst_laptop"))
    RequestModel(GetHashKey("hei_p_m_bag_var22_arm_s"))
    RequestModel(GetHashKey("hei_prop_heist_card_hack_02"))

    while not HasAnimDictLoaded(animDict)
        or not HasModelLoaded(GetHashKey("hei_prop_hst_laptop"))
        or not HasModelLoaded(GetHashKey("hei_p_m_bag_var22_arm_s"))
        or not HasModelLoaded(GetHashKey("hei_prop_heist_card_hack_02")) do Wait(50)
    end
    local ped = PlayerPedId()
    local targetPosition, targetRotation = GetEntityCoords(ped), GetEntityRotation(ped)
    local AnimOffset = Config.BreakOut[id].offset
    local animPos = vec3(GetEntityCoords(door).x + AnimOffset.x, GetEntityCoords(door).y + AnimOffset.y, GetEntityCoords(door).z + AnimOffset.z)

    local self_bag = {
        drawable = GetPedDrawableVariation(ped, 5),
        texture = GetPedTextureVariation(ped, 5)
    }

    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)

    -- part1
    FreezeEntityPosition(ped, true)
    local netScene = NetworkCreateSynchronisedScene(animPos, GetEntityRotation(door), 2, false, false, 1065353216, 0, 1.0)
    NetworkAddPedToSynchronisedScene(ped, netScene, animDict, "hack_enter", 1.5, -4.0, 1, 16, 1148846080, 0)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), targetPosition, 1, 1, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, "hack_enter_bag", 4.0, -8.0, 1)
    Entities[#Entities+1] = bag
    local laptop = CreateObject(GetHashKey("hei_prop_hst_laptop"), targetPosition, 1, 1, 0)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, "hack_enter_laptop", 4.0, -8.0, 1)
    Entities[#Entities+1] = laptop
    local card = CreateObject(GetHashKey("hei_prop_heist_card_hack_02"), targetPosition, 1, 1, 0)
    NetworkAddEntityToSynchronisedScene(card, netScene, animDict, "hack_enter_card", 4.0, -8.0, 1)
    Entities[#Entities+1] = card

    -- part2
    local netScene2 = NetworkCreateSynchronisedScene(animPos, GetEntityRotation(door), 2, false, true, 1065353216, 0, 0.5)
    NetworkAddPedToSynchronisedScene(ped, netScene2, animDict, "hack_loop", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene2, animDict, "hack_loop_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene2, animDict, "hack_loop_laptop", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(card, netScene2, animDict, "hack_loop_card", 4.0, -8.0, 1)
    
    -- part3
    local netScene3 = NetworkCreateSynchronisedScene(animPos, GetEntityRotation(door), 2, false, false, 1065353216, 0, 1.0)
    NetworkAddPedToSynchronisedScene(ped, netScene3, animDict, "hack_exit", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene3, animDict, "hack_exit_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene3, animDict, "hack_exit_laptop", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(card, netScene3, animDict, "hack_exit_card", 4.0, -8.0, 1)

    SetPedComponentVariation(ped, 5, 0, 0, 0) -- removes bag from ped so no 2 bags

    -- local view_mode = GetFollowPedCamViewMode()
    -- SetFollowPedCamViewMode(4)
    local doorFwd = GetEntityForwardVector(door)
    local door90 = vec(doorFwd.y*-1, doorFwd.x)
    doorFwd = vec(doorFwd.x*-1, doorFwd.y*-1)

    local camPos = vec(animPos.x + doorFwd.x*1.5 + door90.x*1.5, animPos.y + doorFwd.y*1.5 + door90.y*1.5, animPos.z)
    local camHeading = GetHeadingFromVector_2d(animPos.x - camPos.x, animPos.y - camPos.y)

    local hack_cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos, -20.0, 0.0, camHeading,  60.0, false, 0)
    SetCamActive(hack_cam, true)
    RenderScriptCams(true, true, 1000, true, true)

    NetworkStartSynchronisedScene(netScene)
    Wait(GetAnimDuration(animDict, "hack_enter_card")*1000-100)

    NetworkStartSynchronisedScene(netScene2)
    Wait(1000)
    local has_succeeded = Config.BreakOut[id].minigame()
    Config.BreakOut[id].callPolice()
    NetworkStartSynchronisedScene(netScene3)
    Wait(GetAnimDuration(animDict, "hack_exit_card")*1000-100)
    
    DeleteObject(bag)
    DeleteObject(laptop)
    DeleteObject(card)
    FreezeEntityPosition(ped, false)
    SetPedComponentVariation(ped, 5, self_bag.drawable, self_bag.texture, 0) -- gives bag back to ped
    -- SetFollowPedCamViewMode(view_mode)
    SetCamActive(hack_cam, false)
    RenderScriptCams(false, true, 1000, true, true)
    return has_succeeded
end

Citizen.CreateThread(function()
    Wait(1000)
    for k, v in pairs(Config.BreakOut) do
        if not v.rope.isrope then
            BreakOutZones[#BreakOutZones + 1] = exports.ox_target:addBoxZone({
                coords = v.targetcoords.xyz,
                size = vec3(1.0, 1.0, 1.0),
                rotation = 0.0,
                debug = Config.Debug,
                drawSprite = true,
                options = {
                    {
                        name = Lang:t('target.hack'),
                        label = Lang:t('target.hack'),
                        icon = "fa-solid fa-laptop-code",
                        iconColor = 'purple',
                        distance = Config.RayCastDistance.washing,
                        coords = v.targetcoords,
                        onSelect = function()
                            lib.callback('flex-jail:server:IsJobPresent', false, function(ispresent)
                                if ispresent >= Config.MinimumDoc then
                                    if not v.getDoorState() then
                                        lib.callback('flex-jail:server:breakout:HasBreakOutItems', false, function(hasItems)
                                            if hasItems then
                                                local entity = GetClosestObjectOfType(v.targetcoords.x, v.targetcoords.y, v.targetcoords.z, 5.0, v.closestmodel, false, false, false)
            
                                                if entity ~= 0 then
                                                    if AnimateHacking(entity, k) then
                                                        lib.callback('flex-jail:server:breakout:HasBreakOutItems', false, function(hasItems)
                                                            if hasItems then
                                                                TriggerServerEvent('flex-jail:server:breakout:RemoveItems', k)
                                                                v.door()
                                                            end
                                                        end, k)
                                                    end
                                                else
                                                    print('Door not found..')
                                                end
                                            else
                                                if GetResourceState('ox_inventory') == 'missing' then
                                                    local requiredItems = {}
                                                    for k, v in pairs(v.itemsNeeded) do
                                                        requiredItems[#requiredItems+1] = {name = QBCore.Shared.Items[k]["name"], image = QBCore.Shared.Items[k]["image"]}
                                                    end
                                                    TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                                                    SetTimeout(5000, function()
                                                        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                                                    end)
                                                end
                                            end
                                        end, k)
                                    else
                                        if Config.Debug then
                                            print('door open')
                                        end
                                    end
                                else
                                    QBCore.Functions.Notify(Lang:t("info.notrightnow"), 'info', 5000)
                                end
                            end, Config.JobName)
                        end,
                    }
                }
            })
        else
            BreakOutZones[#BreakOutZones + 1] = exports.ox_target:addBoxZone({
                coords = v.targetcoords.xyz,
                size = vec3(2.0, 2.0, 4.0),
                rotation = 0.0,
                debug = Config.Debug,
                drawSprite = true,
                options = {
                    {
                        name = Lang:t('target.rope'),
                        label = Lang:t('target.rope'),
                        icon = "fa-solid fa-stairs",
                        iconColor = 'purple',
                        distance = Config.RayCastDistance.rope,
                        coords = v.targetcoords,
                        event = 'flex-jail:client:breakout:Rope',
                        canInteract = function(entity, coords, distance)
                            return not v.rope.isropeplace
                        end,
                        onSelect = function()
                            lib.callback('flex-jail:server:IsJobPresent', false, function(ispresent)
                                if ispresent >= Config.MinimumDoc and not v.rope.isropeplace then
                                    lib.callback('flex-jail:server:breakout:HasBreakOutItems', false, function(hasItems)
                                        if hasItems then
                                            lookEnt(v.targetcoords.xyz)
                                            PlayAnim('amb@prop_human_movie_bulb@idle_a', 'idle_a', false)
                                            Wait(5000)
                                            ClearPedTasks(PlayerPedId())
                                            local model = joaat("prop_jailrope_01")
                                            if not IsModelInCdimage(model) then
                                                return
                                            end
                                            lib.requestModel("prop_jailrope_01")
                                            Ropes[#Ropes + 1] = CreateObject("prop_jailrope_01", v.targetcoords.x + v.offset.x, v.targetcoords.y + v.offset.y, v.targetcoords.z + v.offset.z, true, true, false)
                                            Wait(5)
                                            SetEntityHeading(Ropes[#Ropes], v.targetcoords.w-180.0)
                                            -- SetEntityRotation(obj, entity.rotation.x, entity.rotation.y, entity.rotation.z)
                                            SetModelAsNoLongerNeeded("prop_jailrope_01")
                                            TriggerServerEvent('flex-jail:server:breakout:RemoveItems', k)  
                                            TriggerServerEvent('flex-jail:server:breakout:RegisterRope', k)
                                            SetTimeout(1000*v.rope.roperemovetime, function()
                                                for k, v in pairs(Ropes) do
                                                    if DoesEntityExist(v) then
                                                        DeleteObject(v)
                                                    end
                                                end
                                            end)
                                        else
                                            local requiredItems = {}
                                            for k, v in pairs(v.itemsNeeded) do
                                                requiredItems[#requiredItems+1] = {name = QBCore.Shared.Items[k]["name"], image = QBCore.Shared.Items[k]["image"]}
                                            end
                                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                                            SetTimeout(5000, function()
                                                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                                            end)
                                        end
                                    end, k)
                                else
                                    QBCore.Functions.Notify(Lang:t("info.notrightnow"), 'info', 5000)
                                end
                            end, Config.JobName)
                        end,
                    },
                    {
                        name = Lang:t('target.climb'),
                        label = Lang:t('target.climb'),
                        icon = "fa-solid fa-person-through-window",
                        iconColor = 'purple',
                        distance = Config.RayCastDistance.washing+5,
                        coords = v.targetcoords,
                        event = 'flex-jail:client:breakout:Rope',
                        canInteract = function(entity, coords, distance)
                            return v.rope.isropeplace
                        end,
                        onSelect = function()
                            lib.callback('flex-jail:server:IsJobPresent', false, function(ispresent)
                                if ispresent >= Config.MinimumDoc and v.rope.isropeplace then
                                    lookEnt(v.targetcoords.xyz)
                                    local ped = PlayerPedId()
                                    DoScreenFadeOut(500)
                                    while not IsScreenFadedOut() do Wait(10) end
                                    PlayAnim('amb@prop_human_movie_bulb@idle_a', 'idle_a', false)
                                    Wait(1500)
                                    ClearPedTasks(PlayerPedId())
                                    SetEntityCoords(ped, v.rope.release.xyz)
                                    SetEntityHeading(ped, v.rope.release.w)
                                    Wait(500)
                                    DoScreenFadeIn(500)
                                else
                                    QBCore.Functions.Notify(Lang:t("info.notrightnow"), 'info', 5000)
                                end
                            end, Config.JobName)
                        end,
                    }
                }
            })
        end
    end
end)

-- Register Rope Event
RegisterNetEvent('flex-jail:client:breakout:RegisterRope', function(id)
    Config.BreakOut[id].rope.isropeplace = true
    SetTimeout(1000*Config.BreakOut[id].rope.roperemovetime, function()
        Config.BreakOut[id].rope.isropeplace = false
    end)
end)

RegisterNetEvent('flex-jail:client:breakout:PayCorruptDoc', function()
    lib.callback('flex-jail:server:IsJobPresent', false, function(ispresent)
        if ispresent >= Config.MinimumDoc then
            lib.callback('flex-jail:server:breakout:PayCorruptDoc', false, function(hasmoney)
                if hasmoney then
                    QBCore.Functions.Notify(Lang:t("info.youdidntseeanything"), 'info', 5000)
                    for k, v in pairs(Config.CurrupNPCDoors.doors) do
                        TriggerServerEvent('flex-jail:server:SetDoorState', v, false)
                    end
                else
                    QBCore.Functions.Notify(Lang:t("error.cantpaycorruptnpc", {value = Config.CurrupNPCDoors.payamount}), 'error', 5000)
                end
            end)
        else
            QBCore.Functions.Notify(Lang:t("info.notrightnow"), 'info', 5000)
        end
    end, Config.JobName)
end)

-- On resource stop
AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        for k, v in pairs(BreakOutZones) do
            exports.ox_target:removeZone(v)
        end
        for k, v in pairs(Entities) do
            if DoesEntityExist(v) then
                DeleteObject(v)
            end
        end
        for k, v in pairs(Ropes) do
            if DoesEntityExist(v) then
                DeleteObject(v)
            end
        end
    end
end)