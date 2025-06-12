local Guarding = false
local Models = {
    "u_m_y_baygor",
    "a_m_y_beach_01",
}
local GuardLocations = {
    vector4(1827.87, 2619.42, 62.97, 254),
    vector4(1827.83, 2477.78, 62.70, 302)
}

RegisterNetEvent('flex-jail:server:security:Security', function(state)
    Guarding = state
    if state then
        -- TriggerClientEvent('flex-jail:client:security:CreatePeds', source, GuardLocations, Models)
    else
        TriggerClientEvent('flex-jail:client:security:SyncGuards', -1, Guarding, {})
    end
end)

RegisterNetEvent('flex-jail:server:security:SyncGuards', function(Guards)
    print(Guarding)
    TriggerClientEvent('flex-jail:client:security:SyncGuards', -1, Guarding, Guards)
end)

AddEventHandler("onResourceStop", function(resource)
    if (resource == GetCurrentResourceName()) then
        TriggerClientEvent('flex-jail:client:security:SyncGuards', -1, false)
    end
end)

lib.callback.register('flex-jail:server:security:IsGuarding', function(source)
    return Guarding
end)

-- lib.addCommand('guardjail', {
--     help = 'Bewaak de gevangenis',
--     params = {
--         {
--             name = 'state',
--             type = 'bool',
--             help = 'true or false',
--         },
--     },
--     -- restricted = 'group.admin'
-- }, function(source, args, raw)
--     TriggerEvent('flex-jail:server:security:Security', args.state)
--     TriggerClientEvent('flex-jail:client:security:CreatePeds', source, GuardLocations, Models)
-- end)