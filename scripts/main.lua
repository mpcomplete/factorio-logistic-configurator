local Position = require('__stdlib__/stdlib/area/position')
local Area = require('__stdlib__/stdlib/area/area')
local table = require('__stdlib__/stdlib/utils/table')
local math = require('__stdlib__/stdlib/utils/math')

require('util')

function GUI(player)
  return player.gui.left.zyLCFrame
end

function getRequestersEnabled(player) return GUI(player).requestersCB.state end
function getRequestersSetMultiple(player) return GUI(player).requesters.set.multiple.text end
-- 1=stackSize, 2=amountPerSec, 3="one"
function getRequestersSetMultiplyBy(player) return GUI(player).requesters.set.multiplyBy.selected_index end
function getRequestersRound(player) return GUI(player).requesters.round.enabledCB.state end
-- 1=stackSize, 2="one"
function getRequestersRoundTimes(player) return GUI(player).requesters.round.multiple.text end
function getRequestersRoundTo(player) return GUI(player).requesters.round.multiplyBy.selected_index end
function getRequestersSkipExisting(player) return GUI(player).requesters.skipCB.state end
function getInsertersEnabled(player) return GUI(player).insertersCB.state end
function getInsertersConnectToChest(player) return GUI(player).inserters.connect.connectTo.selected_index == 1 end -- else network
function getInsertersLimitMultiple(player) return GUI(player).inserters.limit.multiple.text end
-- 1=stackSize, 2="one"
function getInsertersLimitMultiplyBy(player) return GUI(player).inserters.limit.multiplyBy.selected_index end
function getInsertersSkipExisting(player) return GUI(player).inserters.skipCB.state end

function getRequesterAmount(player, itemName, amountConsumed)
  local stackSize = game.item_prototypes[itemName].stack_size
  local multiplyBy = getRequestersSetMultiplyBy(player)
  local baseAmount =
     multiplyBy == 1 and stackSize
     or multiplyBy == 2 and amountConsumed
     or 1
  local amount = baseAmount * getRequestersSetMultiple(player)
  if getRequestersRound(player) then
    local roundTo = getRequestersRoundTo(player)
    local roundToAmount =
      roundTo == 1 and stackSize
      or 1
    roundToAmount = roundToAmount * getRequestersRoundTimes(player)
    amount = math.round(amount / roundToAmount) * roundToAmount
    if amount == 0 then amount = roundToAmount end
  end
  return amount
end

function getInserterAmount(player, itemName)
  local stackSize = game.item_prototypes[itemName].stack_size
  local multiplyBy = getInsertersLimitMultiplyBy(player)
  local baseAmount =
     multiplyBy == 1 and stackSize
     or 1
  return baseAmount * getInsertersLimitMultiple(player)
end

function buildGui(player)
  player.gui.left.add {
    type = "frame",
    name = "zyLCFrame",
    direction = "vertical",
    caption = { "zy-LCFrame.heading" },
    visible = false,
  }
  GUI(player).add {
    type = "checkbox",
    name = "requestersCB",
    caption = { "zy-LCFrame.requesters" },
    -- style = "slot_button",
    state = true,
  }
  do
    local flow = GUI(player).add {
      type = "frame",
      name = "requesters",
      direction = "vertical",
      style = "subpanel_frame",
    }
    do
      local set = flow.add {
        type = "flow",
        name = "set",
        direction = "horizontal",
      }
      set.add {
        type = "label",
        name = "label",
        caption = { "zy-LCFrame.requestersSet" },
      }
      set.add {
        type = "textfield",
        name = "multiple",
        numeric = true,
        allow_decimal = true,
        text = "1",
        style = "zy-LCFrame-multiple",
      }
      set.add {
        type = "drop-down",
        name = "multiplyBy",
        items = { { "zy-LCFrame.stackSize" }, { "zy-LCFrame.craftSpeed" },  { "zy-LCFrame.timesOne" } },
        selected_index = 1,
      }
    end
    do
      local round = flow.add {
        type = "flow",
        name = "round",
        direction = "horizontal",
      }
      round.add {
        type = "checkbox",
        name = "enabledCB",
        caption = { "zy-LCFrame.requestersRound" },
        state = true,
      }
      round.add {
        type = "textfield",
        name = "multiple",
        numeric = true,
        allow_decimal = true,
        text = "1",
        style = "zy-LCFrame-multiple",
      }
      round.add {
        type = "drop-down",
        name = "multiplyBy",
        items = { { "zy-LCFrame.stackSize" }, { "zy-LCFrame.timesOne" } },
        selected_index = 1,
      }
    end
    flow.add {
      type = "checkbox",
      name = "skipCB",
      caption = { "zy-LCFrame.requestersSkip" },
      state = false,
    }
  end

  GUI(player).add {
    type = "checkbox",
    name = "insertersCB",
    caption = { "zy-LCFrame.inserters" },
    -- style = "slot_button",
    state = true,
  }
  do
    local flow = GUI(player).add {
      type = "frame",
      name = "inserters",
      direction = "vertical",
      style = "subpanel_frame",
    }
    do
      local connect = flow.add {
        type = "flow",
        name = "connect",
        direction = "horizontal",
      }
      connect.add {
        type = "label",
        name = "label",
        caption = { "zy-LCFrame.insertersConnect" },
      }
      connect.add {
        type = "drop-down",
        name = "connectTo",
        items = { { "zy-LCFrame.insertersConnectChest" }, { "zy-LCFrame.insertersConnectNetwork" } },
        selected_index = 1,
      }
    end
    do
      local limit = flow.add {
        type = "flow",
        name = "limit",
        direction = "horizontal",
      }
      limit.add {
        type = "label",
        name = "label",
        caption = { "zy-LCFrame.insertersLimit" },
      }
      limit.add {
        type = "textfield",
        name = "multiple",
        numeric = true,
        allow_decimal = true,
        text = "1",
        style = "zy-LCFrame-multiple",
      }
      limit.add {
        type = "drop-down",
        name = "multiplyBy",
        items = { { "zy-LCFrame.stackSize" }, { "zy-LCFrame.timesOne" } },
        selected_index = 1,
      }
    end
    flow.add {
      type = "checkbox",
      name = "skipCB",
      caption = { "zy-LCFrame.insertersSkip" },
      state = false,
    }
  end
end

function destroyGui(player)
  if GUI(player) ~= nil then GUI(player).destroy() end
end

function showGui(player)
  destroyGui(player) -- TODO
  if GUI(player) == nil then buildGui(player) end
  GUI(player).visible = true
end

function hideGui(player)
  if GUI(player) ~= nil then GUI(player).visible = false end
end

function initGui(player)
  destroyGui(player)
  buildGui(player)
end

-- function openGui(player, entity)
--   local guiEntity = entity
--   local guiFilter = Chest.getNameFromId(guiEntity.link_id)
--   player.gui.screen.unichestFrame.itemFilter.elem_value = guiFilter
--   Chest.setItemFilter(guiEntity, guiFilter)

--   script.on_event(defines.events.on_gui_elem_changed, function(event)
--     if not guiEntity.valid then return end
--     local element = event.element
--     if element ~= player.gui.relative.unichestFrame.itemFilter then return end
--     if element.elem_value and element.elem_value ~= "" then
--       -- Don't let them set an empty filter.
--       guiFilter = element.elem_value
--     end
--   end)

--   script.on_event(defines.events.on_gui_closed, function(event)
--     script.on_event(defines.events.on_tick, nil)
--     script.on_event(defines.events.on_gui_elem_changed, nil)
--   end)
-- end

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.entity then return end
  -- if event.entity.name == Config.CHEST_NAME then openGui(player, event.entity) end
end)

script.on_init(function(event)
  for i, player in pairs(game.players) do
    initGui(player)
  end
end)

script.on_configuration_changed(function(event)
  for i, player in pairs(game.players) do
    initGui(player)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  initGui(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  initGui(game.get_player(event.player_index))
end)