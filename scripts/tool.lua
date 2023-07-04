local table = require('__stdlib__/stdlib/utils/table')
local Util = require('util')

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= Config.TOOL_NAME then return end

  local player = game.players[event.player_index]

  -- Collect inserters that pickup or drop from/to a linked chest. Index them by the entity on
  -- the other end of the inserter so the calls to setChestFilter will appropriately cycle.
  local pickups = {}
  local drops = {}
  table.each(player.surface.find_entities_filtered{type = "inserter", area = event.area}, function(v)
    if v.drop_target and v.pickup_target then
      if v.pickup_target.name == Config.CHEST_NAME then
        local id = v.drop_target.unit_number
        pickups[id] = pickups[id] or {}
        table.insert(pickups[id], {chest = v.pickup_target, source = v.drop_target})
      elseif v.drop_target.name == Config.CHEST_NAME then
        local id = v.pickup_target.unit_number
        drops[id] = drops[id] or {}
        table.insert(drops[id], {chest = v.drop_target, source = v.pickup_target})
      end
    end
  end)

  -- for _, list in pairs(pickups) do
  --   for k,v in pairs(list) do
  --     Chest.setItemFilterFromSource(v.chest, v.source, false)
  --   end
  -- end
  -- for _, list in pairs(drops) do
  --   for k,v in pairs(list) do
  --     Chest.setItemFilterFromSource(v.chest, v.source, true)
  --   end
  -- end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.players[event.player_index]
  local item = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name
  game.print("stack changed: " .. (item or "nil"))
  if item == Config.TOOL_NAME then
    showGui(player)
  else
    hideGui(player)
  end
end)
script.on_event(defines.events.on_player_dropped_item, function(event)
  local player = game.players[event.player_index]
  game.print("stack dropped")
  if event.entity and event.entity.stack and event.entity.stack.name == Config.TOOL_NAME then
    game.print("stack dropped: " .. (event.entity.stack.name))
    event.entity.stack.clear()
    hideGui(player)
  end
end)