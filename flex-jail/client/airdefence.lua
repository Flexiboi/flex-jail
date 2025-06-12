local QBCore = exports['qb-core']:GetCoreObject()

local accuracy = 800.0 -- higher number is more inaccurate
local nogozone
local isAlarmActive = false
local isExplosionActive = false

local function ApplyInaccuracy(targetCoords)
    local offset = math.random(-accuracy, accuracy) / 100
    local xOffset = offset
    local yOffset = offset
    local zOffset = offset
    return vector3(targetCoords.x + xOffset, targetCoords.y + yOffset, targetCoords.z + zOffset)
end

CreateThread(function()
    while true do
        Wait(math.random(1,2)*1000)
        local ped = PlayerPedId()
        local dist = #(GetEntityCoords(ped) - Config.Location.center)
        local PlayerData = QBCore.Functions.GetPlayerData()
        local veh = GetVehiclePedIsIn(ped, false)
        local driver = GetPedInVehicleSeat(veh, -1)
        if dist < Config.AirDefenceDistanceCheck and ped == driver and GetEntityHeightAboveGround(ped) > 5.0 and IsPedInAnyVehicle(ped) and IsPedInFlyingVehicle(ped) and not isAlarmActive then
            if PlayerData.job.type == 'leo' or PlayerData.job.type == 'ems' then return end
            local count = 0 
            local MaxExplosions = Config.MaxExplosionCount
            while (count < MaxExplosions) do
                if not isAlarmActive then
                    QBCore.Functions.Notify(Lang:t('info.airdefence.goaway', {value = (Config.AirDefenceTimer*1000) / 1000}), 'error')     
                    isAlarmActive = true
                    lib.callback('flex-jail:server:IsJailAlarmActive', false, function(IsAlarmActive)
                        if not IsAlarmActive then
                            TriggerEvent('flex-jail:client:StartJailAlarm')
                        end
                    end)
                    Wait(Config.AirDefenceTimer*1000)
                    QBCore.Functions.Notify(Lang:t('info.airdefence.alarmactivated'), 'error')
                    isExplosionActive = true
                end
                
                while isExplosionActive and isAlarmActive do
                    local ped = PlayerPedId()
                    local pCoords = GetEntityCoords(ped)
                    local targetCoords = ApplyInaccuracy(pCoords)
                    AddExplosion(targetCoords.x, targetCoords.y, targetCoords.z, 18, 2.0, true, false, 1.0)
                    count = count + 1
                    Wait(1000*Config.AirDefenceExplosionTimeout)

                    local dist = #(pCoords - Config.Location.release.xyz)
                    if dist >= Config.AirDefenceDistanceCheck or not IsPedInFlyingVehicle(ped) or not IsPedInAnyVehicle(ped) then
                        isAlarmActive = false
                        isExplosionActive = false
                        break
                    end
                end
                if not isAlarmActive and not isExplosionActive then
                    break
                end
            end 
        end

        local isPlayerDead = IsEntityDead(ped)
        if isPlayerDead then 
            RemoveBlip(nogozone)
            ran = false
            isAlarmActive = false
            isExplosionActive = false
            Wait(1000)
        end
    end
end)