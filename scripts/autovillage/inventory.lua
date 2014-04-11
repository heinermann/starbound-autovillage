EQUIP = { "head", "chest", "legs", "back", "primary", "alt", "sheathedprimary", "headSoc", "chestSoc", "legsSoc", "backSoc" }

-- NOTE consider removing an item on retrieval (easier + correctness)

-- NEED THE FOLLOWING:
-- deposit_all(itemname, targetContainer)

-------------------------------------------------------------------------------------------------

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

-- Adds a list of items to the inventory. It returns the remainder of the items
-- that were not able to fit in the bag.
function inv_add_items(items)
  local result_items = {}
  for _,itm in ipairs(items) do
    local result = inv_add_item(itm)
    if ( result ~= nil ) then
      table.insert(result_items, result)
    end
  end
  return result_items
end

-- Adds a single item to the inventory, stacking with like-items (up to 1000), 
-- and then adding the remainder of the item if it isn't found into a new slot.
-- If there is not enough space in the inventory, the remaining stack of the item
-- is returned. If successful, then nil is returned.
-- Guaranteed to make a copy of the item argument.
function inv_add_item(item_)
  local item = deepcopy(item_)

  for _,inv_item in ipairs(storage.inventory) do

    local stack = item.count
    if ( item_eq(item, inv_item) ) then
      -- If the stack exceeds the max item capacity
      if ( inv_item.count + item.count > 1000 ) then
        item.count = item.count - (1000 - inv_item.count)
        inv_item.count = 1000
      else -- stack the items
        log("Stacked " .. item.name)
        inv_item.count = inv_item.count + item.count
        return nil -- short-circuit
      end
    end

  end

  -- If no suitable item was found or there is some stack remaining
  if ( not inv_is_full() ) then
    log("Added " .. item.name .. " to inventory")
    table.insert(storage.inventory, item)
    log("Size " .. inv_size())
    return nil
  else
    return item
  end
end


-- Checks items within an arbitrary radius of the entity's current location.
-- If there is room in the entity's inventory, the item will be picked up and
-- placed in the inventory.
-- TODO: Don't pick up items if inv. is full.
function inv_check_drops()
  local pos = entity.position()
  local drops = world.itemDropQuery(pos, 5)
  for _,id in ipairs(drops) do
    if ( not inv_is_full() ) then
      
      local item = world.takeItemDrop(id, entity.id())
      if ( item ~= nil ) then
        log("Got a " .. item.name)
        --DUMP.dumpTable(item)

        local result = inv_add_item(item)
        if ( result ~= nil ) then
          log("Inventory full. NOTE: Should not have picked this up.")
          item_toss(result)
        end
      end
      
    end
  end
end

-- Finds an item of the given item type (ex: harvestingtool) and returns its item descriptor.
-- The item is REMOVED from the inventory when it is found. To just check if an itemtype exists,
-- see inv_has_itemtype.
-- Returns nil if there were no items of that type available.
function inv_get_itemtype(itemtype)
  for i,item in ipairs(storage.inventory) do
    if ( world.itemType(item.name) == itemtype ) then
      -- TODO find the best item of all there is in the inventory
      table.remove(storage.inventory, i)
      log("Found item " .. item.name .. " of type " .. itemtype)
      return item
    end
  end
  log("Unable to find itemtype " .. itemtype)
  return nil
end

function inv_has_itemtype(itemtype)
  for i,item in ipairs(storage.inventory) do
    if ( world.itemType(item.name) == itemtype ) then
      return true
    end
  end
  return false
end

-- Finds an arbitrary item whose name matches the given regular expression and returns its item descriptor.
-- Returns nil if there were no items found.
function inv_get_item(itemname_regex)
  for i,item in ipairs(storage.inventory) do
    if ( string.find(item.name, itemname_regex) ) then
      table.remove(storage.inventory, i)
      return item
    end
  end
  return nil
end

function inv_get_items(itemname_regex, count)
  if ( count == nil ) then count = 999999999 end

  local found_items = {}
  local i = 1
  while ( i <= #storage.inventory and count > 0 ) do
    local item = storage.inventory[i]
    if ( string.find(item.name, itemname_regex) ) then

      -- if we didn;t take the whole stack
      if ( count < item.count ) then
        local item_cpy = deepcopy(item)

        item.count = item.count - count
        item_cpy.count = count

        table.insert(found_items, item_cpy)

        count = 0
        i = i + 1
      else -- if we DID take the whole stack
        table.insert(found_items, item)
        count = count - item.count
        table.remove(storage.inventory, i) -- remove emptied stack from inventory
      end
    else -- we didn't find the item we're looking for
      i = i + 1
    end
  end

  return found_items
end

-- Deposits all items matching the item name regex into the given container entity id
-- TODO: NOT THIS
function inv_deposit_all(itemname_regex, container_id, count)
  if ( count == nil ) then count = 999999999 end

  local found_items = inv_get_items(itemname_regex, count)

  local results = world.containerAddItems(container_id, found_items)
  results = inv_add_items(results)
  if ( #results > 0 ) then
    log("Unexpected " + #results + " items remaining from failed deposit (should have re-added to inventory).")
  end
end

-- Unequips the item found in the given inventory slot.
function inv_unequip(slot)
  local itemd = entity.getItemSlot(slot)
  if ( itemd ~= nil and itemd.name ~= "" ) then
    local result = inv_add_item(itemd)
    if ( result == nil ) then
      log("Unequipped " .. itemd.name)
      entity.setItemSlot(slot, nil)
    else
      log("Couldn't unequip, no room!")
    end
  end
end

-- TODO : Figure out which slot it uses by checking item type? (reduced arguments, generic)
function inv_equip(item, slot)
  if ( item == nil ) then return end
  inv_unequip(slot)
  log("Equipped " .. item.name)
  entity.setItemSlot(slot, item)
end

-- TODO : Figure out which slot it uses by checking item type? (reduced arguments, generic)
function inv_equip_itemtype(itemtype, slot)
  local item = inv_get_itemtype(itemtype)
  if ( item == nil ) then return end
  inv_equip(item, slot)
end

-- Drops all of the given items while emptying the given array-based table
function inv_drop_items(items)
  while ( #items > 0 ) do
    local item = items[#items]
    table.remove(items)
    item_toss(item)
  end
end

-- Drops the entire inventory and equipped items
function inv_drop_all()
  for i,slot in ipairs(EQUIP) do
    inv_unequip(slot)
  end

  log("Drop size: " .. inv_size())
  
  inv_drop_items(storage.inventory)
end

---------------------------------------------------------------------------------------------------------
-- Compares two items with each other and returns true if they item descriptors are equal, and false otherwise.
-- Ignores the stack/count.
function item_eq(item1, item2)
  return item1.name == item2.name and deepcompare(item1.data, item2.data)
end

-- Throws an item on to the ground
-- TODO: Reset pickup counter?
function item_toss(item)
  log("Spawned a " .. item.name)
  world.spawnItem(item.name, entity.position(), item.count, item.data)
end

-- From http://snippets.luacode.org/snippets/Deep_Comparison_of_Two_Values_3
function deepcompare(t1,t2)
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

-- from http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        --setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
