local QBCore = exports['qb-core']:GetCoreObject()
local Stashes = {}

-- Check if player is in the city
-- @param id <string> - Citizenid of the player
lib.callback.register('flex-jail:server:IsPlayerOnline', function(source, id)
    local Player = QBCore.Functions.GetPlayerByCitizenId(id) or QBCore.Functions.GetPlayer(id)
    if Player then
        return true
    end
    return false
end)

-- Register a new secret stash
-- @param coords <vec3> - Vector 3 of the stash
RegisterNetEvent('flex-jail:server:RegisterSecretStash', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    for k, v in pairs(Stashes) do
        if v.cid == Citizenid then
            return
        end
    end
    if Player.Functions.RemoveItem(Config.UsableItems.secretstash, 1) then
        if GetResourceState('ox_inventory') == 'missing' then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.UsableItems.secretstash], 'remove')
        end
        Stashes[#Stashes+1] = {
            cid = Citizenid,
            coords = coords
        }
        local result = MySQL.scalar.await('SELECT data FROM flex_jail WHERE identifier = ?', {Citizenid})
        if result then
            local data = json.decode(result)
            if data then
                if data.jailpoints then
                    newdata = {
                        jailpoints = data.jailpoints,
                        secretstash = coords
                    }
                    MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(newdata), Citizenid})
                elseif data.secretstash then
                    newdata = {
                        jailpoints = 0,
                        secretstash = coords
                    }
                    MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(newdata), Citizenid})
                end
            else
                newdata = {
                    secretstash = coords
                }
                MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(newdata), Citizenid})
            end
        else
            newdata = {
                secretstash = coords
            }
            MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(newdata), Citizenid})
        end
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local P = QBCore.Functions.GetPlayer(playerId)
            if (#Stashes > 0) then
                if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, Stashes, true)
                else
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, Stashes, false)
                end
            else
                if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, true)
                else
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, false)
                end
            end
        end
        -- if Player.PlayerData.job.type ~= Config.JobType then
        --     local OwnStash = {}
        --     OwnStash[#OwnStash+1] = { cid = Citizenid, coords = coords }
        --     TriggerClientEvent('flex-jail:client:RegisterNewStash', src, OwnStash, false)
        -- end
        Wait(1000)
        TriggerClientEvent('flex-jail:client:ReloadStashes', -1)
    end
end)

-- Seize Stash
-- @param id <id> - Id of the stash
RegisterNetEvent('flex-jail:server:SeizeStash', function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayerByCitizenId(id)
    if not Player then return end
    if not Target then return end
    local Citizenid = Target.PlayerData.citizenid
    local PlayerPedCoords = GetEntityCoords(GetPlayerPed(source))
    local TargetPedCoords = GetEntityCoords(GetPlayerPed(tonumber(Target.PlayerData.source)))
    if PlayerPedCoords == nil or TargetPedCoords == nil then return end
    if #(PlayerPedCoords - TargetPedCoords) > 10 then return TriggerClientEvent('QBCore:Notify', source, Lang:t('error.tofaraway'), 'error') end
    for k, v in pairs(Stashes) do
        if v.cid == id then
            Stashes[k] = nil
            table.remove(Stashes, k)
        end
    end
    local result = MySQL.scalar.await('SELECT data FROM flex_jail WHERE identifier = ?', {Citizenid})
    if result then
        local data = json.decode(result)
        data.secretstash = 'seized'
        MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', {json.encode(data), Citizenid})
    else
        MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', {json.encode({secretstash = 'seized'}), Citizenid})
    end
    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(playerId)
        if (#Stashes > 0) then
            if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, Stashes, true)
            else
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, Stashes, false)
            end
        else
            if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, true)
            else
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, false)
            end
        end
    end
    -- TriggerClientEvent('flex-jail:client:RegisterNewStash', Target.PlayerData.source, {}, false)
end)

-- Move Stash
-- @param cid <cid> - CID of the player
RegisterNetEvent('flex-jail:server:MoveStash', function(id)
    local Player = QBCore.Functions.GetPlayerByCitizenId(id)
    if not Player then return end
    if Player.Functions.AddItem(Config.UsableItems.secretstash, 1) then
        if GetResourceState('ox_inventory') == 'missing' then
            TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, QBCore.Shared.Items[Config.UsableItems.secretstash], 'add')
        end
        for k, v in pairs(Stashes) do
            if v.cid == id then
                Stashes[k] = nil
                table.remove(Stashes, k)
            end
        end
        local result = MySQL.scalar.await('SELECT data FROM flex_jail WHERE identifier = ?', {id})
        if result then
            local data = json.decode(result)
            data.secretstash = 'pickedup'
            MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', {json.encode(data), id})
        else
            MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', {json.encode({secretstash = 'pickedup'}), id})
        end
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local P = QBCore.Functions.GetPlayer(playerId)
            if (#Stashes > 0) then
                if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, Stashes, true)
                else
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, Stashes, false)
                end
            else
                if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, true)
                else
                    TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, false)
                end
            end
        end
        -- TriggerClientEvent('flex-jail:client:RegisterNewStash', Player.PlayerData.source, {}, false)
    end
end)

-- Remove Secret Stash
RegisterNetEvent('flex-jail:server:RemoveSecretStash', function(id)
    local src = tonumber(id) or source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    for k, v in pairs(Stashes) do
        if v.cid == id then
            Stashes[k] = nil
            table.remove(Stashes, k)
            MySQL.query.await('DELETE FROM stashitems where identifier = ?', {'SecretStash_'..Citizenid})
        end
    end
    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(playerId)
        if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
            TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, Stashes, true)
        -- elseif (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
        --     TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, true)
        end
    end
end)

-- Get all secret stashes
lib.callback.register('flex-jail:server:GetSecretStashes', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    local result = MySQL.Sync.fetchAll('SELECT * FROM flex_jail')
    if not result[1] then return false end
    local stashes = {}
    for k, v in pairs(result) do
        local data = json.decode(v.data)
        if data then
            if data.secretstash then
                if data.secretstash.x and data.secretstash.y and data.secretstash.z then
                    stashes[#stashes+1] = {
                        cid = v.identifier,
                        coords = vector3(data.secretstash.x, data.secretstash.y, data.secretstash.z)
                    }
                end
            end
        end
    end
    Stashes = stashes
    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(playerId)
        if (#stashes > 0) then
            if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, stashes, true)
            else
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, stashes, false)
            end
        else
            if (P.PlayerData.job.type == Config.JobType) and P.PlayerData.job.onduty then
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, true)
            else
                TriggerClientEvent('flex-jail:client:RegisterNewStash', playerId, {}, false)
            end
        end
    end
end)

-- Callback function to get the stash items
-- @param stashId <string> - The id of the stash
lib.callback.register('flex-jail:server:secretstash:getstashitems', function(source, stashId)
    return exports['qb-inventory']:GetStashItems(stashId)
end)