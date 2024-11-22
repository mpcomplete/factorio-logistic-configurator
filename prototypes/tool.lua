local icon = "__base__/graphics/icons/requester-chest.png"

data:extend({
  {
    type = "selection-tool",
    name = Config.TOOL_NAME,
    icon = icon,
    flags = { "only-in-cursor", "not-stackable", "spawnable" },
    subgroup = "tool",
    order = "c[automated-construction]-b[deconstruction-planner]",
    stack_size = 1,
    icon_size = 64,
    stackable = false,
    select = {
      border_color = { r = 0, g = 1, b = 0 },
      cursor_box_type = "pair",
      mode = { "nothing" },
    },
    alt_select = {
      border_color = { r = 0, g = 1, b = 0 },
      cursor_box_type = "pair",
      mode = { "nothing" },
    },
    show_in_library = true
  },
  {
    type = "shortcut",
    name = Config.TOOL_NAME,
    order = "o[" .. Config.TOOL_NAME .. "]",
    action = "spawn-item",
    item_to_spawn = Config.TOOL_NAME,
    toggleable = true,
    icon = icon,
    icon_size = 64,
    small_icon = icon,
    small_icon_size = 64,
    -- icon = {
    --   filename = icon,
    --   -- priority = "extra-high-no-scale",
    --   size = 64,
    --   scale = 0.5,
    --   flags = { "gui-icon" }
    -- }
  }
})
