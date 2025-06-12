local QBCore = exports['qb-core']:GetCoreObject()
local props = {}
function DeleteProps()
    for _, v in pairs(props) do
        DeleteEntity(v)
    end
end

RegisterNetEvent('flex-jail:client:useables:eatdrink', function(item, policeambu)
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    local pos = GetEntityCoords(ped)
    local animDic, anim, flag, bone, scenario = nil, nil, 0, nil, nil
    local text, metaData = nil, nil
    if string.lower(Config.EatDrinkItems[item].propinfo.animation) == 'eat' then
        animDic = "mp_player_inteat@burger"
        anim = "mp_player_int_eat_burger"
        flag = 51
        text = Lang:t("progress.eatdrink.eating")
        metaData = 'hunger'
    elseif string.lower(Config.EatDrinkItems[item].propinfo.animation) == 'drink' then
        animDic = "mp_player_intdrink"
        anim = "loop_bottle"
        flag = 51
        text = Lang:t("progress.eatdrink.drinking")
        metaData = 'thirst'
    elseif string.lower(Config.EatDrinkItems[item].propinfo.animation) == 'warmdrink' then
        animDic = "amb@world_human_drinking@coffee@male@idle_a"
        anim = "idle_c"
        flag = 51
        text = Lang:t("progress.eatdrink.drinking")
        metaData = 'thirst'
    elseif string.lower(Config.EatDrinkItems[item].propinfo.animation) == 'smoke' then
        animDic = "amb@world_human_aa_smoke@male@idle_a"
        anim = "idle_b"
        flag = 51
        text = Lang:t("progress.eatdrink.smoking")
        metaData = 'hunger'
    elseif string.lower(Config.EatDrinkItems[item].propinfo.animation) == 'joint' then
        animDic = "amb@world_human_aa_smoke@male@idle_a"
        anim = "idle_b"
        flag = 51
        scenario = "WORLD_HUMAN_SMOKING_POT"
        text = Lang:t("progress.eatdrink.smoking")
        metaData = 'hunger'
    elseif string.lower(Config.EatDrinkItems[item].propinfo.animation) == 'drugs' then
        animDic = "switch@trevor@trev_smoking_meth"
        anim = "trev_smoking_meth_loop"
        flag = 49
        text = Lang:t("progress.eatdrink.drugs")
        metaData = 'hunger'
    elseif string.lower(Config.EatDrinkItems[item].propinfo.animation) == 'pill' then
        animDic = "mp_suicide"
        anim = "pill"
        flag = 49
        text = Lang:t("progress.eatdrink.pill")
        metaData = 'hunger'
    else
        return QBCore.Functions.Notify(Lang:t("error.error404"), "error", 4500)
    end
    props[item] = CreateObject(joaat(Config.EatDrinkItems[item].propinfo.proppos.prop), pos.x, pos.y, pos.z + 0.2, true, true, true)
    SetEntityCollision(props[item], false, false)
    AttachEntityToEntity(props[item], ped, GetPedBoneIndex(ped, Config.EatDrinkItems[item].propinfo.proppos.bone), Config.EatDrinkItems[item].propinfo.proppos.xPos, Config.EatDrinkItems[item].propinfo.proppos.yPos, Config.EatDrinkItems[item].propinfo.proppos.zPos, Config.EatDrinkItems[item].propinfo.proppos.xRot, Config.EatDrinkItems[item].propinfo.proppos.yRot, Config.EatDrinkItems[item].propinfo.proppos.zRot, true, true, false, true, 1, true)
    if scenario ~= nil then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end
    QBCore.Functions.Progressbar("eatdrinksmokedrugs", text, Config.EatDrinkItems[item].consumetime * 1000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = animDic,
        anim = anim,
        flags = flag,
        task = nil,
    }, {}, {},function()
        ClearPedTasks(ped)
        TriggerServerEvent("flex-jail:server:useables:UpdatePlayer", metaData, Config.EatDrinkItems[item].addamount)
        TriggerServerEvent('flex-jail:server:useables:RemoveItem', item, 1)
        DeleteProps()
        CreateThread(function()
            if Config.EatDrinkItems[item].isalcohol then
                alcoholCount = alcoholCount + 1
                if alcoholCount > 1 and alcoholCount < 4 then
                    TriggerEvent("evidence:client:SetStatus", "alcohol", 2000)
                elseif alcoholCount >= 4 then
                    TriggerEvent("evidence:client:SetStatus", "heavyalcohol", 2000)
                end
            end
        end)
        CreateThread(function()
            if Config.EatDrinkItems[item].stresreleave >= 1 then
                ReleaveStress(Config.EatDrinkItems[item].consumetime, Config.EatDrinkItems[item].stresreleave)
            end
        end)
        CreateThread(function()
            if Config.EatDrinkItems[item].runspeed.stamina ~= false then
                RunSpeed(Config.EatDrinkItems[item].runspeed.stamina, Config.EatDrinkItems[item].runspeed.multiply, Config.EatDrinkItems[item].runspeed.losechance)
            end
        end)
        CreateThread(function()
            if Config.EatDrinkItems[item].effect and Config.EatDrinkItems[item].effectAddAmount then
                effect(Config.EatDrinkItems[item].effect, Config.EatDrinkItems[item].effectAddAmount)
            elseif Config.EatDrinkItems[item].effect then
                effect(Config.EatDrinkItems[item].effect, nil)
            end
        end)
        CreateThread(function()
            if Config.EatDrinkItems[item].reward.item ~= nil then
                TriggerServerEvent('flex-jail:server:useables:Additem', Config.EatDrinkItems[item].reward.item, amount)
            end
        end)
        CreateThread(function()
            if policeambu then
                QBCore.Functions.Notify(Lang:t("error.allergy"), "error", 4500)
                if Config.EatDrinkItems[item].policeambu.die then
                    SetEntityHealth(ped, 0)
                else
                    SetPedToRagdoll(ped, 4000, 4000, 0, 0, 0, 0)
                end
            end
        end)
    end, function()
        ClearPedTasks(ped)
        DeleteProps()
        QBCore.Functions.Notify(Lang:t("error.canceled"), "error", 4500)
    end) 
end)