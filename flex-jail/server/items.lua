local QBCore = exports['qb-core']:GetCoreObject()

if Config.UsableItems then
    QBCore.Functions.CreateUseableItem(Config.UsableItems.secretstash, function(source, item)
        if not exports['flex-jail']:IsPlayerInJail(source) then return end
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        TriggerClientEvent('flex-jail:client:SecretStash', source)
    end)

    QBCore.Functions.CreateUseableItem(Config.UsableItems.crack.pot, function(source, item)
        if not exports['flex-jail']:IsPlayerInJail(source) then return end
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        TriggerClientEvent('flex-jail:client:crack:PlaceFire', source)
    end)
end