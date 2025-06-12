local QBCore = exports['qb-core']:GetCoreObject()

if Config.commands.jail.enabled then
    lib.addCommand(Config.commands.jail.command, {
        help = Lang:t('commands.jail'),
        params = {
            {
                name = 'geluksnummer',
                type = 'ID',
                help = Lang:t('commands.id'),
            },
            {
                name = 'tijd',
                type = 'Nummer',
                help = Lang:t('commands.time'),
            },
        },
        -- restricted = 'group.admin'
    }, function(source, args, raw)
        local Player = QBCore.Functions.GetPlayer(source)
        if (Player.PlayerData.job.name == Config.JobName and Player.PlayerData.job.grade.level < Config.DocOfficerGrade) then return end
        if (Player.PlayerData.job.name ~= Config.JobName and not Config.commands.jail.all) then return end
        local Target = QBCore.Functions.GetPlayer(tonumber(args.geluksnummer))
        if not Target then return TriggerClientEvent('QBCore:Notify', source, Lang:t('info.citizinotonline'), 'error') end
        local PlayerPedCoords = GetEntityCoords(GetPlayerPed(source))
        local TargetPedCoords = GetEntityCoords(GetPlayerPed(tonumber(args.geluksnummer)))
        if PlayerPedCoords == nil or TargetPedCoords == nil then return end
        if #(PlayerPedCoords - TargetPedCoords) > 10 then return TriggerClientEvent('QBCore:Notify', source, Lang:t('error.tofaraway'), 'error') end
        local dist = #(PlayerPedCoords - Config.Location.center)
        local InJail = false
        if dist <= 200 then
            InJail = true
        end
        if QBCore.Functions.HasPermission(source, 'god') or QBCore.Functions.HasPermission(source, 'admin') or ((Player.PlayerData.job.type == Config.JobType and Player.PlayerData.job.onduty) and (math.floor(tonumber(args.tijd)) > 0)) then
            TriggerClientEvent('flex-jail:client:PutInJail', tonumber(args.geluksnummer), tonumber(args.geluksnummer), math.floor(tonumber(args.tijd)), InJail)
        end
    end)
end

if Config.commands.unjail.enabled then
    lib.addCommand(Config.commands.unjail.command, {
        help = Lang:t('commands.unjail'),
        params = {
            {
                name = 'geluksnummer',
                type = 'ID',
                help = Lang:t('commands.id'),
            },
        },
        -- restricted = 'group.admin'
    }, function(source, args, raw)
        local Player = QBCore.Functions.GetPlayer(source)
        if (Player.PlayerData.job.name == Config.JobName and Player.PlayerData.job.grade.level < Config.DocOfficerGrade) then return end
        if (Player.PlayerData.job.name ~= Config.JobName and not Config.commands.jail.all) then return end
        if (Player.PlayerData.job.type == Config.JobType and Player.PlayerData.job.onduty) or QBCore.Functions.HasPermission(source, 'god') or QBCore.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('flex-jail:client:RemoveFromJail', source, args.geluksnummer)
        end
    end)
end

if Config.commands.jailmenu.enabled then
    lib.addCommand(Config.commands.jailmenu.command, {
        help = Lang:t('menu.mainjailmenu'),
        params = {},
        -- restricted = 'group.admin'
    }, function(source, args, raw)
        local Player = QBCore.Functions.GetPlayer(source)
        if (Player.PlayerData.job.name == Config.JobName and Player.PlayerData.job.grade.level < Config.DocOfficerGrade) then return end
        if (Player.PlayerData.job.name ~= Config.JobName and not Config.commands.jail.all) then return end
        if (Player.PlayerData.job.type == Config.JobType and Player.PlayerData.job.onduty) or QBCore.Functions.HasPermission(source, 'god') or QBCore.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('flex-jail:client:OpenJailMenu', source)
        end
    end)
else
    QBCore.Functions.CreateUseableItem(Config.commands.jailmenu.item, function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        if (Player.PlayerData.job.name == Config.JobName and Player.PlayerData.job.grade.level < Config.DocOfficerGrade) then return end
        if (Player.PlayerData.job.name ~= Config.JobName and not Config.commands.jail.all) then return end
        if (Player.PlayerData.job.type == Config.JobType and Player.PlayerData.job.onduty) or QBCore.Functions.HasPermission(source, 'god') or QBCore.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('flex-jail:client:OpenJailMenu', source)
        end
    end)
end

if Config.commands.jailtime.enabled then
    lib.addCommand(Config.commands.jailtime.command, {
        help = Lang:t('commands.jailtime'),
        params = {},
        -- restricted = 'group.admin'
    }, function(source, args, raw)
        TriggerClientEvent('flex-jail:client:GetTimeInJail', source)
    end)
end

if Config.commands.jailpoints.enabled then
    lib.addCommand(Config.commands.jailpoints.command, {
        help = Lang:t('commands.jailpoints'),
        params = {},
        -- restricted = 'group.admin'
    }, function(source, args, raw)
        if not exports['flex-jail']:IsPlayerInJail(source) then return end
        TriggerClientEvent('QBCore:Notify', source, Lang:t('info.jailpoints',{value = tostring(exports['flex-jail']:GetJailPoints(source))}), 'info')
    end)
end

if Config.commands.addjailpoints.enabled then
    lib.addCommand(Config.commands.addjailpoints.command, {
        help = Lang:t('commands.points.add'),
        params = {
            {
                name = 'geluksnummer',
                type = 'ID',
                help = Lang:t('commands.id'),
            },
            {
                name = 'punten',
                type = 'POINTS',
                help = Lang:t('commands.points.amount'),
            },
        },
        restricted = 'group.admin',
    }, function(source, args, raw)
        TriggerEvent('flex-jail:server:AddJailPoints', tonumber(args.geluksnummer), tonumber(args.punten))
    end)
end

if Config.commands.removejailpoints.enabled then
    lib.addCommand(Config.commands.removejailpoints.command, {
        help = Lang:t('commands.points.add'),
        params = {
            {
                name = 'geluksnummer',
                type = 'ID',
                help = Lang:t('commands.id'),
            },
            {
                name = 'punten',
                type = 'POINTS',
                help = Lang:t('commands.points.amount'),
            },
        },
        restricted = 'group.admin',
    }, function(source, args, raw)
        TriggerEvent('flex-jail:server:RemoveJailPoints', tonumber(args.geluksnummer), tonumber(args.punten))
    end)
end

if Config.commands.fixJailData.enabled then
    lib.addCommand(Config.commands.fixJailData.command, {
        help = Lang:t('commands.fixjaildata'),
        params = {
            {
                name = 'geluksnummer',
                type = 'ID',
                help = Lang:t('commands.id'),
            },
        },
        restricted = 'group.admin',
    }, function(source, args, raw)
        local src = tonumber(args.geluksnummer) or source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local Citizenid = Player.PlayerData.citizenid
            if Citizenid then
                local Points = exports['flex-jail']:GetJailPoints(src)
                MySQL.Sync.execute('UPDATE flex_jail SET data = ? WHERE identifier = ?', { json.encode({}), Citizenid})
                TriggerEvent('flex-jail:server:AddJailPoints', tonumber(args.geluksnummer), tonumber(Points))
            end
        end
    end)
end