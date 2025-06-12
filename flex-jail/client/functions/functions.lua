local QBCore = exports['qb-core']:GetCoreObject()
local Peds = {}
function LoadPed(coords, model, scenario)
    local current = type(model) == 'number' and model or joaat(model)
    RequestModel(current)
    while not HasModelLoaded(current) do Wait(0) end
    Peds[#Peds+1] = CreatePed(0, current, coords.x, coords.y, coords.z - 1, coords.w, false, false)
    if scenario then
        TaskStartScenarioInPlace(Peds[#Peds], scenario, 0, true)
    end
    FreezeEntityPosition(Peds[#Peds], true)
    SetEntityInvincible(Peds[#Peds], true)
    SetBlockingOfNonTemporaryEvents(Peds[#Peds], true)
    return Peds[#Peds]
end

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function lookEnt(entity)
	if type(entity) == "vector3" then
		if not IsPedHeadingTowardsPosition(PlayerPedId(), entity, 10.0) then
			TaskTurnPedToFaceCoord(PlayerPedId(), entity, 1500)
			if Config.Debug then print("^5Debug^7: ^2Turning Player to^7: '^6"..json.encode(entity).."^7'") end
			Wait(1500)
		end
	else
		if DoesEntityExist(entity) then
			if not IsPedHeadingTowardsPosition(PlayerPedId(), GetEntityCoords(entity), 30.0) then
				TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(entity), 1500)
				if Config.Debug then print("^5Debug^7: ^2Turning Player to^7: '^6"..entity.."^7'") end
				Wait(1500)
			end
		end
	end
end

function createBlip(data)
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)
    return blip
end

function showLoopParticle(dict, particleName, coords, scale, time)
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do Wait(0) end
    SetPtfxAssetNextCall(dict)
    local particle = StartParticleFxLoopedAtCoord(particleName, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, scale, false, false, false, false)
    if time then
        Wait(time)
        if particle == nil then return end
        StopParticleFxLooped(particle, 0)
    end
end

function GetObjectCenter(objectModel, objectCoords)
    local minDim, maxDim = GetModelDimensions(objectModel)
    local centerOffset = (maxDim + minDim) / 2
    
    -- Calculate adjusted center
    local objectCenter = vector3(
        objectCoords.x + centerOffset.x,
        objectCoords.y + centerOffset.y,
        objectCoords.z + centerOffset.z
    )
    return objectCenter
end

function RespawnInJail()
    if Config.SpawnBackWhenBuggedOutPrison then
        local ped = PlayerPedId()
        local dist = #(GetEntityCoords(ped) - Config.Location.release.xyz)
        if dist > Config.RespawnDistanceCheck.min and dist < Config.RespawnDistanceCheck.max then
            local conf = Config.Location.jailspawn[math.random(1, #Config.Location.jailspawn)]
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
            DoScreenFadeIn(800)
        end
    end
end

function InitiateInmate()
    lib.callback('flex-jail:server:GetTimeInJail', false, function(time)
        if time then
            if time > 0 then
                QBCore.Functions.Notify(Lang:t("info.timeinjail", {value = tostring(time)}), 'info', 3000)
                if DoesEntityExist(PlayerPedId()) then
                    SetPedArmour(PlayerPedId(), 0)
                    ClearPedBloodDamage(PlayerPedId())
                    ResetPedVisibleDamage(PlayerPedId())
                    ClearPedLastWeaponDamage(PlayerPedId())
                    ResetPedMovementClipset(PlayerPedId(), 0)
                    local gender = QBCore.Functions.GetPlayerData().charinfo.gender
                    if gender == 0 then
                        TriggerEvent('qb-clothing:client:loadOutfit', Config.PrisonClothes.m)
                    else
                        TriggerEvent('qb-clothing:client:loadOutfit', Config.PrisonClothes.f)
                    end
                end
            elseif time == -1 then
                QBCore.Functions.Notify(Lang:t('menu.playersinjail.lifetimeinjail'), 'info', 3000)
            end
        end
    end, id)
end

function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0) -- Wait until the model is loaded
    end
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        for k, entity in pairs(Peds) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
end)