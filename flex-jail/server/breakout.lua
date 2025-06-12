local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('flex-jail:server:SetDoorState', function(doorId, state)
    exports.ox_doorlock:setDoorState(doorId, state)
end)

-- @param id <number> - ID for in the config
lib.callback.register('flex-jail:server:breakout:HasBreakOutItems', function(source, id)
    local items = Config.BreakOut[id].itemsNeeded
    local hasItems = false
    for k, v in pairs(items) do
        if not exports["qb-inventory"]:HasItem(source, k, v.amount) then
            hasItems = false
            return false
        else
            hasItems = true
        end
    end
    return hasItems
end)

-- @param id <number> - ID for in the config
RegisterNetEvent('flex-jail:server:breakout:RemoveItems', function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.citizennothere'), 'error') end
    local items = Config.BreakOut[id].itemsNeeded
    for k, v in pairs(items) do
        if GetResourceState('ox_inventory') == 'missing' then
            if not exports["qb-inventory"]:HasItem(src, k, v.amount) then
                return
            end
        else
            if exports.ox_inventory:GetItemCount(src, k, nil, nil) < v.amount then
                return
            end
            -- if not exports["ox_inventory"]:GetItemCount(src, k) >= v.amount then
            --     return
            -- end
        end
    end
    for k, v in pairs(items) do
        if GetResourceState('ox_inventory') == 'missing' then
            if exports["qb-inventory"]:HasItem(src, k, v.amount) then
                if v.remove then
                    if Player.Functions.RemoveItem(k, v.amount or 1, false, nil) then
                        if GetResourceState('ox_inventory') == 'missing' then
                            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[k], 'remove', v.amount or 1)
                        end
                    end
                end
            end
        else
            if exports.ox_inventory:GetItemCount(src, k, nil, nil) >= v.amount then
                if v.remove then
                    if Player.Functions.RemoveItem(k, v.amount or 1, false, nil) then
                        if GetResourceState('ox_inventory') == 'missing' then
                            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[k], 'remove', v.amount or 1)
                        end
                    end
                end
            end
        end
    end
end)

-- @param id <number> - ID for in the config
RegisterNetEvent('flex-jail:server:breakout:RegisterRope', function(id)
    TriggerClientEvent('flex-jail:client:breakout:RegisterRope', -1, id)
end)

-- @param doorID <number> - ID for the door
lib.callback.register('flex-jail:server:breakout:GetDoorState', function(source, doorID)
    local door = exports.ox_doorlock:getDoor(doorID)
    if door.state == 1 then
        return false
    else
        return true
    end
end)

-- Callback function to give money to the corrupt npc
lib.callback.register('flex-jail:server:breakout:PayCorruptDoc', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    if Player.Functions.RemoveMoney('cash', Config.CurrupNPCDoors.payamount, Lang:t('success.payedcorruptnpc',{value = Config.CurrupNPCDoors.payamount})) then
        return true
    else
        return false
    end
end)