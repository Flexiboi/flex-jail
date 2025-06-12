local QBCore = exports['qb-core']:GetCoreObject()
local IsPlaceing, IsBaking = false, false
local CampFires, Pans, Findables = {}, {}, {}
local FirePlaceTargets = {}

-- On Player Join
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    Wait(1000)
    TriggerEvent('flex-jail:client:crack:LoadObjects')
end)

-- Load Objects
RegisterNetEvent('flex-jail:client:crack:LoadObjects', function()
    local IsInJail = lib.callback.await('flex-jail:server:IsPlayerInJail')
    local IsPolice = lib.callback.await('flex-jail:server:IsPlayerPolice')
    if IsInJail or IsPolice then
        local data = lib.callback.await('flex-jail:server:crack:GetCrackObjects')
        for k, v in pairs(data) do
            if v.spawned then
                LoadModel(v.prop)
                Findables[k] = CreateObject(joaat(v.prop), v.coords.x, v.coords.y, v.coords.z, false, true, true)
                SetEntityHeading(Findables[k], v.coords.w)
                SetEntityInvincible(Findables[k], true)
                -- PlaceObjectOnGroundProperly(Findables[k])
                RegisterFindableTarget(Findables[k], k)
            end
        end
    end
end)

-- Place fireplace
RegisterNetEvent('flex-jail:client:crack:PlaceFire', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, Config.Crack.props.fireplace, false, false, false)
    if not pot or pot == 0 then
        lib.callback('flex-jail:server:IsPlayerInJail', false, function(IsInJail)
            if IsInJail then
                lib.callback('flex-jail:server:crack:HasItems', false, function(HasItems)
                    if HasItems then
                        if not IsPlaceing then
                            IsPlaceing = true
                            local coords = RayCast(Config.RayCastDistance.secretstash, Lang:t('info.drawtext2d.placesecretstash'))
                            if coords then
                                lookEnt(coords)
                                PlayAnim("random@domestic", "pickup_low", false)
                                Wait(1000)
                                ClearPedTasks(ped)
                                LoadModel(Config.Crack.props.fireplace)
                                CampFires[#CampFires + 1] = CreateObject(joaat(Config.Crack.props.fireplace), coords.x, coords.y, coords.z, true, true, true)
                                SetEntityHeading(CampFires[#CampFires], GetEntityHeading(ped))
                                PlaceObjectOnGroundProperly(CampFires[#CampFires])
                                FreezeEntityPosition(CampFires[#CampFires],true)
                                TriggerServerEvent('flex-jail:server:crack:RemoveItem', 1)
                                local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, Config.Crack.props.fireplace, false, false, false)
                                if not pot or pot == 0 then return end
                                local potcoords = GetEntityCoords(pot)
                                local center = GetObjectCenter(Config.Crack.props.fireplace, potcoords)
                                lookEnt(center)
                                PlayAnim("random@domestic", "pickup_low", false)
                                Wait(1000)
                                ClearPedTasks(ped)
                                TriggerServerEvent('flex-jail:server:crack:PlacePot', coords, 2)
                                SetTimeout(1000*Config.Crack.settings.fireplacetime, function()
                                    while IsBaking do 
                                        Wait(100)
                                    end
                                    exports.ox_target:removeLocalEntity(FirePlaceTargets[#FirePlaceTargets])
                                    if DoesEntityExist(CampFires[#CampFires]) then
                                        DeleteEntity(CampFires[#CampFires])
                                        TriggerServerEvent('flex-jail:server:crack:DeletePot', coords)
                                        local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, Config.Crack.props.pan, false, false, false)
                                        if DoesEntityExist(pot) then
                                            SetEntityAsMissionEntity(pot, true, true)
                                            DeleteObject(pot)
                                            SetEntityAsNoLongerNeeded(pot)
                                        end
                                    end
                                end)
                            end
                            IsPlaceing = false
                        end
                    end
                end,1)
            end
        end)
    else
        local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, Config.Crack.props.fireplace, false, false, false)
        if not pot or pot == 0 then return end
        local potcoords = GetEntityCoords(pot)
        local center = GetObjectCenter(Config.Crack.props.fireplace, potcoords)
        lookEnt(center)
        PlayAnim("random@domestic", "pickup_low", false)
        Wait(1000)
        ClearPedTasks(ped)
        TriggerServerEvent('flex-jail:server:crack:PlacePot', coords)
    end
end)

-- Delete Pot
RegisterNetEvent('flex-jail:client:crack:DeletePot', function(coords)
    local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, Config.Crack.props.pan, false, false, false)
    if DoesEntityExist(pot) then
        SetEntityAsMissionEntity(pot, true, true)
        DeleteObject(pot)
        SetEntityAsNoLongerNeeded(pot)
    end
end)

-- Place pot on fire
RegisterNetEvent('flex-jail:client:crack:PlacePot', function(coords)
    -- lib.callback('flex-jail:server:crack:HasItems', false, function(HasItems)
    --     if HasItems then
            LoadModel(Config.Crack.props.pan)
            local pot = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, Config.Crack.props.fireplace, false, false, false)
            if not pot or pot == 0 then return end
            local potcoords = GetEntityCoords(pot)
            local center = GetObjectCenter(Config.Crack.props.fireplace, potcoords)
            Pans[#Pans + 1] = CreateObject(joaat(Config.Crack.props.pan), center.x, center.y, center.z, false, true, true)
            SetEntityHeading(Pans[#Pans], GetEntityHeading(PlayerPedId()))
            FreezeEntityPosition(Pans[#Pans],true)
            TriggerServerEvent('flex-jail:server:crack:RemoveItem', 2)
            FirePlaceTargets[#FirePlaceTargets + 1] = exports.ox_target:addLocalEntity(Pans[#Pans],
            {
                {
                    name = Lang:t('target.crack.bake'),
                    icon = "fa-solid fa-fire",
                    label = Lang:t('target.crack.bake'),
                    distance = Config.RayCastDistance.fireplace,
                    canInteract = function(entity, coords, distance)
                        local IsInJail = lib.callback.await('flex-jail:server:IsPlayerInJail')
                        return IsInJail
                    end,
                    onSelect = function(args)
                        lib.callback('flex-jail:server:crack:HasItems', false, function(HasItems)
                            if HasItems then
                                TriggerServerEvent('flex-jail:server:crack:RemoveItem', 3)
                                lookEnt(center)
                                if lib.progressBar({
                                    duration = 5000,
                                    label = Lang:t('progress.crack.bake'),
                                    useWhileDead = false,
                                    canCancel = false,
                                    disable = { move = false, car = true, combat = true, mouse = false, },
                                    anim = {
                                        dict = 'missmechanic',
                                        clip = 'work2_base',
                                    },
                                    prop = {
                                        model = 'prop_cs_script_bottle',
                                        bone = 60309,
                                        pos = {
                                            x = -0.03,
                                            y = 0.0,
                                            z = 0.0600
                                        },
                                        rot = {
                                            x = 0.0,
                                            y = 180.0,
                                            z = 0.0
                                        },
                                    }
                                }) then
                                    TriggerServerEvent('flex-jail:server:crack:Particles', 'core', 'ent_amb_torch_fire', vec3(center.x, center.y, center.z-.3), 1.0, Config.Crack.settings.baketime * 1000)
                                    if lib.progressBar({
                                        duration = Config.Crack.settings.baketime * 1000,
                                        label = Lang:t('progress.crack.bake'),
                                        useWhileDead = false,
                                        canCancel = false,
                                        disable = { move = false, car = true, combat = true, mouse = false, },
                                        anim = {},
                                        prop = {}
                                    }) then
                                        TriggerServerEvent('flex-jail:server:crack:AddItem', 4)
                                    end
                                end
                            end
                        end,3)
                    end,
                },
            })
        -- end
    -- end,2)
end)

-- Particles effect
RegisterNetEvent('flex-jail:client:crack:Particles', function(dict, particleName, coords, scale, time)
    IsBaking = true
    showLoopParticle(dict, particleName, coords, scale, time)
    IsBaking = false
end)

-- Register New Findable target after found timer
RegisterNetEvent('flex-jail:client:crack:ReTarget', function(info, id)
    local IsInJail = lib.callback.await('flex-jail:server:IsPlayerInJail')
    local IsPolice = lib.callback.await('flex-jail:server:IsPlayerPolice')
    if IsInJail or IsPolice then
        Findables[id] = CreateObject(joaat(info.prop), info.coords.x, info.coords.y, info.coords.z, false, true, true)
        SetEntityHeading(Findables[id], info.coords.w)
        -- PlaceObjectOnGroundProperly(Findables[id])
        RegisterFindableTarget(Findables[id], id)
    end
end)

-- Register New Findable target after found timer
RegisterNetEvent('flex-jail:client:crack:DeleteFindable', function(id)
    local IsInJail = lib.callback.await('flex-jail:server:IsPlayerInJail')
    local IsPolice = lib.callback.await('flex-jail:server:IsPlayerPolice')
    if IsInJail or IsPolice then
        if DoesEntityExist(Findables[id]) then
            DeleteEntity(Findables[id])
        end
        Findables[id] = nil
    end
end)

-- Register Findable target
function RegisterFindableTarget(object, id)
    exports.ox_target:addLocalEntity(object,
    {
        {
            name = Lang:t('target.crack.take'),
            icon = "fa-solid fa-hand",
            label = Lang:t('target.crack.take'),
            distance = Config.RayCastDistance.default,
            canInteract = function(entity, coords, distance)
                local IsInJail = lib.callback.await('flex-jail:server:IsPlayerInJail')
                return IsInJail
            end,
            onSelect = function(args)
                lookEnt(GetEntityCoords(object))
                PlayAnim("random@domestic", "pickup_low", false)
                Wait(1000)
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent('flex-jail:server:crack:Retarget', id)
                if DoesEntityExist(object) then
                    TriggerServerEvent('flex-jail:server:crack:GiveFindable', id)
                    exports.ox_target:removeLocalEntity(object)
                end
            end,
        },
    })
end

-- On resource stop
AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        for k, target in pairs(FirePlaceTargets) do
            exports.ox_target:removeLocalEntity(target)
        end
        for k, entity in pairs(Pans) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
        for k, entity in pairs(CampFires) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
        for k, entity in pairs(Findables) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
end)