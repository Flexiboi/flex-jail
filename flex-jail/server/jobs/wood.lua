local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('flex-jail:server:wood:Sell', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.citizennothere'), 'error') end
    local items = Config.JobSettings.wood.sellItemList
    for k, v in pairs(items) do
        local item = Player.Functions.GetItemByName(k)
        if item ~= nil then
            local amount = item.amount
            if amount ~= nil then
                if amount >= (v or 1) then
                    if Player.Functions.RemoveItem(k, amount, false, nil) then
                        if GetResourceState('ox_inventory') == 'missing' then
                            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[k], 'remove', amount or 1)
                        end
                        TriggerEvent('flex-jail:server:AddJailPoints', source, amount)
                    end
                end
            end
        end
    end
end)