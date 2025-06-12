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
    for k, v in pairs(Config.Location.evidence) do
        if GetResourceState('ox_inventory') ~= 'missing' then
            exports.ox_target:addBoxZone({
                coords = vector3(v.x, v.y, v.z), size = vec3(5.0, 2.0, 2.5), rotation = 0.0, debug = Config.Debug,
                options = {
                    { 
                        icon  = 'fa-solid fa-folder-open',
                        label = Lang:t('target.evidence'),
                        canInteract = function() 
                            if PlayerJob.name == "doc" then return true end
                        end, 
                        onSelect = function()
                            local currentEvidence = 0
                            local pos = GetEntityCoords(PlayerPedId())
        
                            for k, v in pairs(Config.Location.evidence) do
                                if #(pos - v) < 2 then
                                    currentEvidence = k
                                end
                            end
                            local EvidenceStash = {}
                            EvidenceStash[#EvidenceStash + 1] = {
                                title = Lang:t('menu.evd_drawer_h'),
                                description = Lang:t('menu.evd_drawer_b'),
                                icon = 'list-ol',
                                event = 'flex-jail:client:EvidenceStashDrawer',
                                args = {type = 'drawer', number = currentEvidence},
                            }
                            EvidenceStash[#EvidenceStash + 1] = {
                                title = Lang:t('menu.evd_stash_h'),
                                description = Lang:t('menu.evd_stash_b'),
                                icon = 'folder-closed',
                                event = 'flex-jail:client:EvidenceStashDrawer',
                                args = {type = 'stash',number = currentEvidence},
                            }

                            lib.registerContext({
                                id = 'police_evidencestash_menu',
                                title = PlayerJob.label,
                                menu = Lang:t('menu.back'),
                                icon = "building-shield",
                                options = EvidenceStash,
                            })
                            lib.showContext('police_evidencestash_menu')
                        end,
                    },
                }
            })
        else
            exports['qb-target']:AddBoxZone(Lang:t('target.armory'), vector3(v.x, v.y, v.z), 5.0, 2.0, { name=Lang:t('target.armory'), heading=0.0, debugPoly = Config.Debug }, {
                options = {
                    {
                        icon  = 'fa-solid fa-folder-open',
                        label = Lang:t('target.evidence'),
                        canInteract = function()
                            if PlayerJob.name == "doc" then return true end
                        end,
                        action = function()
                            local currentEvidence = 0
                            local pos = GetEntityCoords(PlayerPedId())
        
                            for k, v in pairs(Config.Location.evidence) do
                                if #(pos - v) < 2 then
                                    currentEvidence = k
                                end
                            end
                            local EvidenceStash = {}
                            EvidenceStash[#EvidenceStash + 1] = {
                                title = Lang:t('menu.evd_drawer_h'),
                                description = Lang:t('menu.evd_drawer_b'),
                                icon = 'list-ol',
                                event = 'flex-jail:client:EvidenceStashDrawer',
                                args = {type = 'drawer', number = currentEvidence},
                            }
                            EvidenceStash[#EvidenceStash + 1] = {
                                title = Lang:t('menu.evd_stash_h'),
                                description = Lang:t('menu.evd_stash_b'),
                                icon = 'folder-closed',
                                event = 'flex-jail:client:EvidenceStashDrawer',
                                args = {type = 'stash',number = currentEvidence},
                            }

                            lib.registerContext({
                                id = 'police_evidencestash_menu',
                                title = PlayerJob.label,
                                menu = Lang:t('menu.back'),
                                icon = "building-shield",
                                options = EvidenceStash,
                            })
                            lib.showContext('police_evidencestash_menu')
                        end,
                    },
                },
                distance = 2.5
            })
        end
    end
end)

RegisterNetEvent('flex-jail:client:EvidenceStashDrawer', function(data)
    local currentEvidence = data.number
    local currentType = data.type
    local pos = GetEntityCoords(PlayerPedId())
    local takeLoc = Config.Location.evidence[currentEvidence]
    if not takeLoc then return end

    if #(pos - takeLoc) <= 5.0 then
        if currentType == 'drawer' then
            local drawer = lib.inputDialog(Lang:t('menu.drawer.label'), {
                { type = 'input', label = Lang:t('menu.drawer.desc'), required = true} 
            })
            if drawer then
                if not drawer[1] then return end
                if GetResourceState('ox_inventory') ~= 'missing' then
                    local id = 'drawer_doc_'..tonumber(drawer[1])
                    local name = Lang:t('menu.current_evidence_doc', {value = currentEvidence, value2 = tonumber(drawer[1])})
                    TriggerServerEvent('flex-jail:server:openStash', id, name)
                end
            else return end
        elseif currentType == 'stash' then
            if GetResourceState('ox_inventory') ~= 'missing' then
                local id = 'generalevidence_doc_'..currentEvidence
                local name = Lang:t('menu.general_current_evidence_doc', {value = currentEvidence})
                TriggerServerEvent('flex-jail:server:openStash', id, name)
            end
        end
    end
end)