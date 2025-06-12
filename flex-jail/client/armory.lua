local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local player = QBCore.Functions.GetPlayerData()
    PlayerJob = player.job
end)

RegisterNetEvent("QBCore:Client:SetDuty", function(newDuty)
    PlayerJob.onduty = newDuty
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
        PlayerJob = QBCore.Functions.GetPlayerData().job
   end
end)

CreateThread(function()
    for k, v in pairs(Config.Location.armory) do
        if GetResourceState('ox_inventory') ~= 'missing' then
            exports.ox_target:addBoxZone({
                coords = vector3(v.x, v.y, v.z), size = vec3(5.0, 2.0, 2.5), rotation = 0.0, debug = Config.Debug,
                options = {
                    { 
                        icon  = 'fas fa-swords',
                        label = Lang:t('target.armory'),
                        canInteract = function() 
                            if PlayerJob.name == "doc" then return true end
                        end, 
                        onSelect = function() 
                            TriggerEvent("flex-jail:client:openArmory")
                        end
                    },
                }
            })
        else
            exports['qb-target']:AddBoxZone(Lang:t('target.armory'), vector3(v.x, v.y, v.z), 5.0, 2.0, { name=Lang:t('target.armory'), heading=0.0, debugPoly = Config.Debug }, {
                options = {
                    {
                        icon  = 'fas fa-swords',
                        label = Lang:t('target.armory'),
                        canInteract = function()
                            if PlayerJob.name == "doc" then return true end
                        end,
                        action = function()
                            TriggerEvent("flex-jail:client:openArmory")
                        end
                    },
                },
                distance = 2.5
            })
        end
    end
end)

local function SetWeaponSeries()
    for k, _ in pairs(Config.Armory.items) do
        if k < 6 then
            Config.Armory.items[k].info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
        end
    end
end

RegisterNetEvent('flex-jail:client:openArmory', function()
    local authorizedItems = {
        label = Config.Armory.label,
        slots = Config.Armory.slots,
        items = {}
    }
    local index = 1
    for _, armoryItem in pairs(Config.Armory.items) do
        for i=1, #armoryItem.authorizedJobGrades do
            if armoryItem.authorizedJobGrades[i] == PlayerJob.grade.level then
                authorizedItems.items[index] = armoryItem
                authorizedItems.items[index].slot = index
                index = index + 1
            end
        end
    end
    SetWeaponSeries()
    TriggerServerEvent('flex-jail:server:openShop', 'policeshop', authorizedItems)
end)