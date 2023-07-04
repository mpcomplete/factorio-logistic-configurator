local Position = require('__stdlib__/stdlib/area/position')
local Area = require('__stdlib__/stdlib/area/area')
local table = require('__stdlib__/stdlib/utils/table')
require('util')

function GUI(player)
  return player.gui.left.zyLCFrame
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
        items = { { "zy-LCFrame.stackSize" }, { "zy-LCFrame.craftSpeed" } },
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
        name = "label",
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
        items = { { "zy-LCFrame.stackSize" }, "1" },
        selected_index = 1,
      }
    end
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
        items = { { "zy-LCFrame.insertersConnectNetwork" }, { "zy-LCFrame.insertersConnectChest" } },
        selected_index = 2,
      }
    end
    do
      local limit = flow.add {
        type = "flow",
        name = "limitFlow",
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
        items = { { "zy-LCFrame.stackSize" }, "1" },
        selected_index = 1,
      }
    end
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