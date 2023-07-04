local table = require('__stdlib__/stdlib/utils/table')

Chest = Chest or {}

-- Adds ingredient/products from the entity's current recipe.
function addRecipeCycle(cycle, entity, isOutput)
  if entity.prototype.crafting_speed and entity.get_recipe() then
    local items = isOutput and entity.get_recipe().products or entity.get_recipe().ingredients
    for _, v in pairs(items) do
      if (v.type == "item") then table.insert(cycle, v.name) end
    end
  end
end

-- Adds science packs for a lab.
function addLabCycle(cycle, entity, isOutput)
  if entity.prototype.lab_inputs then
    for _, v in pairs(entity.prototype.lab_inputs) do
      table.insert(cycle, v)
    end
  end
end

-- Adds items from the input/output inventory of a container.
function addChestInventoryCycle(cycle, entity, isOutput)
   local inventory = entity.get_inventory(defines.inventory.chest)
   if not inventory then return end
   for k,v in pairs(inventory.get_contents()) do
     table.insert(cycle, k)
   end
end

-- Sets the chest filter based on a source entity's expected inputs/outputs.
function Chest.setItemFilterFromSource(dest, source, isOutput)
  if source == nil or dest == nil or not source.valid or not dest.valid then return end
  if dest.name ~= Config.CHEST_NAME then return end

  local itemCycle = {}
  if not isOutput then
    -- Burner fuel and labs are input-only
    addLabCycle(itemCycle, source, isOutput)
  end
  addRecipeCycle(itemCycle, source, isOutput)
  addChestInventoryCycle(itemCycle, source, isOutput)

  if #itemCycle == 0 then
    -- link_id might have changed (e.g. if we pasted from a chest), so update our local metadata from it.
    Chest.setItemFilter(dest, Chest.getNameFromId(dest.link_id))
    return
  end

  if global.lastPasteSource ~= source or global.lastPasteAlt ~= isOutput then
    global.lastPasteSource = source
    global.lastPasteAlt = isOutput
    global.lastPasteIdx = 1
  end

  local item = itemCycle[global.lastPasteIdx or 1]
  global.lastPasteIdx = global.lastPasteIdx + 1
  if global.lastPasteIdx > #itemCycle then
    global.lastPasteIdx = 1
  end

  Chest.setItemFilter(dest, item)
end

return Chest