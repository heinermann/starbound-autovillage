EQUIP = { "head", "chest", "legs", "back", "primary", "alt", "sheathedprimary", "headSoc", "chestSoc", "legsSoc", "backSoc" }

-- NOTE consider removing an item on retrieval (easier + correctness)

-- NEED THE FOLLOWING:
-- deposit_all(itemname, targetContainer)


-- Retrieves the current maximum inventory size
-- TODO: increase size with backpacks/carts/wheelbarrows
function inv_max()
  return 20
end

-- Retrieves the number of distinct items in the inventory(does not count stacks)
function inv_size()
  return #storage.inventory
end

-- Returns true if the inventory is full, otherwise returns false
function inv_is_full()
  return inv_size() >= inv_max()
end

-- Adds an item to the inventory, regardless if it is full or not
function inv_add_item(item)
  --for _,inv_item in ipairs(storage.inventory) do
  --  -- table_deepcompare(t1,t2)
  --  local stack = item.count
  --  if ( item_eq(item,inv_item) ) then
  --    -- If the stack exceeds the max item capacity
  --    if ( inv_item.count + item.count > 1000 ) then
  --      item.count = item.count - (1000 - inv_item.count)
  --      inv_item.count = 1000
  --    else -- stack the items
  --      inv_item.count = inv_item.count + item.count
  --      return -- short-circuit
  --    end
  --  end
  --end

  -- If no suitable item was found or there is some stack remaining
  table.insert(storage.inventory, item)
end


-- Checks items within an arbitrary radius of the entity's current location.
-- If there is room in the entity's inventory, the item will be picked up and
-- placed in the inventory.
function inv_check_drops()
  local pos = entity.position()
  local drops = world.itemDropQuery(pos, 5)
  for _,id in ipairs(drops) do
    if ( not inv_is_full() ) then
      
      local item = world.takeItemDrop(id, entity.id())
      if ( item ~= nil ) then
        log("Got a " .. item.name)
        --DUMP.dumpTable(item)
        inv_add_item(item)
      end
      
    end
  end
end

-- Finds an item of the given item type (ex: harvestingtool) and returns its item descriptor.
-- Returns nil if there were no items of that type available.
function inv_get_itemtype(itemtype)
  for _,item in ipairs(storage.inventory) do
    if ( world.itemType(item.name) == itemtype ) then
      -- TODO find the best item of all there is in the inventory
      return item
    end
  end
  return nil
end

-- Finds an arbitrary item whose name matches the given regular expression and returns its item descriptor.
-- Returns nil if there were no items found.
function inv_get_item(itemname_regex)
  for _,item in ipairs(storage.inventory) do
    if ( string.find(item.name, itemname_regex) ) then
      return item
    end
  end
  return nil
end

-- Deposits all items matching the item name regex into the given container entity id
-- TODO: NOT THIS
function inv_deposit_all(itemname_regex, container_id)
  local trash_list = {}
  for _,item in ipairs(storage.inventory) do
    if ( string.find(item.name, itemname_regex) ) then
      -- attempt deposit, add to trash_list if successful
    end
  end

  for _,item in ipairs(trash_list) do
    inv_remove_item(item)
  end
end

-- Unequips the item found in the given inventory slot.
function inv_unequip(slot)
  local itemd = entity.getItemSlot(slot)
  if ( itemd ~= nil and string.len(itemd.name) > 0 and itemd.count > 0 ) then
    inv_add_item(itemd)
    entity.setItemSlot(slot, nil)
  end
end

-- Removes the first item matching the given item descriptor from the inventory
function inv_remove_item(item)
  for i,inv_item in ipairs(storage.inventory) do
    if ( item_eq(item,inv_item) ) then
      table.remove(storage.inventory, i)
      return
    end
  end
end

-- TODO : remove_from_inventory
-- TODO : Figure out which slot it uses by checking item type
function inv_equip(item, slot)
  unequip(slot)
  inv_remove_item(item)
  entity.setItemSlot(slot, item)
end

function inv_drop_all()
  for i,slot in ipairs(EQUIP) do
    unequip(slot)
  end
  
  for _,item in ipairs(storage.inventory) do
    world.spawnItem(item.name, entity.position(), item.count, item.data)
  end
  storage.inventory = {}
end

-- containerSize()
-- containerItems()
-- containerItemAt(offset)
-- containerConsume(items)
-- containerConsumeAt(offset,count)
-- containerAvailable(items)
-- containerTakeAll()
-- containerTakeAt(offset)
-- containerTakeNumItemsAt(offset,amount)
-- containerItemsCanFit(items)
-- containerItemsFitWhere(items)
-- containerAddItems(items)
-- containerStackItems(items)
-- containerPutItemsAt(items,offset)
-- containerSwapItems(items,offset)
-- containerSwapItemsNoCombine(items,offset)
-- containerItemApply(items,offset)
function item_eq(item1, item2)
  return item.name == inv_item.name and table_deepcompare(item.data, inv_item.data)
end

-- From http://snippets.luacode.org/snippets/Deep_Comparison_of_Two_Values_3
function table_deepcompare(t1,t2)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end

  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end

  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deepcompare(v1,v2) then return false end
  end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not deepcompare(v1,v2) then return false end
  end
  return true
end
