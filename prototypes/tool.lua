local icon = "__base__/graphics/icons/logistic-chest-requester.png"

data:extend({
  {
    type = "selection-tool",
    name = Config.TOOL_NAME,
    icon = icon,
    flags = { "hidden", "only-in-cursor", "not-stackable", "spawnable" },
    subgroup = "tool",
    order = "c[automated-construction]-b[deconstruction-planner]",
    stack_size = 1,
    icon_size = 64,
    stackable = false,
    selection_color = { r = 0, g = 1, b = 0 },
    alt_selection_color = { r = 0, g = 1, b = 0 },
    selection_mode = { "nothing" },
    alt_selection_mode = { "nothing" },
    selection_cursor_box_type = "pair",
    alt_selection_cursor_box_type = "pair",
    show_in_library = true
  },
  {
    type = "shortcut",
    name = Config.TOOL_NAME,
    order = "o[" .. Config.TOOL_NAME .. "]",
    action = "spawn-item",
    item_to_spawn = Config.TOOL_NAME,
    toggleable = true,
    icon = {
      filename = icon,
      -- priority = "extra-high-no-scale",
      size = 64,
      scale = 0.5,
      flags = { "gui-icon" }
    }
  }
})
