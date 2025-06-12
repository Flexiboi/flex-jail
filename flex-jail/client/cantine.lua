local QBCore = exports['qb-core']:GetCoreObject()
local CantinerPed = nil

-- Spawn washing job ped
function CantinePed()
    if CantinerPed ~= nil then return end
    CantinerPed = LoadPed(Config.Location.peds.cantine.loc, Config.Location.peds.cantine.model, Config.Location.peds.cantine.scenario)
    exports.ox_target:addLocalEntity(CantinerPed,{			
        {
            name = Lang:t('target.cantine.shop'),
            label = Lang:t('target.cantine.shop'),
            distance = 3.0,
            icon = 'fas fa-hand',
            onSelect = function(args)
                OpenShop()
            end,
        },
    })
end

-- Main Shop Menu
function OpenShop()
    lookEnt(Config.Location.peds.cantine.loc.xyz)
    local IsInJail = lib.callback.await('flex-jail:server:IsPlayerInJail')
    local IsOfficer = lib.callback.await('flex-jail:server:IsPlayerOfficer')
    local options = {
        {
            title = Lang:t('menu.shop.food.title'),
            description = Lang:t('menu.shop.food.desc'),
            icon = "fa-solid fa-utensils",
            event = "flex-jail:client:cantine:OpenFoodshop",
            args = {
            },
        },
    }

    if IsInJail then
        options[#options + 1] = {
            title = Lang:t('menu.shop.pointshop.title'),
            description = Lang:t('menu.shop.pointshop.desc'),
            icon = "fa-solid fa-coins",
            event = "flex-jail:client:cantine:OpenPointshop",
            args = {
            },
        }

        options[#options + 1] = {
            title = Lang:t('menu.checkmoney.title'),
            description = Lang:t('menu.checkmoney.desc'),
            icon = "fa-solid fa-euro-sign",
            onSelect = function()
                QBCore.Functions.Notify(Lang:t("info.getmoneybalance", {value = QBCore.Functions.GetPlayerData().money['bank']}), 'info', 3000)
            end,
            args = {
            },
        }

        options[#options + 1] = {
            title = Lang:t('menu.jailtime.title'),
            description = Lang:t('menu.jailtime.desc'),
            icon = "fa-solid fa-calendar-days",
            event = "flex-jail:client:GetTimeInJail",
            args = {
            },
        }

        if GetResourceState('randol_paycheck') ~= 'missing' then
            options[#options + 1] = {
                title = Lang:t('menu.paycheck'),
                description = Lang:t('menu.paycheck'),
                icon = "fa-solid fa-landmark",
                onSelect = function(args)
                    exports['randol_paycheck']:viewPaycheckBankOnly()
                end,
                args = {
                },
            }
        end
    end

    if not IsOfficer then
        options[#options + 1] = {
            title = Lang:t('menu.shop.illegal.title'),
            description = Lang:t('menu.shop.illegal.desc'),
            icon = "fa-solid fa-mask",
            event = "flex-jail:client:cantine:OpenIllegalShop",
            args = {
            },
        }
    end

    Wait(500)
    lib.registerContext({
        id = Lang:t('menu.shop.mainmenu'),
        title = Lang:t('menu.shop.mainmenu'),
        menu = Lang:t('menu.back'),
        -- onBack = function() OpenShop() end,
        options = options,
    })
    lib.showContext(Lang:t('menu.shop.mainmenu'))
end

-- Open food mnenu
RegisterNetEvent('flex-jail:client:cantine:OpenFoodshop', function()
    lib.callback('flex-jail:server:GetShopitems', false, function(shopitems)
        if shopitems then
            local options = {}
            for k, v in pairs(shopitems) do
                if GetResourceState('ox_inventory') == 'missing' then
                    options[#options + 1] = {
                        title = Lang:t('menu.shop.buy', {value = QBCore.Shared.Items[v.name].label, value2 = Lang:t('menu.shop.curency'), value3 = v.price}),
                        description = Lang:t('menu.shop.stock', {value = v.amount}),
                        icon = "nui://"..Config.Inv..QBCore.Shared.Items[v.name].image,
                        image = "nui://"..Config.Inv..QBCore.Shared.Items[v.name].image,
                        event = "flex-jail:client:cantine:CatineAmountInput",
                        disabled = v.amount <= 0,
                        args = {
                            shoptype = 'cantine',
                            slot = k,
                            name = v.name,
                        },
                    }
                else
                    local img = "nui://"..Config.Inv..v.name..'.png'
                    if exports.ox_inventory:Items(v.name).client then
                        if exports.ox_inventory:Items(v.name).client.image then
                            img = exports.ox_inventory:Items(v.name).client.image or "nui://"..Config.Inv..v.name..'.png'
                        end
                    end
                    options[#options + 1] = {
                        title = Lang:t('menu.shop.buy', {value = exports.ox_inventory:Items(v.name).label, value2 = Lang:t('menu.shop.curency'), value3 = v.price}),
                        description = Lang:t('menu.shop.stock', {value = v.amount}),
                        icon = img,
                        image = img,
                        event = "flex-jail:client:cantine:CatineAmountInput",
                        disabled = v.amount <= 0,
                        args = {
                            shoptype = 'cantine',
                            slot = k,
                            name = v.name,
                        },
                    }
                end
            end
            lib.registerContext({
                id = Lang:t('menu.shop.food.title'),
                title = Lang:t('menu.shop.food.title'),
                menu = Lang:t('menu.back'),
                onBack = function() OpenShop() end,
                options = options,
            })
            lib.showContext(Lang:t('menu.shop.food.title'))
        end
    end, 'cantine')
end)

-- Input to tell how many you want to buy
RegisterNetEvent('flex-jail:client:cantine:CatineAmountInput', function(data)
    local amount = 0
    if GetResourceState('ox_inventory') == 'missing' then
        amount = lib.inputDialog(Lang:t('menu.shop.amount.title', {value = QBCore.Shared.Items[data.name].label}), {
            { type = 'input', label = Lang:t('menu.shop.amount.desc'), required = true} 
        })
    else
        amount = lib.inputDialog(Lang:t('menu.shop.amount.title', {value = exports.ox_inventory:Items(data.name).label}), {
            { type = 'input', label = Lang:t('menu.shop.amount.desc'), required = true} 
        })
    end
    if tonumber(amount[1]) > 0 then
        TriggerServerEvent('flex-jail:server:cantine:Buy', data, tonumber(amount[1]))
    end
end)

-- Open jailpoints shop
RegisterNetEvent('flex-jail:client:cantine:OpenPointshop', function()
    lib.callback('flex-jail:server:GetShopitems', false, function(shopitems)
        if shopitems then
            local options = {}
            for k, v in pairs(shopitems) do
                options[#options + 1] = {
                    title = v.label,
                    description = Lang:t('menu.shop.buy', {value = '', value2 = v.points, value3 = ' jp'}),
                    serverEvent = "flex-jail:server:cantine:Buy",
                    args = {
                        shoptype = 'jp',
                        slot = k,
                    },
                }
            end
            lib.registerContext({
                id = Lang:t('menu.shop.pointshop.title'),
                title = Lang:t('menu.shop.pointshop.title'),
                menu = Lang:t('menu.back'),
                onBack = function() OpenShop() end,
                options = options,
            })
            lib.showContext(Lang:t('menu.shop.pointshop.title'))
        end
    end, 'jp')
end)

-- Open illegal shop
RegisterNetEvent('flex-jail:client:cantine:OpenIllegalShop', function()
    lib.callback('flex-jail:server:GetShopitems', false, function(shopitems)
        if shopitems then
            local options = {}
            for k, v in pairs(shopitems) do
                if GetResourceState('ox_inventory') == 'missing' then
                    options[#options + 1] = {
                        title = Lang:t('menu.shop.buy', {value = QBCore.Shared.Items[v.name].label, value2 = Lang:t('menu.shop.curency'), value3 = v.price}),
                        description = Lang:t('menu.shop.stock', {value = v.amount}),
                        icon = "nui://"..Config.Inv..QBCore.Shared.Items[v.name].image,
                        image = "nui://"..Config.Inv..QBCore.Shared.Items[v.name].image,
                        serverEvent = "flex-jail:server:cantine:Buy",
                        disabled = v.amount <= 0,
                        args = {
                            shoptype = 'illegal',
                            slot = k,
                        },
                    }
                else
                    local img = "nui://"..Config.Inv..v.name..'.png'
                    if exports.ox_inventory:Items(v.name).client then
                        if exports.ox_inventory:Items(v.name).client.image then
                            img = exports.ox_inventory:Items(v.name).client.image or "nui://"..Config.Inv..v.name..'.png'
                        end
                    end
                    options[#options + 1] = {
                        title = Lang:t('menu.shop.buy', {value = exports.ox_inventory:Items(v.name).label, value2 = Lang:t('menu.shop.curency'), value3 = v.price}),
                        description = Lang:t('menu.shop.stock', {value = v.amount}),
                        icon = img,
                        image = img,
                        serverEvent = "flex-jail:server:cantine:Buy",
                        disabled = v.amount <= 0,
                        args = {
                            shoptype = 'illegal',
                            slot = k,
                        },
                    }
                end
            end
            lib.registerContext({
                id = Lang:t('menu.shop.illegal.title'),
                title = Lang:t('menu.shop.illegal.title'),
                menu = Lang:t('menu.back'),
                onBack = function() OpenShop() end,
                options = options,
            })
            lib.showContext(Lang:t('menu.shop.illegal.title'))
        end
    end, 'illegal')
end)

-- On resource stop
AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        exports.ox_target:removeLocalEntity(CantinerPed)
    end
end)