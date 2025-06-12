**What do you need?**
</br>
qb core or qbox
</br>
sql script
</br>
ox_lib
</br>
ox_target
</br>
ox_inventory or qb inv should work too not sure if i removed that functionality moving to ox
</br>
xsound

</br>
</br>
</br>
**ITEMS**
</br>
</br>
['jail_breakouttool'] = { label = 'Gatecrack', description = '', weight = 200, stack = true, close = false, durability = 100, },
</br>
['jail_secretstash'] = { label = 'Kleine opslag', description = '', weight = 1000, stack = true, close = false, durability = 100, },
</br>
['jail_secretstash2'] = { label = 'Grote opslag', description = '', weight = 2000, stack = true, close = false, durability = 100, client = { image = "jail_secretstash.png", } },
</br>
['jail_breakouttool_housing'] = { label = 'Behuizing', description = '', weight = 200, stack = true, close = false, durability = 100, },
</br>
['jail_pot'] = { label = 'Pan', description = '', weight = 2000, stack = true, close = false, durability = 100, },
</br>
['jail_rope'] = { label = 'Sterker Touw', description = '', weight = 2000, stack = true, close = false, durability = 100, },
</br>
['jail_sandwichh'] = { label = 'Broodje', description = '', weight = 200, stack = true, close = false, durability = 100, degrade = 80, client = { image = 'sandwich.png', status = { hunger = math.random(30,48) }, anim = { dict = "mp_player_inteat@burger", clip = "mp_player_int_eat_burger" }, prop = { model = 'prop_sandwich_01', pos = vec3(0.00000, -0.008500, -0.023000), rot = vec3(55.0, 16.0, 0.0) }, usetime = 2500, }, },
</br>
['jail_waterr'] = { label = 'Water', description = '', weight = 200, stack = true, close = false, durability = 100, degrade = 80, client = { image = 'water_bottle.png', status = { thirst = math.random(30,48) }, anim = { dict = "mp_player_intdrink", clip = "loop_bottle" }, prop = { model = `vw_prop_casino_water_bottle_01a`, bone = 18905, pos = vec3(0.008, 0.0, -0.05), rot = vec3(0.0, 0.0, 0.0) }, usetime = 2500, } },
