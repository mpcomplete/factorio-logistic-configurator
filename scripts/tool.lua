local table = require('__stdlib__/stdlib/utils/table')
local Util = require('util')

function debug(msg)
--  game.print(msg)
end

function isRequester(entity)
  return entity.type == "logistic-container" and
    (entity.prototype.logistic_mode == "buffer" or entity.prototype.logistic_mode == "requester")
end

function isBuffer(entity)
  return entity.type == "logistic-container" and
    entity.prototype.logistic_mode == "buffer"
end

-- Adds ingredients from the entity's current recipe.
function addIngredients(requests, entity)
  if entity.prototype.crafting_speed and entity.get_recipe() then
    for _, v in pairs(entity.get_recipe().ingredients) do
      if (v.type == "item") then
        requests[v.name] = (requests[v.name] or 0) + (entity.crafting_speed * v.amount)
      end
    end
  end
end

-- Adds science packs for a lab.
function addLabCycle(requests, entity)
  if entity.prototype.lab_inputs then
    for _, v in pairs(entity.prototype.lab_inputs) do
      requests[v] = 6 -- six is good, how about six?
    end
  end
end

function setRequester(player, chest, requests)
  if chest.request_slot_count > 0 and getRequestersSkipExisting(player) then return end

  for i = 1, chest.request_slot_count do
    chest.clear_request_slot(i)
  end

  local nextSlot = 1
  for itemName, amountConsumed in pairs(requests) do
    local amount = getRequesterAmount(player, itemName, amountConsumed)
    chest.set_request_slot({ name = itemName, count = amount }, nextSlot)
    debug("setting requester slot to " .. itemName .. " = " .. amount)
    nextSlot = nextSlot + 1
  end

  chest.request_from_buffers = getRequestersFromBuffers(player)
end

function setInserter(player, inserter)
  if inserter.get_control_behavior() and getInsertersSkipExisting(player) then return end

  local crafter = inserter.pickup_target
  if crafter.prototype.crafting_speed and crafter.get_recipe() and #crafter.get_recipe().products > 0 then
    local itemName = crafter.get_recipe().products[1].name
    local amount = getInserterAmount(player, itemName)
    local cb = inserter.get_or_create_control_behavior()
    local condition = {
      condition = {
        comparator = "<",
        first_signal = { type = "item", name = itemName },
        constant = amount,
      }
    }

    if getInsertersConnectToChest(player) then
      inserter.connect_neighbour({
        wire = defines.wire_type.green,
        target_entity = inserter.drop_target,
        source_circuit_id = defines.circuit_connector_id.inserter,
        target_circuit_id = defines.circuit_connector_id.container,
      })

      cb.circuit_mode_of_operation = defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable
      cb.circuit_condition = condition
      debug("setting circuit condition to " .. itemName .. " < " .. amount)
    else
      cb.connect_to_logistic_network = true
      cb.logistic_condition = condition
      debug("setting logistic condition to " .. itemName .. " < " .. amount)
    end
  end
end

function setBuffer(player, inserter)
  local chest  = inserter.drop_target
  if not isBuffer(chest) then return end
  if chest.request_slot_count > 0 and getBuffersSkipExisting(player) then return end

  local crafter = inserter.pickup_target
  if crafter.prototype.crafting_speed and crafter.get_recipe() and #crafter.get_recipe().products > 0 then
    local itemName = crafter.get_recipe().products[1].name
    local amount = getBufferAmount(player, itemName)

    for i = 1, chest.request_slot_count do
      chest.clear_request_slot(i)
    end
    chest.set_request_slot({ name = itemName, count = amount }, 1)
    debug("setting buffer slot to " .. itemName .. " = " .. amount)
  end
end

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= Config.TOOL_NAME then return end
  local player = game.players[event.player_index]

  local requesters = {}
  local inserters = {}
  table.each(player.surface.find_entities_filtered{type = "inserter", area = event.area}, function(v)
    if v.drop_target and v.pickup_target then
      if isRequester(v.pickup_target) then
        local id = v.pickup_target.unit_number
        requesters[id] = requesters[id] or { chest = v.pickup_target, targets = {} }
        table.insert(requesters[id].targets, v.drop_target)
      elseif v.drop_target.get_inventory(defines.inventory.chest) then
        table.insert(inserters, v)
      end
    end
  end)

  if getRequestersEnabled(player) then
    for _, data in pairs(requesters) do
      local chest = data.chest
      local requests = {}
      for _,drop in pairs(data.targets) do
        addIngredients(requests, drop)
        addLabCycle(requests, drop)
      end
      setRequester(player, chest, requests)
    end
  end
  if getInsertersEnabled(player) then
    for _, inserter in pairs(inserters) do
      setInserter(player, inserter)
    end
  end
  if getBuffersEnabled(player) then
    for _, inserter in pairs(inserters) do
      setBuffer(player, inserter)
    end
  end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.players[event.player_index]
  local item = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name
  if item == Config.TOOL_NAME then
    showGui(player)
  else
    hideGui(player)
  end
end)

script.on_event(defines.events.on_player_dropped_item, function(event)
  local player = game.players[event.player_index]
  if event.entity and event.entity.stack and event.entity.stack.name == Config.TOOL_NAME then
    event.entity.stack.clear()
    hideGui(player)
  end
end)