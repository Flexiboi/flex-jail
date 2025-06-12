local QBCore = exports['qb-core']:GetCoreObject()
local Stashes = {}
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

-- Register Stashes
function RegisterStashes()
    for k, v in pairs(Config.Location.stashes) do
        local loc = v.location
        Stashes[#Stashes+1] = exports.ox_target:addBoxZone({
            coords = loc.xyz, size = v.boxzone, rotation = loc.w, debug = Config.Debug,
            options = {
                { 
                    icon  = 'fas fa-swords',
                    label = Lang:t('target.storage'),
                    canInteract = function() 
                        if v.job then
                            if table.contains(v.job, PlayerJob.name) then
                                return true
                            else
                                return false
                            end
                        else
                            return true
                        end
                    end, 
                    onSelect = function() 
                        local id = v.stashname..'_'..k
                        if not exports.ox_inventory:openInventory('stash', id) then
                            TriggerServerEvent('flex-jail:server:RegisterOxStash', id, v.slots, v.size)
                            exports.ox_inventory:openInventory('stash', id)
                        end
                    end
                },
            }
        })
    end
end

AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        for k, v in pairs(Stashes) do
            exports.ox_target:removeZone(v)
        end
    end
end)