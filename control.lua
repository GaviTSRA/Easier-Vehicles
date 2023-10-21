script.on_event(defines.events.on_built_entity, function(e)
   local player = game.players[e.player_index]

   local VEHICLE_TYPES = {
      ["car"] = true,
      ["locomotive"] = true,
      ["spider-vehicle"] = true,
   }

   game.print(e.created_entity.type)


   if not player.driving and VEHICLE_TYPES[e.created_entity.type] then
      e.created_entity.set_driver(player)
   end
end)

function enter_vehicle(player, e)
   e.set_driver(player)
end

script.on_event("leave-mine", function(e)
   local player = game.players[e.player_index]
   
   if not player.driving then
      return
   end

   entity = player.vehicle
   entity.mine({force=true, inventory=player.character.get_main_inventory()})
end)

script.on_event(defines.events.on_player_driving_changed_state, function(e)
   if e.entity.get_driver() ~= nil then
      on_enter(e)
   end
end)

function fuel_vehicle(e, entity)
   if entity.get_fuel_inventory() == nil then
      return
   end

   if not entity.get_fuel_inventory().is_empty() then
      return
   end

   local player = game.players[e.player_index]

   local fuels = {}
   for k,v in pairs(game.item_prototypes) do
      if v.fuel_value > 0 and entity.get_fuel_inventory().can_insert(k) then
         table.insert(fuels, v)
      end
   end

   table.sort(fuels, function(a,b) return a.fuel_value > b.fuel_value end)

   for i, v in pairs(fuels) do
      if player.get_item_count(v.name) > 0 then
         amount = math.min(player.get_item_count(v.name), v.stack_size)
         game.print({"", "Inserted " .. amount .. " ", {"item-name." .. v.name}})
         entity.insert{name=v.name, count=amount}
         player.remove_item{name=v.name, count=amount}
         return
      end
   end
   game.print("No fuel to insert!")
end

function on_enter(e)
   local player = game.players[e.player_index]
   if e.entity.get_driver() ~= nil and e.entity.get_driver().player == player then
      fuel_vehicle(e, e.entity)
   end
end
