local QBCore = exports['qb-core']:GetCoreObject()
local xSound = exports.xsound

-- Locals
local IsJailAlarmActive = false
local JpRequests = {}

-- Callback function to add player to jail database
-- @param id <number> - The ID of the player you want to put in jail
-- @param time <number> - Time in minutes the player needs to be in jail
lib.callback.register('flex-jail:server:PutInJail', function(source, id, time)
    local src = tonumber(id) or source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    local Citizenid = Player.PlayerData.citizenid
    local JailTime = MySQL.scalar.await('SELECT jailtime FROM flex_jail WHERE identifier = ?', {Citizenid})
    if JailTime then
        if JailTime == nil then return false end
        if tonumber(JailTime) == 0 then
            MySQL.query.await('DELETE FROM flex_jail WHERE identifier = ?', {Citizenid})
        else
            return false
        end
    end

    local prisonnumber = math.random(1,999)
    local result = MySQL.scalar.await('SELECT * FROM flex_jail WHERE prisonnumber = ?', {prisonnumber})
    if result then
        while result[1] do
            prisonnumber = math.random(1,999)
            result = MySQL.scalar.await('SELECT * FROM flex_jail WHERE prisonnumber = ?', {prisonnumber})
            Wait(1000)
        end
    end
    MySQL.Sync.execute('INSERT INTO flex_jail (identifier, status, jailtime, prisonnumber, items, data) VALUES (?, ?, ?, ?, ?, ?)', {
        Citizenid, true, time, prisonnumber, json.encode(Player.PlayerData.items), ''
    })
    TriggerEvent('flex-jail:server:SetupJailTimer', Citizenid, time)
    Player.Functions.ClearInventory()
    Config.RemoveMultiJob(Citizenid)
    Wait(100)
    if Config.NewsPaper then
        local name = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
        exports['futte-newspaper']:CreateJailStory(name, time)
    end

    if time > 0 and Config.JailJobs.removejob then
        if Config.JailJobs.default.name ~= nil then
            Player.Functions.SetJob(Config.JailJobs.default.name, Config.JailJobs.default.rank)
        end
    elseif time < 0 and Config.JailJobs.removejob then
        Player.Functions.RemoveMoney('cash', Player.PlayerData.money['cash'])
        Player.Functions.RemoveMoney('bank', Player.PlayerData.money['bank'])
        if Config.JailJobs.lifer.name ~= nil then
            Player.Functions.SetJob(Config.JailJobs.lifer.name, Config.JailJobs.lifer.rank)
        end
    end

    TriggerEvent('flex-jail:server:MessageLifers', Lang:t('info.newinmate'), 'info', 5000)

    return true
end)

-- Net Event to Return player items or if escaped remove them from the database
-- @param escaped <true or false> - If true player doesnt get items back
RegisterNetEvent('flex-jail:server:ReturnItems', function(escaped)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM flex_jail WHERE identifier = ?', {Citizenid})
    if not result[1] then return TriggerClientEvent('QBCore:Notify', src, Lang:t('info.areyouinjail'), 'info') end
    if tonumber(result[1].jailtime) > 0 and not escaped then return end
    if escaped then
        MySQL.Async.execute('UPDATE `flex_jail` SET jailtime = @jailtime AND items = @items WHERE identifier = @identifier',
            {
                ["jailtime"] = 0,
                ["@items"] = nil,
                ["@identifier"] = Citizenid,
            }
        )
        return
    end
    if result[1].items then
        for _, v in pairs(json.decode(result[1].items)) do
            if GetResourceState('ox_inventory') == 'missing' then
                exports['qb-inventory']:AddItem(src, v.name, v.amount or v.count or 1, false, v.info or v.metadata or nil, 'flex-jail:server:ReturnItems')
            else
                exports.ox_inventory:AddItem(src, v.name, v.amount or v.count or 1, v.metadata or v.info or nil)
            end
        end
    end
    MySQL.Async.execute('UPDATE `flex_jail` SET items = @items WHERE identifier = @identifier',
        {
            ["@items"] = nil,
            ["@identifier"] = Citizenid,
        }
    )
    TriggerClientEvent('flex-jail:client:Reloadskin', src)
end)

-- Net Event Remove player from prison database
-- @param id <number> - Id of the player you want to remove from the database
-- @param forced <bool> - Force release from jail
RegisterNetEvent('flex-jail:server:RemoveFromJail', function(id, forced)
    local src = tonumber(id) or source
    local Player = QBCore.Functions.GetPlayerByCitizenId(id)
    if not Player then
        Player = QBCore.Functions.GetPlayer(src)
    end
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    if forced then
        TriggerClientEvent('flex-jail:client:ReleaseInmate', src)
        TriggerEvent('flex-jail:server:RemoveFromJailTimer', Citizenid)
    end
    local result = MySQL.query.await('SELECT * FROM flex_jail WHERE identifier = ?', {Citizenid})
    if result then
        if result[1].items then
            if result[1].status then
                MySQL.Async.execute('UPDATE `flex_jail` SET jailtime = @jailtime WHERE identifier = @identifier',
                    {
                        ["@jailtime"] = 0,
                        ["@identifier"] = Citizenid,
                    }
                )
                return TriggerClientEvent('QBCore:Notify', src, Lang:t('info.grabyourstuff'), 'info')
            end
        end
        Wait(2000)
        MySQL.query.await('DELETE FROM flex_jail WHERE identifier = ?', {Citizenid})
        TriggerClientEvent('flex-jail:client:RemoveZones', src)
        TriggerClientEvent('flex-jail:client:ClearEvents', src)
    end
end)

-- Net Event Remove player from prison database
-- @param id/cid <number> - Id or cid of the player you want to remove from the database
RegisterNetEvent('flex-jail:server:RemoveFromSystem', function(data)
    local JailTime = MySQL.scalar.await('SELECT jailtime FROM flex_jail WHERE identifier = ?', {data.citizenid})
    if JailTime then
        if JailTime == nil then return false end
        if tonumber(JailTime) == 0 then
            MySQL.query.await('DELETE FROM flex_jail WHERE identifier = ?', {data.citizenid})
        else
            return false
        end
    end
end)

-- Net event to release an inmate
-- @param id <number> - Id of the player you want to release
RegisterNetEvent('flex-jail:server:ReleaseInmate', function(data)
    local src = tonumber(data) or source
    local Player = QBCore.Functions.GetPlayer(src)
    if data ~= nil and type(data) == 'string' then
        Player = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
    end
    TriggerClientEvent('flex-jail:client:ReleaseInmate', Player.PlayerData.source)
end)

-- Callback to get everyone in jail
lib.callback.register('flex-jail:server:GetEveryoneInAJail', function(source)
    local result = MySQL.Sync.fetchAll('SELECT * FROM flex_jail')
    local players = {}
    for _, v in pairs(result) do
        local Offline = false
        local Player = QBCore.Functions.GetPlayerByCitizenId(v.identifier)
        if Player then
            local PlayerPed = GetPlayerPed(Player.PlayerData.source)
            if PlayerPed then
                local PlayerLocation = GetEntityCoords(PlayerPed)
                if PlayerLocation then
                    local dist = #(PlayerLocation - Config.Location.center)
                    if dist > Config.RespawnDistanceCheck.min then
                        Offline = false
                    end
                end
            end
        end
        if not Player then
            Offline = true
            Player = QBCore.Functions.GetOfflinePlayerByCitizenId(v.identifier)
        end
        if Player then
            players[#players + 1] = {
                Citizenid = v.identifier,
                Prisonnumber = v.prisonnumber,
                Firstname = Player.PlayerData.charinfo.firstname,
                Lastname = Player.PlayerData.charinfo.lastname,
                Time = v.jailtime,
                Jp = exports['flex-jail']:GetJailPoints(Player.PlayerData.source) or 0,
                Disabled = Offline,
            }
        end
    end
    return players
end)

-- Callback to check if player is police
-- @param id <id or nil> - Id of the player you want to remove from the database
lib.callback.register('flex-jail:server:IsPlayerPolice', function(source, id)
    local src = id or source
    local Player = QBCore.Functions.GetPlayer(src)
    if id ~= nil and type(id) == 'string' then
        Player = QBCore.Functions.GetPlayerByCitizenId(id)
    end
    if not Player then return end
    if (Player.PlayerData.job.type == Config.JobType and Player.PlayerData.job.onduty) then
        return true
    else
        return false
    end
end)

-- Callback to check if player is in jail
-- @param id <id or nil> - Id of the player you want to remove from the database
lib.callback.register('flex-jail:server:IsPlayerInJail', function(source, id)
    local src = id or source
    local Player = QBCore.Functions.GetPlayer(src)
    if id ~= nil and type(id) == 'string' then
        Player = QBCore.Functions.GetPlayerByCitizenId(id)
    end
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    local status = MySQL.scalar.await('SELECT status FROM flex_jail WHERE identifier = ?', {Citizenid})
    if not status then
        return false
    else
        return true
    end
end)

-- Server Export to get if player is in jail
function IsPlayerInJail(id)
    local src = id
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    local status = MySQL.query.await('SELECT status FROM flex_jail WHERE identifier = ?', {Citizenid})
    if not status then
        return false
    else
        return true
    end
end
exports('IsPlayerInJail', IsPlayerInJail)

-- Callback to get all jail info from player
-- @param id <id or nil> - Id of the player you want to remove from the database
lib.callback.register('flex-jail:server:GetPlayerJailInfo', function(source, id)
    local src = id or source
    local Offline = false
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        Offline = true
        Player = QBCore.Functions.GetOfflinePlayer(src)
    end
    local Citizenid = Player.PlayerData.citizenid
    local result = MySQL.Sync.fetchAll('SELECT * FROM flex_jail WHERE identifier = ?', {Citizenid})
    if result[1] then
        local r = {
            Citizenid = result[1].identifier,
            Prisonnumber = result[1].prisonnumber,
            Firstname = Player.PlayerData.charinfo.firstname,
            Lastname = Player.PlayerData.charinfo.lastname,
            Time = result[1].jailtime,
            Disabled = Offline,
        }
        return r
    else
        return false
    end
end)

-- Callback to check if player can go outside the prison
-- @param citizenid <cid> - Citizenid of the player
lib.callback.register('flex-jail:server:GetOutSideStatus', function(source, cid)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local status = MySQL.scalar.await('SELECT cangooutside FROM flex_jail WHERE identifier = ?', {cid or Player.PlayerData.citizenid})
    if not status then return end
    return status
end)

-- Event to set outside status (If inmate can go outside or not)
-- @param data <data> - data given from menu (inmate number and cid)
RegisterNetEvent('flex-jail:server:SetOutSideStatus', function(data)
    local src = source
    local status = MySQL.scalar.await('SELECT cangooutside FROM flex_jail WHERE identifier = ? AND prisonnumber = ?', {data.citizenid, data.prisonnumber})
    local state = not status
    MySQL.Sync.execute('UPDATE flex_jail SET cangooutside = ? WHERE identifier = ? AND prisonnumber = ?', { state, data.citizenid, data.prisonnumber})
    if not state then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.outside.yes', {value = data.firstname .. ' ' .. data.lastname, value2 = data.prisonnumber}), 'info')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.outside.no', {value = data.firstname .. ' ' .. data.lastname, value2 = data.prisonnumber}), 'info')
    end
    TriggerClientEvent('flex-jail:client:ManageInmate', src, data)
end)

-- Event to add Jail Points
-- @param id <id> - ID of the player who needs points or nil for source
-- @param amount <number> - Amount it needs to add
RegisterNetEvent('flex-jail:server:AddJailPoints', function(id, addtype)
    local amount = 0
    if Config.JobSettings[addtype] then
        amount = Config.JobSettings[addtype].points
    else
        amount = tonumber(addtype)
    end
    if amount == nil then return end
    local src = id or source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    local result = MySQL.scalar.await('SELECT data FROM flex_jail WHERE identifier = ?', {Citizenid})
    if result then
        local data = json.decode(result) or {}
        if data == nil then
            data = {}
        end
        if data then
            if not data.jailpoints then
                data.jailpoints = 0
            end
            if data.jailpoints then
                data.jailpoints = tonumber(data.jailpoints) + amount
                MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(data), Citizenid})
            else
                data.jailpoints = amount
                MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(data), Citizenid})    
            end
        else
            data.jailpoints = amount
            MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(data), Citizenid})
        end
    else
        MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode({jailpoints = amount}), Citizenid})
    end
    if Config.JobSettings[addtype] then
        if math.random(0, 100) <= Config.JobSettings[addtype].reducetimechance then
            if exports['flex-jail']:GetTimeInJail(src) > 0 then
                exports['flex-jail']:UpdateJailTimer(src)
                TriggerClientEvent('QBCore:Notify', src, Lang:t("success.reducedtime"), 'info')
            end
        end
    end
    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.earnedjp", {value = tostring(amount)}), 'info')
end)

-- Event to remove Jail Points
-- @param id <id> - ID of the player who needs points or nil for source
-- @param amount <number> - Amount it needs to remove
RegisterNetEvent('flex-jail:server:RemoveJailPoints', function(id, amount)
    local src = id or source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    local result = MySQL.scalar.await('SELECT data FROM flex_jail WHERE identifier = ?', {Citizenid})
    if result then
        local data = json.decode(result)
        if data == nil then
            data = {}
            data.jailpoints = 0
            MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(data), Citizenid})
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.removejp", {value = tostring(0)}), 'info')
        elseif data then
            if not data.jailpoints then
                data.jailpoints = 0
            end
            if (tonumber(data.jailpoints) - amount) <= 0 then
                data.jailpoints = 0
            else
                data.jailpoints = tonumber(data.jailpoints) - amount
            end
            MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode(data), Citizenid})
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.removejp", {value = tostring(amount)}), 'info')
        end
    end
end)

-- Event to check Jail Points
-- @param id <id> - ID of the player
function GetJailPoints(id)
    local src = id
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Citizenid = Player.PlayerData.citizenid
    local result = MySQL.scalar.await('SELECT data FROM flex_jail WHERE identifier = ?', {Citizenid})
    if result then
        local data = json.decode(result)
        if data == nil then return 0 end
        if data.jailpoints then
            return tonumber(data.jailpoints)
        end
        return 0
    else
        return 0
    end
end
exports('GetJailPoints', GetJailPoints)

-- Event to give reward
-- @param id <id> - ID of the player who needs to get the reward or nil
-- @param name <string> - type of the job
RegisterNetEvent('flex-jail:server:GiveReward', function(id, jobtype)
    local src = id or source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not Config.JobSettings[jobtype] then return end
    local conf = Config.JobSettings[jobtype].reward
    if conf.reward.item == nil or conf.chance == nil then return end
    if conf.checkifhas then
        if GetResourceState('ox_inventory') == 'missing' then
            if exports["qb-inventory"]:HasItem(src, conf.reward.item, conf.reward.amount) then
                return
            end
        else
            if exports.ox_inventory:GetItemCount(src, conf.reward.item, nil, nil) >= conf.reward.amount then
                return
            end
        end
    end
    if math.random(0,100) <= conf.chance then
        if conf.reward.item == 'cash' or conf.reward.item == 'bank' or conf.reward.item == 'black_money' then
            Player.Functions.AddMoney(conf.reward.item, conf.reward.amount)
        else
            Player.Functions.AddItem(conf.reward.item, conf.reward.amount, false, nil)
            if GetResourceState('ox_inventory') == 'missing' then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[conf.reward.item], 'add')
            end
        end
    end
end)

-- Callback function to check if player is an officer
-- @param id <number> - The ID of the player you want to check
lib.callback.register('flex-jail:server:IsPlayerOfficer', function(source, id)
    local src = id or source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    if (Player.PlayerData.job.name == Config.JobName and Player.PlayerData.job.grade.level < Config.DocOfficerGrade) then return false end
    if (Player.PlayerData.job.type == Config.JobType and Player.PlayerData.job.onduty) then
        return true
    else
        return false
    end
end)

-- Callback function to get the shop items
-- @param shoptype <string> - The type of the shop
lib.callback.register('flex-jail:server:GetShopitems', function(source, shoptype)
    if not Config.Shops[shoptype] then return end
    return Config.Shops[shoptype]
end)

-- Event To Open Stash
-- @param id <number> - ID of the stash to open
-- @param name <string> - Name of the stash
function OpenStash(source, id, name, slots, size)
    if GetResourceState('ox_inventory') ~= 'missing' then
        local inventory = exports.ox_inventory:GetInventory(id)
        if not inventory then
            if not slots or size then
                exports.ox_inventory:RegisterStash(id, name, 30, 100000, true)
            else
                exports.ox_inventory:RegisterStash(id, name, slots, size, true)
            end
        end
        TriggerClientEvent('ox_inventory:openInventory', source, 'player', id)
    else
        TriggerEvent("inventory:server:OpenInventory", "stash", id, Config.StashSizes.Default)
        TriggerClientEvent("inventory:client:SetCurrentStash", source, id)
    end
end
RegisterNetEvent('flex-jail:server:openStash', function(id, name, slots, size)
    OpenStash(source, id, name, slots, size)
end)

-- Event to open armory
-- @param armoryname <string> - Name of the armory to open
-- @param items <array> - List of items in the armory
function OpenArmory(source, name, items, jobs)
    if GetResourceState('ox_inventory') ~= 'missing' then
        local inventory = exports.ox_inventory:GetInventory(name)
        if not inventory then
            exports.ox_inventory:RegisterShop(name, {
                name = name,
                inventory = items,
                groups = jobs,
            })
        end
        TriggerClientEvent('ox_inventory:openInventory', source, 'shop', {type = name})
    elseif GetResourceState('qb-inventory') ~= 'missing' then
        local playerPed = GetPlayerPed(source)
        local playerCoords = GetEntityCoords(playerPed)
        exports['qb-inventory']:CreateShop({
            name = name,
            label = 'armory',
            coords = playerCoords,
            slots = #items,
            items = items
        }) exports['qb-inventory']:OpenShop(source, name)
    end
end
RegisterNetEvent('flex-jail:server:openShop', function(name, items)
    if GetResourceState('ox_inventory') ~= 'missing' then
        local si = {}
        for k,v in pairs(items.items) do
            si[#si+1] = {name = v.name, price = v.price}
        end
        OpenArmory(source, name, si, LEOjobs)
    else
        OpenArmory(source, name, items.items, LEOjobs)
    end
end)

-- Buy Item Event
-- @param data <string> - item and amount data
RegisterNetEvent('flex-jail:server:cantine:Buy', function(data, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local conf = Config.Shops[data.shoptype]
    if conf[data.slot].price then
        if not amount then
            if conf[data.slot].amount <= 0 then return end
            if Player.Functions.RemoveMoney(conf[data.slot].paytype or 'bank', conf[data.slot].price, Lang:t('success.boughtitem',{value = conf[data.slot].name, value2 = conf[data.slot].price})) then
                conf[data.slot].amount -= 1
                Player.Functions.AddItem(conf[data.slot].name, 1, false, conf[data.slot].info)
                local itemname = nil
                if GetResourceState('ox_inventory') ~= 'missing' then
                    if exports.ox_inventory:Items(conf[data.slot].name) then
                        itemname = exports.ox_inventory:Items(conf[data.slot].name).label
                    end
                else
                    itemname = QBCore.Shared.Items[conf[data.slot].name].label
                end
                TriggerClientEvent('QBCore:Notify', src, Lang:t('success.boughtitem',{value = itemname, value2 = conf[data.slot].price}), 'success')
                if GetResourceState('ox_inventory') == 'missing' then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[conf[data.slot].name], 'add')
                end
            end
        else
            if conf[data.slot].amount - amount <= 0 then return end
            if Player.Functions.RemoveMoney(conf[data.slot].paytype or 'bank', conf[data.slot].price * amount, Lang:t('success.boughtitem',{value = conf[data.slot].name, value2 = conf[data.slot].price * amount})) then
                conf[data.slot].amount -= amount
                Player.Functions.AddItem(conf[data.slot].name, amount, false, conf[data.slot].info)
                local itemname = nil
                if GetResourceState('ox_inventory') ~= 'missing' then
                    if exports.ox_inventory:Items(conf[data.slot].name) then
                        itemname = exports.ox_inventory:Items(conf[data.slot].name).label
                    end
                else
                    itemname = QBCore.Shared.Items[conf[data.slot].name].label
                end
                TriggerClientEvent('QBCore:Notify', src, Lang:t('success.boughtitem',{value = itemname, value2 = conf[data.slot].price * amount}), 'success')
                if GetResourceState('ox_inventory') == 'missing' then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[conf[data.slot].name], 'add', amount)
                end
            end
        end
    else
        local points = GetJailPoints(src)
        if points < 0 then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughtjailpoints'), 'error') end
        if points - conf[data.slot].points < 0 then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughtjailpoints'), 'error') end
        if points - conf[data.slot].points >= 0 then
            local Citizenid = Player.PlayerData.citizenid
            if not JpRequests[Citizenid] then
                local result = MySQL.Sync.fetchAll('SELECT * FROM flex_jail WHERE identifier = ?', {Citizenid})
                if result[1] then
                    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.requestedjp'), 'success')
                    JpRequests[Citizenid] = {
                        Citizenid = result[1].identifier,
                        Prisonnumber = result[1].prisonnumber,
                        Firstname = Player.PlayerData.charinfo.firstname,
                        Lastname = Player.PlayerData.charinfo.lastname,
                        Time = result[1].jailtime,
                        Request = conf[data.slot].label,
                        Points = conf[data.slot].points,
                    }
                end
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error.alreadyrequestedjp'), 'error')
            end
        end
    end
end)

-- Callback function to get all prison requests
lib.callback.register('flex-jail:server:GetPrisonRequests', function(source)
    return JpRequests
end)

-- Event to give extra reward
-- @param cid <string> - CitizenId
-- @param confirmed <bool> - true = accept, false = deny
RegisterNetEvent('flex-jail:server:ConfirmPriosnRequest', function(cid, confirmed, points)
    local src = source
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    if not Player then return end
    if confirmed then
        local CurrentPoints = GetJailPoints(Player.PlayerData.source)
        if CurrentPoints < 0 then return end
        if CurrentPoints - points < 0 then return end
        if CurrentPoints - points >= 0 then
            TriggerEvent('flex-jail:server:RemoveJailPoints', Player.PlayerData.source, points)
            TriggerClientEvent('QBCore:Notify', src, Lang:t('success.requestaccepted'), 'success')
            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('success.requestaccepted'), 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughtjailpoints'), 'error')
            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.notenoughtjailpoints'), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.requestdenied'), 'error')
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.requestdenied'), 'error')
        JpRequests[cid] = nil
    end
end)

-- Event to check if job is there
-- @param job <string> - Job you want to check
lib.callback.register('flex-jail:server:IsJobPresent', function(source, job)
    if not job then return end
    local players = QBCore.Functions.GetQBPlayers()
    local amount = 0
    for _, v in pairs(players) do
        if v and (v.PlayerData.job.name == job or v.PlayerData.job.type == job) and v.PlayerData.job.onduty then
            amount += 1
        end
    end
    return amount
end)

-- Event to set outside status (If inmate can go outside or not)
-- @param id <id> - ID of the player who needs to hear the sound, -1 for everyone or nil for source
-- @param name <name> - unique name of the sound
-- @param url <youtube url> - Youtube URL for sound
-- @param volume <volume> - Volume of the audio
-- @param pos <vec3> - Vector 3 where the sound is comming from
-- @param distance <distance> - The distance the sound can be heard from
-- @param soundlegth <seconds> - Seconds how long the sound is
RegisterNetEvent('flex-jail:server:PlayXsoundPos', function(id, name, url, volume, pos, distance, soundlength)
    local src = id or source 
    xSound:PlayUrlPos(src, name, url, volume, pos, false)
    xSound:Distance(src, name, distance)
    -- local soundId = exports['mx-surround']:createUniqueId()
    -- exports['mx-surround']:Play(-1, soundId, url, pos, false, volume, nil)
    SetTimeout(1000*soundlength, function()
        xSound:Destroy(src, name)
        -- exports['mx-surround']:Stop(src, soundId)
    end)
end)

-- Callback to check if alarm is active
lib.callback.register('flex-jail:server:IsJailAlarmActive', function(source)
    if not IsJailAlarmActive then
        IsJailAlarmActive = true
        SetTimeout(1500*Config.Sounds.breakout.soundlength, function()
            IsJailAlarmActive = false
        end)
        return false
    else
        return true
    end
end)

-- Message Lifers
-- @param message <string> - What you want to say to the inmates
-- @param messagetype <string> - Type of message
-- @param time <int> - Amount of time ,essage shows
RegisterNetEvent('flex-jail:server:MessageLifers', function(message, messagetype, time)
    local Lifers = MySQL.Sync.fetchAll('SELECT * FROM flex_jail WHERE jailtime = -1')
    if Lifers then
        for _, v in pairs(Lifers) do
            local Player = QBCore.Functions.GetPlayerByCitizenId(v.identifier)
            if Player then
                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, message, messagetype, time or 5000)
            end
        end
    end
end)

-- REGISTER OX STASH
RegisterNetEvent('flex-jail:server:RegisterOxStash', function(id, slots, maxWeight)
    exports.ox_inventory:RegisterStash(id, id, slots, maxWeight)
end)