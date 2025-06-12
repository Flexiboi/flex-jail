local QBCore = exports['qb-core']:GetCoreObject()

-- Open Menu that shows all players in jail
function OpenPlayerInJailMenu()
    local players = lib.callback.await('flex-jail:server:GetEveryoneInAJail')
    if players then
        local options = {}
        for _, v in pairs(players) do
            local desc = Lang:t('menu.playersinjail.timeinjail', {value = v.Time})
            if tonumber(v.Time) == -1 then
                desc = Lang:t('menu.playersinjail.lifetimeinjail')
            end
            table.insert(options, {
                title = v.Firstname .. ' ' .. v.Lastname .. ' ('..v.Prisonnumber..')',
                description = desc,
                icon = "fa-solid fa-handcuffs",
                event = "flex-jail:client:ManageInmate",
                disabled = v.Disabled or false,
                args = {
                    firstname = v.Firstname,
                    lastname = v.Lastname,
                    citizenid = v.Citizenid,
                    prisonnumber = v.Prisonnumber,
                    time = v.Time,
                    jp = v.Jp,
                    disabled = v.Disabled,
                },
            })
        end
        lib.registerContext({
            id = Lang:t('menu.playersinjail.title1'),
            title = Lang:t('menu.playersinjail.title1'),
            onBack = function() TriggerEvent('flex-jail:client:OpenJailMenu') end,
            onClose = function() StopTabletAnimation() end,
            onExit = function() StopTabletAnimation() end,
            menu = Lang:t('menu.mainjailmenu'),
            options = options,
        })
        lib.showContext(Lang:t('menu.playersinjail.title1'))
    end
end

-- Manage all inmates
-- @param data <data> - Data of the inmate
RegisterNetEvent('flex-jail:client:ManageInmate', function(data)
    lib.callback('flex-jail:server:GetOutSideStatus', false, function(cangooutside)
        local cangooutside_text = Lang:t('menu.yes')
        if cangooutside then
            cangooutside_text = Lang:t('menu.yes')
        else 
            cangooutside_text = Lang:t('menu.no')
        end
        lib.registerContext({
            id = Lang:t('menu.playersinjail.manageinmate'),
            title = Lang:t('menu.playersinjail.manageinmate',{value = data.firstname .. ' ' .. data.lastname, value2 = data.prisonnumber}),
            onBack = function() OpenPlayerInJailMenu() end,
            onClose = function() StopTabletAnimation() end,
            onExit = function() StopTabletAnimation() end,
            menu = Lang:t('menu.playersinjail.title1'),
            options = {
                {
                    title = Lang:t('menu.playersinjail.checkjailpoints.title'),
                    description = Lang:t('menu.playersinjail.checkjailpoints.desc', {value = data.firstname, value2 = data.jp}),
                    icon = "fa-solid fa-coins",
                },
                {
                    title = Lang:t('menu.playersinjail.cangooutside.title'),
                    description = Lang:t('menu.playersinjail.cangooutside.desc', {value = cangooutside_text}),
                    icon = "fa-solid fa-handcuffs",
                    serverEvent = "flex-jail:server:SetOutSideStatus",
                    args = {
                        firstname = data.firstname,
                        lastname = data.lastname,
                        citizenid = data.citizenid,
                        prisonnumber = data.prisonnumber,
                    },
                },
                {
                    title = Lang:t('menu.playersinjail.removefromsystem.title'),
                    description = Lang:t('menu.playersinjail.removefromsystem.desc'),
                    icon = "fa-solid fa-trash",
                    serverEvent = "flex-jail:server:RemoveFromSystem",
                    args = {
                        firstname = data.firstname,
                        lastname = data.lastname,
                        citizenid = data.citizenid,
                        prisonnumber = data.prisonnumber,
                    },
                },
            },
        })
        lib.showContext(Lang:t('menu.playersinjail.manageinmate'))
    end, data.citizenid)
end)

-- Release Inmate
RegisterNetEvent('flex-jail:client:ReleaseInmate', function()
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    SetEntityCoords(ped, Config.Location.release.xyz)
    SetEntityHeading(ped, Config.Location.release.w)
    Wait(500)
    DoScreenFadeIn(500)
end)

-- Open menu to view all cameras
function Cameras()
    local options = {}
    for _, v in pairs(Config.Cameras) do
        table.insert(options, {
            title = v.name,
            description = '',
            icon = "fa-solid fa-camera",
            onSelect = function()
                OpenCam(v.coords)
            end,
        })
    end
    lib.registerContext({
        id = Lang:t('menu.camera.title'),
        title = Lang:t('menu.camera.title'),
        description = Lang:t('menu.camera.desc'),
        onClose = function() StopTabletAnimation() end,
        onExit = function() StopTabletAnimation() end,
        onBack = function() TriggerEvent('flex-jail:client:OpenJailMenu') end,
        menu = Lang:t('menu.mainjailmenu'),
        options = options,
    })
    lib.showContext(Lang:t('menu.camera.title'))
end

-- Event to open the jail menu
RegisterNetEvent('flex-jail:client:OpenJailMenu', function()
    local options = {}
    TabletAnimation()
    lib.registerContext({
        id = Lang:t('menu.mainjailmenu'),
        title = Lang:t('menu.mainjailmenu'),
        onClose = function() StopTabletAnimation() end,
        onExit = function() StopTabletAnimation() end,
        -- menu = Lang:t('menu.back'),
        options = {
            {
                id = Lang:t('menu.playersinjail.title1'),
                title = Lang:t('menu.playersinjail.title1'),
                icon = "fa-solid fa-handcuffs",
                onSelect = function()
                    OpenPlayerInJailMenu()
                end,
            },
            {
                title = Lang:t('menu.camera.title'),
                description = Lang:t('menu.camera.desc'),
                icon = "fa-solid fa-camera",
                onSelect = function()
                    Cameras()
                end,
            },
            {
                title = Lang:t('menu.jailpointsrequests.title'),
                description = Lang:t('menu.jailpointsrequests.desc'),
                icon = "fa-solid fa-book",
                onSelect = function()
                    JailPointRequests()
                end,
            },
        },
    })
    lib.showContext(Lang:t('menu.mainjailmenu'))
end)

-- Function to open Jail Points Menu
function JailPointRequests()
    lib.callback('flex-jail:server:GetPrisonRequests', false, function(requests)
        if requests then
            local options = {}
            for _, v in pairs(requests) do
                table.insert(options, {
                    title = Lang:t('menu.jailpointsrequests.sub.title', {value = v.Firstname ..' '.. v.Lastname, value2 = v.Prisonnumber}),
                    description = v.Request,
                    onSelect = function()
                        lib.registerContext({
                            id = Lang:t('menu.jailpointsrequests.sub.title', {value = v.Firstname ..' '.. v.Lastname, value2 = v.Prisonnumber}),
                            title = v.Request,
                            description = v.Request,
                            onClose = function() StopTabletAnimation() end,
                            onExit = function() StopTabletAnimation() end,
                            onBack = function() TriggerEvent('flex-jail:client:OpenJailMenu') end,
                            menu = Lang:t('menu.jailpointsrequests.title'),
                            options = {
                                {
                                    id = Lang:t('menu.yes'),
                                    title = Lang:t('menu.yes'),
                                    icon = "fa-solid fa-check",
                                    onSelect = function()
                                        TriggerServerEvent('flex-jail:server:ConfirmPriosnRequest', v.Citizenid, true, v.Points)
                                        TriggerEvent('flex-jail:client:OpenJailMenu')
                                    end,
                                },
                                {
                                    id = Lang:t('menu.no'),
                                    title = Lang:t('menu.no'),
                                    icon = "fa-solid fa-ban",
                                    onSelect = function()
                                        TriggerServerEvent('flex-jail:server:ConfirmPriosnRequest', v.Citizenid, false)
                                        TriggerEvent('flex-jail:client:OpenJailMenu')
                                    end,
                                },
                            },
                        })
                        lib.showContext(Lang:t('menu.jailpointsrequests.sub.title', {value = v.Firstname ..' '.. v.Lastname, value2 = v.Prisonnumber}))
                    end,
                })
            end
            lib.registerContext({
                id = Lang:t('menu.jailpointsrequests.title'),
                title = Lang:t('menu.jailpointsrequests.title'),
                description = Lang:t('menu.jailpointsrequests.desc'),
                onClose = function() StopTabletAnimation() end,
                onExit = function() StopTabletAnimation() end,
                onBack = function() TriggerEvent('flex-jail:client:OpenJailMenu') end,
                menu = Lang:t('menu.mainjailmenu'),
                options = options,
            })
            lib.showContext(Lang:t('menu.jailpointsrequests.title'))
        end
    end)
end

-- Remove Player From System
RegisterNetEvent('flex-jail:client:RemoveFromSystem', function(data)
    lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
        lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
            if IsInJail then
                if tonumber(time) == 0 then
                    TriggerServerEvent('flex-jail:server:RemoveFromJail', data.citizenid, true)
                end
            end
        end, data.citizenid)
    end, data.citizenid)
end)

-- On Player Load
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end
end)

-- On Start Script
AddEventHandler("onResourceStart", function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        while not LocalPlayer.state.isLoggedIn do
            Wait(1000)
        end
    end
end)

-- oldProximity =  LocalPlayer.state['proximity'].distance
-- exports["pma-voice"]:overrideProximityRange(ZoneData.range, true)