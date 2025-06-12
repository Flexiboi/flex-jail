local QBCore = exports['qb-core']:GetCoreObject()
local PlayersInJail = {}

RegisterNetEvent('flex-jail:server:SetupJailTimer', function(Citizenid, time)
    PlayersInJail[Citizenid] = {
        cid = Citizenid,
        time = tonumber(time)
    }
end)

RegisterNetEvent('flex-jail:server:RemoveFromJailTimer', function(Citizenid)
    MySQL.Sync.execute('UPDATE flex_jail SET jailtime = ? WHERE identifier = ?', { 0, Citizenid})
    PlayersInJail[Citizenid] = nil
end)

function UpdateJailTimer(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if src ~= nil and type(src) == 'string' or Player == nil then
        Player = QBCore.Functions.GetPlayerByCitizenId(id)
    end
    if not Player then return false end
    local Citizenid = Player.PlayerData.citizenid
    if PlayersInJail[Citizenid] == nil then return end
    if not PlayersInJail[Citizenid] then return end
    if PlayersInJail[Citizenid].time == nil then return end
    if Config.PayEachMonthToDoc.enable then
        exports.fd_banking:AddMoney(Config.JobName, Config.PayEachMonthToDoc.payout, 'Gevangenis')
    end
    if PlayersInJail[Citizenid].time == -1 then return true end
    if PlayersInJail[Citizenid].time > 0 then
        PlayersInJail[Citizenid].time -= 1
        MySQL.Sync.execute('UPDATE flex_jail SET jailtime = ? WHERE identifier = ?', { PlayersInJail[Citizenid].time, Citizenid})
        return PlayersInJail[Citizenid].time
    elseif PlayersInJail[Citizenid].time == 0 then
        PlayersInJail[Citizenid].time = 0
        MySQL.Sync.execute('UPDATE flex_jail SET jailtime = ? WHERE identifier = ?', { 0, Citizenid})
        return false
    else
        return true
    end
end
exports('UpdateJailTimer', UpdateJailTimer)

lib.callback.register('flex-jail:server:UpdateTimeInJail', function(source, id)
    local src = tonumber(id) or source
    return UpdateJailTimer(src)
end)

function GetTimeInJail(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    local Citizenid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT jailtime FROM flex_jail WHERE identifier = ?', {Citizenid})
    if result[1] then
        if result[1].jailtime then
            return tonumber(result[1].jailtime)
        else
            return 0
        end
    else
        return 0
    end
end
exports('GetTimeInJail', GetTimeInJail)

lib.callback.register('flex-jail:server:GetTimeInJail', function(source, id)
    local src = tonumber(id) or source
    return GetTimeInJail(src)
end)