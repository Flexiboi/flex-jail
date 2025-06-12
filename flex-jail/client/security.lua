local Guarding, IsInJail = false, false
local Guards = {}
local NetworedGuards = {}

function loadModel(model)
    local time = 1000
    if not HasModelLoaded(model) then
        while not HasModelLoaded(model) do
            if time > 0 then time = time - 1 RequestModel(model) else time = 1000 break end Wait(10)
        end
    end 
end

RegisterNetEvent('flex-jail:client:security:CreatePeds', function(GuardLocations, Models)
    local GuardNetIds = {}
    for k, v in pairs(GuardLocations) do
        local model = Models[math.random(1, #Models)]
        loadModel(model)
        Guards[#Guards+1] = CreatePed(4, GetHashKey(model), v.x, v.y, v.z, v.w, true, true)
        GuardNetIds[#GuardNetIds+1] = NetworkGetNetworkIdFromEntity(Guards[#Guards])
    end
    TriggerServerEvent('flex-jail:server:security:SyncGuards', GuardNetIds)
end)

RegisterNetEvent('flex-jail:client:security:SyncGuards', function(state, NetworedGuards)
    NetworedGuards = NetworedGuards
    Guarding = state
    if Guarding then
        for k, v in pairs(NetworedGuards) do
            local guard = NetworkGetEntityFromNetworkId(v)
            if DoesEntityExist(guard) and not IsPedDeadOrDying(guard, true) then
                FreezeEntityPosition(guard, true)
                SetEntityAsMissionEntity(guard, true, true)
                SetPedCombatAttributes(guard, 46, true) -- Make sure NPC engages in combat
                SetPedCombatAbility(guard, 100) -- High combat skill
                SetPedCombatRange(guard, 2) -- Medium range attack
                SetPedAlertness(guard, 3) -- High alert
                SetPedAccuracy(guard, 75) -- Decent aim
                SetPedFleeAttributes(guard, 0, false) -- Prevent fleeing
                SetPedRelationshipGroupHash(guard, GetHashKey("COP")) -- Set relationship group
                GiveWeaponToPed(guard, GetHashKey("WEAPON_PISTOL"), 255, false, true) -- Give weapon
                TaskStartScenarioInPlace(guard, "WORLD_HUMAN_GUARD_STAND", 0, true)
            end
        end
        JailGuardThread()
    else
        for k, v in pairs(Guards) do
            local guard = v
            if DoesEntityExist(guard) then
                DeleteEntity(guard)
            end
        end
        for k, v in pairs(NetworedGuards) do
            local guard = NetworkGetEntityFromNetworkId(v)
            if DoesEntityExist(guard) then
                DeleteEntity(guard)
            end
        end
    end
end)

function PlayerHasWeapon()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    return weapon ~= GetHashKey("WEAPON_UNARMED")
end

RegisterNetEvent('flex-jail:client:security:AttackPlayer', function(state)
    IsInJail = state
    if IsInJail then
        JailGuardThread()
    end
end)

function JailGuardThread()
    Citizen.CreateThread(function()
        while IsInJail and Guarding do
            local IsOfficer = lib.callback.await('flex-jail:server:IsPlayerOfficer')
            if IsOfficer then 
                IsInJail = false
            end
            if PlayerHasWeapon() and not IsOfficer then
                for k, v in pairs(NetworedGuards) do
                    local guard = NetworkGetEntityFromNetworkId(v)
                    if DoesEntityExist(guard) and not IsPedDeadOrDying(guard, true) then
                        ClearPedTasksImmediately(guard)
                        TaskCombatPed(guard, PlayerPedId(), 0, 16)
                    end
                end
            end
            Citizen.Wait(10000)
        end
    end)
end

AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        for k, v in pairs(Guards) do
            local guard = v
            if DoesEntityExist(guard) then
                DeleteEntity(guard)
            end
        end
        for k, v in pairs(NetworedGuards) do
            local guard = NetworkGetEntityFromNetworkId(v)
            if DoesEntityExist(guard) then
                DeleteEntity(guard)
            end
        end
    end
end)