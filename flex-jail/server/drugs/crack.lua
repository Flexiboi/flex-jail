local QBCore = exports['qb-core']:GetCoreObject()

-- Callback to get all findables
lib.callback.register('flex-jail:server:crack:GetCrackObjects', function(source)
    return SV_Config.Crack.Objects.objects
end)

-- Check if has item
lib.callback.register('flex-jail:server:crack:HasItems', function(source, id)
    for k, v in pairs(SV_Config.Crack.Objects.stageitems[id]) do
        if GetResourceState('ox_inventory') == 'missing' then
            if not exports["qb-inventory"]:HasItem(source, v.item, v.amount or 1) then
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.missingitem', {value = v.amount or 1, value2 = QBCore.Shared.Items[v.item].label}), 'error')
                return false
            end
        else
            if exports.ox_inventory:GetItemCount(source, v.item, nil, nil) < v.amount then
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.missingitem', {value = v.amount or 1, value2 = QBCore.Shared.Items[v.item].label}), 'error')
                return false
            end
        end
    end
    return true
end)

-- Retarget Found Object
RegisterNetEvent('flex-jail:server:crack:PlacePot', function(coords, id)
    for k, v in pairs(SV_Config.Crack.Objects.stageitems[id]) do
        if GetResourceState('ox_inventory') == 'missing' then
            if not exports["qb-inventory"]:HasItem(source, v.item, v.amount or 1) then
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.missingitem', {value = v.amount or 1, value2 = QBCore.Shared.Items[v.item].label}), 'error')
                return
            else
                TriggerClientEvent('flex-jail:client:crack:PlacePot', -1, coords)
            end
        else
            if exports.ox_inventory:GetItemCount(source, v.item, nil, nil) < v.amount then
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.missingitem', {value = v.amount or 1, value2 = QBCore.Shared.Items[v.item].label}), 'error')
                return
            else
                TriggerClientEvent('flex-jail:client:crack:PlacePot', -1, coords)
            end
        end
    end
end)

-- Remove Item
RegisterNetEvent('flex-jail:server:crack:RemoveItem', function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.citizennothere'), 'error') end
    for k, v in pairs(SV_Config.Crack.Objects.stageitems[id]) do
        if Player.Functions.RemoveItem(v.item, v.amount or 1, false, nil) then
            if GetResourceState('ox_inventory') == 'missing' then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.item], 'remove', v.amount or 1)
            end
        end
    end
end)

-- Add Item
RegisterNetEvent('flex-jail:server:crack:AddItem', function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.citizennothere'), 'error') end
    for k, v in pairs(SV_Config.Crack.Objects.stageitems[id]) do
        if Player.Functions.AddItem(v.item, v.amount or 1, false, nil) then
            if GetResourceState('ox_inventory') == 'missing' then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.item], 'remove', v.amount or 1)
            end
        end
    end
end)

-- Delete Pot
RegisterNetEvent('flex-jail:server:crack:DeletePot', function(coords)
    TriggerClientEvent('flex-jail:client:crack:DeletePot', -1, coords)
end)

-- Retarget Found Object
RegisterNetEvent('flex-jail:server:crack:Retarget', function(id)
    if not SV_Config.Crack.Objects.objects[id].spawned then return end
    SV_Config.Crack.Objects.objects[id].spawned = false
    TriggerClientEvent('flex-jail:client:crack:DeleteFindable', -1, id)
    SetTimeout(1000*60*SV_Config.Crack.Objects.replacetime, function()
        SV_Config.Crack.Objects.objects[id].spawned = true
        TriggerClientEvent('flex-jail:client:crack:ReTarget', -1, SV_Config.Crack.Objects.objects[id], id)
    end)
end)

-- Give Found Findable
RegisterNetEvent('flex-jail:server:crack:GiveFindable', function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.citizennothere'), 'error') end
    if not SV_Config.Crack.Objects.objects[id].reward then return end
    local conf = SV_Config.Crack.Objects.objects[id].reward
    if conf.item == nil then return end
    Player.Functions.AddItem(conf.item, conf.amount or 1, false, nil)
    if GetResourceState('ox_inventory') == 'missing' then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[conf.item], 'add', conf.amount or 1)
    end
end)

RegisterNetEvent('flex-jail:server:crack:GiveCrack', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.citizennothere'), 'error') end
    if not SV_Config.Crack.Objects.objects[id].reward then return end
    local conf = SV_Config.Crack.Objects.objects[id].reward
    if conf.item == nil then return end
    Player.Functions.AddItem(conf.item, conf.amount or 1, false, nil)
    if GetResourceState('ox_inventory') == 'missing' then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[conf.item], 'add', conf.amount or 1)
    end
end)

-- Event to trigger the particle effect for everyone
RegisterNetEvent('flex-jail:server:crack:Particles', function(dict, particleName, coords, scale, time)
    TriggerClientEvent('flex-jail:client:crack:Particles', -1, dict, particleName, coords, scale, time)
end)