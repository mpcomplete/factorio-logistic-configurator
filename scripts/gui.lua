local math = require('__kry_stdlib__/stdlib/utils/math')

require('util')

function GUI(player)
  return player.gui.left.zyLCFrame
end
function PData(player)
  global = global or {}
  global.players = global.players or {}
  global.players[player.name] = global.players[player.name] or {}
  return global.players[player.name]
end

function getRequestersEnabled(player) return GUI(player).requestersCB.state end
function getRequestersSetMultiple(player) return GUI(player).requesters.set.multiple.text end
-- 1="one", 2=stackSize, 3=amountPerSec
function getRequestersSetMultiplyBy(player) return GUI(player).requesters.set.multiplyBy.selected_index end
function getRequestersRound(player) return GUI(player).requesters.round.enabledCB.state end
-- 1="one", 2=stackSize
function getRequestersRoundTimes(player) return GUI(player).requesters.round.multiple.text end
function getRequestersRoundTo(player) return GUI(player).requesters.round.multiplyBy.selected_index end
function getRequestersFromBuffers(player) return GUI(player).requesters.buffersCB.state end
function getRequestersSkipExisting(player) return GUI(player).requesters.skipCB.state end
function getInsertersEnabled(player) return GUI(player).insertersCB.state end
function getInsertersConnectToChest(player) return GUI(player).inserters.connect.connectTo.selected_index == 1 end -- else network
function getInsertersLimitMultiple(player) return GUI(player).inserters.limit.multiple.text end
-- 1="one", 2=stackSize
function getInsertersLimitMultiplyBy(player) return GUI(player).inserters.limit.multiplyBy.selected_index end
function getInsertersSkipExisting(player) return GUI(player).inserters.skipCB.state end
function getBuffersEnabled(player) return GUI(player).buffersCB end
function getBuffersSetMultiple(player) return GUI(player).buffers.set.multiple.text end
-- 1="one", 2=stackSize
function getBuffersSetMultiplyBy(player) return GUI(player).buffers.set.multiplyBy.selected_index end
function getBuffersSkipExisting(player) return GUI(player).buffers.skipCB.state end

function getRequesterAmount(player, itemName, amountConsumed)
  local stackSize = prototypes.item[itemName].stack_size
  local multiplyBy = getRequestersSetMultiplyBy(player)
  local baseAmount =
     multiplyBy == 1 and 1
     or multiplyBy == 2 and stackSize
     or amountConsumed
  local amount = baseAmount * getRequestersSetMultiple(player)
  if getRequestersRound(player) then
    local roundTo = getRequestersRoundTo(player)
    local roundToAmount = roundTo == 1 and 1 or stackSize
    roundToAmount = roundToAmount * getRequestersRoundTimes(player)
    amount = math.round(amount / roundToAmount) * roundToAmount
    if amount == 0 then amount = roundToAmount end
  end
  return amount
end

function getInserterAmount(player, itemName)
  local stackSize = prototypes.item[itemName].stack_size
  local multiplyBy = getInsertersLimitMultiplyBy(player)
  local baseAmount = multiplyBy == 1 and 1 or stackSize
  return baseAmount * getInsertersLimitMultiple(player)
end

function getBufferAmount(player, itemName)
  local stackSize = prototypes.item[itemName].stack_size
  local multiplyBy = getBuffersSetMultiplyBy(player)
  local baseAmount = multiplyBy == 1 and 1 or stackSize
  return baseAmount * getBuffersSetMultiple(player)
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
      style = "shallow_frame",
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
        text = "4",
        style = "zy-LCFrame-multiple",
      }
      set.add {
        type = "drop-down",
        name = "multiplyBy",
        items = { { "zy-LCFrame.timesOne" }, { "zy-LCFrame.stackSize" }, { "zy-LCFrame.consumedPerSec" }  },
        selected_index = 3,
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
        state = false,
      }
      round.add {
        type = "textfield",
        name = "multiple",
        numeric = true,
        allow_decimal = true,
        text = "10",
        style = "zy-LCFrame-multiple",
      }
      round.add {
        type = "drop-down",
        name = "multiplyBy",
        items = { { "zy-LCFrame.timesOne" }, { "zy-LCFrame.stackSize" } },
        selected_index = 1,
      }
    end
    flow.add {
      type = "checkbox",
      name = "buffersCB",
      caption = { "zy-LCFrame.requestersFromBuffers" },
      state = false,
    }
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
      style = "shallow_frame",
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
        items = { { "zy-LCFrame.timesOne" }, { "zy-LCFrame.stackSize" } },
        selected_index = 2,
      }
    end
    flow.add {
      type = "checkbox",
      name = "skipCB",
      caption = { "zy-LCFrame.insertersSkip" },
      state = false,
    }
  end

  GUI(player).add {
    type = "checkbox",
    name = "buffersCB",
    caption = { "zy-LCFrame.buffers" },
    state = true,
  }
  
  do
    local flow = GUI(player).add {
      type = "frame",
      name = "buffers",
      direction = "vertical",
      style = "shallow_frame",
    }
    do
      flow.add {
        type = "label",
        name = "label",
        caption = { "zy-LCFrame.buffersLabel" },
        style = "zy-LCFrame-note",
      }.style.horizontally_stretchable = true

      local set = flow.add {
        type = "flow",
        name = "set",
        direction = "horizontal",
      }
      set.add {
        type = "label",
        name = "label",
        caption = { "zy-LCFrame.buffersSet" },
      }
      set.add {
        type = "textfield",
        name = "multiple",
        numeric = true,
        allow_decimal = true,
        text = "2",
        style = "zy-LCFrame-multiple",
      }
      set.add {
        type = "drop-down",
        name = "multiplyBy",
        items = { { "zy-LCFrame.timesOne" }, { "zy-LCFrame.stackSize" } },
        selected_index = 2,
      }
    end
    flow.add {
      type = "checkbox",
      name = "skipCB",
      caption = { "zy-LCFrame.buffersSkip" },
      state = false,
    }
  end
end

function destroyGui(player)
  if GUI(player) ~= nil then GUI(player).destroy() end
end

function showGui(player)
  if PData(player).guiVersion ~= 1 then destroyGui(player) end
  PData(player).guiVersion = 1
  if GUI(player) == nil then buildGui(player) end
  GUI(player).visible = true
end

function hideGui(player)
  if GUI(player) ~= nil then GUI(player).visible = false end
end