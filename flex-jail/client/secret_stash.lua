local QBCore = exports['qb-core']:GetCoreObject()
local IsCreatingSecretStash = false
local Stashes = {}
local StashZones, StashProps = {}, {}

-- On Player Join
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end
    lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
        if time then
            lib.callback('flex-jail:server:GetSecretStashes', false, function(stashes, IsPolice)
                if stashes then
                    TriggerEvent('flex-jail:client:RegisterNewStash', stashes, IsPolice)
                end
            end)
        end
    end)
end)

-- On resource start
-- AddEventHandler("onResourceStart", function(resourceName)
-- 	if (GetCurrentResourceName() == resourceName) then
--         while not LocalPlayer.state.isLoggedIn do
--             Wait(1000)
--         end
--         lib.callback('flex-jail:server:GetSecretStashes', false, function(stashes, IsPolice)
--             if stashes then
--                 TriggerEvent('flex-jail:client:RegisterNewStash', stashes, IsPolice)
--             end
--         end)
-- 	end
-- end)

-- On Player Job Update
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.type == Config.JobType then
        lib.callback('flex-jail:server:GetSecretStashes', false, function(stashes, IsPolice)
            if stashes then
                TriggerEvent('flex-jail:client:RegisterNewStash', stashes, IsPolice)
            end
        end)
    end
end)

RegisterNetEvent('flex-jail:client:ReloadStashes', function()
    lib.callback('flex-jail:server:GetSecretStashes', false, function(stashes, IsPolice)
        if stashes then
            TriggerEvent('flex-jail:client:RegisterNewStash', stashes, IsPolice)
        end
    end)
end)

RegisterNetEvent('flex-jail:client:SecretStash', function()
    lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
        if IsInJail then
            if not IsCreatingSecretStash then
                IsCreatingSecretStash = true
                local coords = RayCast(Config.RayCastDistance.secretstash, Lang:t('info.drawtext2d.placesecretstash'))
                if coords then
                    PlayAnim("random@domestic", "pickup_low", false)
                    Wait(1000)
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('flex-jail:server:RegisterSecretStash', coords)
                end
                IsCreatingSecretStash = false
            end
        end
    end)
end)

RegisterNetEvent('flex-jail:client:RegisterNewStash', function(NewStashes, IsPolice)
    for k, v in pairs(StashZones) do
        if v then
            exports.ox_target:removeLocalEntity(v)
        end
    end
    for k, entity in pairs(StashProps) do
        if DoesEntityExist(entity) then
            DeleteObject(entity)
        end
    end
    StashProps = {}
    Stashes = NewStashes
    lib.requestModel(Config.SecretStashProp)
    for k, v in pairs(Stashes) do
        if v.coords then
            StashProps[#StashProps + 1] = CreateObject(GetHashKey(Config.SecretStashProp), v.coords.x, v.coords.y, v.coords.z, false, true, true)
            -- PlaceObjectOnGroundProperly(StashProps[#StashProps])
            FreezeEntityPosition( StashProps[#StashProps], true)
            local Options = {
                {
                    name = Lang:t('target.secretstash.open').. v.cid,
                    event = 'flex-jail:client:OpenSecretStash',
                    icon = "fa-solid fa-box",
                    label = Lang:t('target.secretstash.open'),
                    id = v.cid,
                    canInteract = function(entity, coords, distance)
                        return QBCore.Functions.GetPlayerData().citizenid == v.cid
                    end
                },
            }
            
            if QBCore.Functions.GetPlayerData().citizenid == v.cid then
                Options[#Options+1] = {
                    name = Lang:t('target.secretstash.move').. v.cid,
                    event = 'flex-jail:client:MoveStash',
                    icon = "fa-solid fa-up-down-left-right",
                    label = Lang:t('target.secretstash.move'),
                    id = v.cid,
                    canInteract = function(entity, coords, distance)
                        return true
                    end
                }
            end
            
            if IsPolice then
                Options[#Options+1] = {
                    name = Lang:t('target.secretstash.seize').. v.cid,
                    event = 'flex-jail:client:SeizeStash',
                    icon = "fa-solid fa-skull",
                    label = Lang:t('target.secretstash.seize'),
                    id = v.cid,
                    canInteract = function(entity, coords, distance)
                        return true
                    end
                }

                Options[#Options+1] = {
                    name = Lang:t('target.secretstash.open').. v.cid,
                    -- event = 'flex-jail:client:ViewSecretStash',
                    icon = "fa-solid fa-box",
                    label = Lang:t('target.secretstash.open'),
                    id = v.cid,
                    onSelect = function(data)
                        lib.callback('flex-jail:server:IsPlayerOnline', false, function(isonline)
                            if isonline then
                                TriggerEvent('flex-jail:client:OpenSecretStash', {id = data.id})
                                -- local success = exports["bl_ui"]:PrintLock(3, {grid = 4, duration = 10000, target = 4 })
                                -- if success then
                                --     -- TriggerEvent('flex-jail:client:ViewSecretStash', {id = data.id})
                                --     TriggerEvent('flex-jail:client:OpenSecretStash', {id = data.id})
                                -- end
                            else
                                QBCore.Functions.Notify(Lang:t("info.notrightnow"), 'info', 5000)
                            end
                        end, v.cid)
                    end,
                    canInteract = function(entity, coords, distance)
                        return IsPolice
                    end
                }
            end
            
            StashZones[#StashZones + 1] = exports.ox_target:addLocalEntity(StashProps[#StashProps],Options)
        end
    end
end)

RegisterNetEvent('flex-jail:client:ViewSecretStash', function(args)
    lib.callback('flex-jail:server:secretstash:getstashitems', false, function(items)
        if items then
            local options = {}
            for k, v in pairs(items) do
                options[#options + 1] = {
                    title = QBCore.Shared.Items[v.name].label,
                    description = Lang:t('menu.storage.desc', {value = v.amount}),
                    icon = "nui://"..Config.Inv..QBCore.Shared.Items[v.name].image,
                    image = "nui://"..Config.Inv..QBCore.Shared.Items[v.name].image,
                    event = "",
                    args = {},
                }
            end
            lib.registerContext({
                id = Lang:t('menu.storage.title'),
                title = Lang:t('menu.storage.title'),
                menu = Lang:t('menu.back'),
                onBack = function() OpenShop() end,
                options = options,
            })
            lib.showContext(Lang:t('menu.storage.title'))
        end
    end, 'SecretStash_'..args.id)
end)

RegisterNetEvent('flex-jail:client:OpenSecretStash', function(args)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.4)
    if GetResourceState('ox_inventory') == 'missing' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", 'SecretStash_'..args.id, {maxweight = Config.StashSizes.secret.size, slots = Config.StashSizes.secret.slots})
        TriggerEvent("inventory:client:SetCurrentStash", 'SecretStash_'..args.id)
    else
        if not exports.ox_inventory:openInventory('stash', 'SecretStash_'..args.id) then
            TriggerServerEvent('flex-jail:server:RegisterOxStash', 'SecretStash_'..args.id, Config.StashSizes.secret.slots, Config.StashSizes.secret.size)
            exports.ox_inventory:openInventory('stash', 'SecretStash_'..args.id)
        end
    end
end)

RegisterNetEvent('flex-jail:client:SeizeStash', function(args)
    PlayAnim("random@domestic", "pickup_low", false)
    Wait(1000)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('flex-jail:server:SeizeStash', args.id)
end)

RegisterNetEvent('flex-jail:client:MoveStash', function(args)
    PlayAnim("random@domestic", "pickup_low", false)
    Wait(1000)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('flex-jail:server:MoveStash', args.id)
end)

AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        for k, v in pairs(StashZones) do
            -- exports.ox_target:removeZone(v)
            exports.ox_target:removeLocalEntity(v)
        end
        for k, entity in pairs(StashProps) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
end)