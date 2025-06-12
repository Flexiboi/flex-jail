local holdingTablet, tabletObject
function TabletAnimation()
    lib.requestAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    holdingTablet = true

    if tabletObject and DoesEntityExist(tabletObject) then
        DeleteEntity(tabletObject)
    end

    local playerPed = PlayerPedId()
    CreateThread(function()
        while holdingTablet do
            if not IsEntityPlayingAnim(playerPed, 'amb@code_human_in_bus_passenger_idles@female@tablet@base', 'base', 3) then
                TaskPlayAnim(playerPed, 'amb@code_human_in_bus_passenger_idles@female@tablet@base', 'base', 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end

            Wait(0)
        end
    end)

    CreateThread(function()
        lib.requestModel('prop_cs_tablet')
        tabletObject = CreateObject(joaat('prop_cs_tablet'), 1.0, 1.0, 1.0, 1, 1, 0)
        NetworkRegisterEntityAsNetworked(tabletObject)
        SetEntityAsMissionEntity(tabletObject, true, true)
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(tabletObject), true)
        local bone = GetPedBoneIndex(PlayerPedId(), 60309)
        AttachEntityToEntity(tabletObject, PlayerPedId(), bone, 0.03, 0.02, -0.0, 10.0, -10.0, 0.0, 1, 0, 0, 0, 2, 1)
    end)
end

function StopTabletAnimation()
    if not holdingTablet then
        return
    end

    holdingTablet = false
    Wait(250)

    ClearPedTasks(PlayerPedId())
    if DoesEntityExist(tabletObject) then
        DeleteObject(tabletObject)
    end

    tabletObject = nil
end

function PlayAnim(dic, anim, move)
    RequestAnimDict(dic)
    while not HasAnimDictLoaded(dic) do
        Wait(100)
    end
    if move then
        TaskPlayAnim(PlayerPedId(), dic, anim, 1.0, 1.0, -1, 51, 0, false, false, false)
    else
        TaskPlayAnim(PlayerPedId(), dic, anim, 1.0, 1.0, -1, 1, 0, false, false, false)
    end
end