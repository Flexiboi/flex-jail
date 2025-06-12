local QBCore = exports['qb-core']:GetCoreObject()
local IsPlayerInJailZone = false
local IsLoggedIn = false
local docalerted = false
local receptionPed, releasePed = nil, nil
local IsPlayerInJail, TimeInJail = false, 0
local Zones = {}
local FirstSpawn = false

-- On Player Join
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    if not IsLoggedIn then
        while not LocalPlayer.state.isLoggedIn do
            Wait(1000)
        end
        IsLoggedIn = LocalPlayer.state.isLoggedIn
        if not IsPlayerInJail then
            lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                IsPlayerInJail = IsInJail
                if IsInJail then
                    lib.callback('flex-jail:server:GetPlayerJailInfo', false, function(JailInfo)
                        if JailInfo then
                            TriggerServerEvent('flex-jail:server:SetupJailTimer', JailInfo.Citizenid, JailInfo.Time)
                            InitiateInmate()
                            RespawnInJail()
                            FirstSpawn = true
                            SetTimeout(30000, function()
                                FirstSpawn = false
                            end)
                            StartJailTimer()
                            TriggerEvent('flex-jail:client:RegisterZones')
                        end
                    end)
                end
            end)
        end
        SetupPeds()
    end
end)

-- On resource start
AddEventHandler("onResourceStart", function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        while not LocalPlayer.state.isLoggedIn do
            Wait(1000)
        end
        if LocalPlayer.state.isLoggedIn then
            IsLoggedIn = true
            if not IsPlayerInJail then
                lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
                    IsPlayerInJail = IsInJail
                    if IsInJail then
                        lib.callback('flex-jail:server:GetPlayerJailInfo', false, function(JailInfo)
                            if JailInfo then
                                TriggerServerEvent('flex-jail:server:SetupJailTimer', JailInfo.Citizenid, JailInfo.Time)
                                InitiateInmate()
                                RespawnInJail()
                                FirstSpawn = true
                                SetTimeout(30000, function()
                                    FirstSpawn = false
                                end)
                                StartJailTimer()
                                TriggerEvent('flex-jail:client:RegisterZones')
                            end
                        end)
                    end
                end)
            end
            SetupPeds()
        end
	end
end)

function SetupPeds()
    if receptionPed ~= nil or releasePed ~= nil then return end
    receptionPed = LoadPed(Config.Location.peds.reception.loc, Config.Location.peds.reception.model, Config.Location.peds.reception.scenario)
    exports.ox_target:addLocalEntity(receptionPed,{			
        {
            name = Lang:t('target.retreiveitems'),
            label = Lang:t('target.retreiveitems'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                TriggerServerEvent('flex-jail:server:ReturnItems', false)
            end,
        },
        {
            name = Lang:t('target.istherehighsecurity'),
            label = Lang:t('target.istherehighsecurity'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                local CanEscape = false
                local TotalJobs, JobCheked = 0, 0
                for k, v in pairs(Config.MiniMumEscape) do
                    TotalJobs += 1
                end
                for k, v in pairs(Config.MiniMumEscape) do
                    lib.callback('flex-jail:server:IsJobPresent', false, function(amount)
                        JobCheked += 1
                        if amount >= v then
                            CanEscape = true
                        else
                            CanEscape = false
                            return
                        end
                    end, k)
                end
                if CanEscape and JobCheked == TotalJobs then
                    QBCore.Functions.Notify(Lang:t("info.escapejail.yes"), 'info', 3000)
                else
                    QBCore.Functions.Notify(Lang:t("info.escapejail.no"), 'info', 3000)
                end
            end,
        },
    })

    releasePed = LoadPed(Config.Location.peds.release.loc, Config.Location.peds.release.model, Config.Location.peds.release.scenario)
    exports.ox_target:addLocalEntity(releasePed,{			
        {
            name = Lang:t('target.release'),
            label = Lang:t('target.release'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
                    if time then
                        if time == 0 then
                            TriggerEvent('flex-jail:client:Release')
                            TriggerServerEvent('flex-jail:server:RemoveFromJail')
                            TriggerServerEvent('flex-jail:server:RemoveSecretStash')
                        else
                            if time > 0 then
                                QBCore.Functions.Notify(Lang:t("info.timeinjail", {value = tostring(time)}), 'info', 3000)
                            elseif time == -1 then
                                QBCore.Functions.Notify(Lang:t('menu.playersinjail.lifetimeinjail'), 'info', 3000)
                            end
                        end
                    end
                end)
            end,
        },
        {
            name = Lang:t('target.istherehighsecurity'),
            label = Lang:t('target.istherehighsecurity'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                local CanEscape = false
                local TotalJobs, JobCheked = 0, 0
                for k, v in pairs(Config.MiniMumEscape) do
                    TotalJobs += 1
                end
                for k, v in pairs(Config.MiniMumEscape) do
                    lib.callback('flex-jail:server:IsJobPresent', false, function(amount)
                        if amount >= v then
                            JobCheked += 1
                            CanEscape = true
                        else
                            CanEscape = false
                            return
                        end
                    end, k)
                end
                if CanEscape and JobCheked == TotalJobs then
                    QBCore.Functions.Notify(Lang:t("info.escapejail.yes"), 'info', 3000)
                else
                    QBCore.Functions.Notify(Lang:t("info.escapejail.no"), 'info', 3000)
                end
            end,
        },
        {
            name = Lang:t('target.paycorruptdoc'),
            label = Lang:t('target.paycorruptdoc'),
            distance = 3.0,
            icon = 'fas fa-hand',
            canInteract = function(entity, coords, distance)
                local IsInJail = lib.callback.await('flex-jail:server:IsPlayerInJail')
                return IsInJail
            end,
            onSelect = function(args)
                TriggerEvent('flex-jail:client:breakout:PayCorruptDoc')
            end,
        },
    })

    RegisterStashes()
    WashingPed()
    MiningPed()
    CleaningPed()
    WoodWorkPed()
    CantinePed()
end

-- Remove player from jail
-- @param id <ID> -- Player id you want to jail
-- @param time <TIME> -- Time in minutes a player gets to stay in jail
RegisterNetEvent('flex-jail:client:PutInJail', function(id, time, InJail)
    if id and time then
        lib.callback('flex-jail:server:PutInJail', false, function(result)
            if result then
                TriggerEvent('flex-jail:client:RegisterZones')
                Wait(1000)
                local conf = Config.Location.jailspawn[math.random(1, #Config.Location.jailspawn)]
                TimeInJail = time
                docalerted = false
                if not InJail then
                    DoScreenFadeOut(800)
                    Wait(3000)
                    SetEntityCoordsNoOffset(PlayerPedId(), conf.loc.xyz)
                    SetEntityHeading(PlayerPedId(), conf.loc.w)
                    Wait(500)
                    if conf.anim.dic then
                        PlayAnim(conf.anim.dic, conf.anim.anim, false)
                    else
                        TaskStartScenarioInPlace(PlayerPedId(), conf.anim.anim, 0, true)
                    end
                    Wait(2000)
                end
                InitiateInmate()
                DoScreenFadeIn(800)
                TriggerEvent('flex-jail:client:crack:LoadObjects')
                StartJailTimer()
            end
        end, id, time)
    end
end)

-- Start Jail Timer for new prisoner
function StartJailTimer()
    Wait(10000)
    lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
        if IsInJail then
            IsPlayerInJail = IsInJail
        end
    end)
    Wait(1000)
    Citizen.CreateThread(function()
        while IsPlayerInJail do
            Wait(1000*60)
            lib.callback('flex-jail:server:UpdateTimeInJail', false, function(time)
                if time then
                    TimeInJail = time
                else
                    IsPlayerInJail = false
                end
            end)
        end
    end)
end

-- Relese player event for ped or teleport to start of prison
RegisterNetEvent('flex-jail:client:Release', function()
    lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
        if IsInJail then
            lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
                if time then
                    if time == 0 then
                        local ped = PlayerPedId()
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do Wait(10) end
                        SetEntityCoords(ped, Config.Location.release.xyz)
                        SetEntityHeading(ped, Config.Location.release.w)
                        Wait(500)
                        DoScreenFadeIn(500)
                    else
                        if time > 0 then
                            QBCore.Functions.Notify(Lang:t("info.timeinjail", {value = tostring(time)}), 'info', 3000)
                        elseif time == -1 then
                            QBCore.Functions.Notify(Lang:t('menu.playersinjail.lifetimeinjail'), 'info', 3000)
                        end
                    end
                end
            end, id)
        end
    end)
end)

-- Get Time In Jail For player
RegisterNetEvent('flex-jail:client:GetTimeInJail', function(id)
    lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
        if time then
            if time > 0 then
                QBCore.Functions.Notify(Lang:t("info.timeinjail", {value = tostring(time)}), 'info', 3000)
            elseif time == -1 then
                QBCore.Functions.Notify(Lang:t('menu.playersinjail.lifetimeinjail'), 'info', 3000)
            end
        end
    end, id)
end)

-- Remove player from jail
-- @param id <ID> -- Player id you want to unjail
RegisterNetEvent('flex-jail:client:RemoveFromJail', function(id)
    if id then
        TriggerServerEvent('flex-jail:server:RemoveFromJail', id, true)
        TriggerServerEvent('flex-jail:server:RemoveSecretStash', id)
    end
end)

-- Register all Zones
RegisterNetEvent('flex-jail:client:RegisterZones', function()
    if Zones.JailArea then
        Zones.JailArea:destroy()
    end
    Zones.JailArea = PolyZone:Create(Config.Location.jail, { name = 'flex-jail:jailzone', debugPoly = Config.Debug })
    Zones.JailArea:onPlayerInOut(function(isPointInside)
        IsPlayerInJailZone = isPointInside
        TriggerEvent('flex-jail:client:security:AttackPlayer', isPointInside)
        if isPointInside then
        else
            if not FirstSpawn then
                lib.callback('flex-jail:server:GetOutSideStatus', false, function(cangooutside)
                    if not cangooutside then
                        lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
                            if time then
                                if time > 0 or time < 0 then
                                    local ped = PlayerPedId()
                                    local loc = GetEntityCoords(ped)
                                    local dist = #(loc - Config.Location.center)
                                    if dist > Config.RespawnDistanceCheck.min then
                                    else
                                        lib.callback('flex-jail:server:IsJailAlarmActive', false, function(IsAlarmActive)
                                            if not IsAlarmActive then
                                                lib.callback('flex-jail:server:IsJobPresent', false, function(ispresent)
                                                    if ispresent >= Config.MinimumDoc then
                                                        Config.SendPoliceAlert(loc, Lang:t('alert.jailbreak.title'), Lang:t('alert.jailbreak.code'), Lang:t('alert.jailbreak.message'), Config.JobName)
                                                    else
                                                        Config.SendPoliceAlert(loc, Lang:t('alert.jailbreak.title'), Lang:t('alert.jailbreak.code'), Lang:t('alert.jailbreak.message'), 'police')
                                                    end
                                                end, Config.JobName)
                                                TriggerEvent('flex-jail:client:StartJailAlarm')
                                            end
                                        end)
                                    end
                                else
                                end
                            else
                                TriggerServerEvent('flex-jail:server:RemoveFromJail')
                                TriggerServerEvent('flex-jail:server:RemoveSecretStash')
                            end
                        end)
                    end
                end)
            end
        end
    end)
end)

-- Reloadskin
RegisterNetEvent('flex-jail:client:Reloadskin', function()
    TriggerEvent("fivem-appearance:client:reloadSkin")
    TriggerEvent("fivem-appearance:ReloadSkin")
    TriggerEvent("illenium-appearance:client:reloadSkin")
    TriggerEvent("illenium-appearance:ReloadSkin")
end)

-- Remove all Zones
RegisterNetEvent('flex-jail:client:RemoveZones', function()
    if Zones.JailArea then
        Zones.JailArea:destroy()
    end
end)

-- Trigger to start the jail alarm sound
RegisterNetEvent('flex-jail:client:StartJailAlarm', function()
    TriggerServerEvent('flex-jail:server:PlayXsoundPos', -1, Config.Sounds.breakout.soundname, Config.Sounds.breakout.url, Config.Sounds.breakout.volume, Config.Sounds.breakout.pos, Config.Sounds.breakout.distance, Config.Sounds.breakout.soundlength)
end)

-- On resource stop
AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        if Zones.JailArea then
            Zones.JailArea:destroy()
        end
        exports.ox_target:removeGlobalPed(receptionPed)
    end
end)