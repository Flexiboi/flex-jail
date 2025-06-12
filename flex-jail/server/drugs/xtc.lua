local QBCore = nil 
local ESX = nil

if Config.XTC.framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.XTC.framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end

-- add item
RegisterNetEvent('solos-xtc:server:itemadd', function(item, amount, bool)
    local src = source

    if Config.XTC.framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddItem(item, amount, bool)
    elseif Config.XTC.framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addInventoryItem(item, amount)
    end
end)

-- remove item
RegisterNetEvent('solos-xtc:server:itemremove', function(item, amount, bool)
    local src = source
    if Config.XTC.framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveItem(item, amount, bool)
    elseif Config.XTC.framework == "ESX" then
        local Player = ESX.GetPlayerFromId(src)
        Player.removeInventoryItem(item, amount)
    end
end)


