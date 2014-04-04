EQUIP = { "head", "chest", "legs", "back", "primary", "alt", "sheathedprimary", "headSoc", "chestSoc", "legsSoc", "backSoc" }

-- TODO: REWRITE THIS ENTIRELY

-- NEED THE FOLLOWING:
-- is_inventory_full()
-- check_drops()
-- deposit_all(itemname, targetContainer)
-- get_inventory_itemtype(itemtype)
-- get_inventory_item(itemname)
-- unequip(slot)
-- equip(slot, item)
-- drop_all_items()

-- Retrieves the current maximum inventory size
-- TODO: increase size with backpacks/carts/wheelbarrows
function max_inventory()
  return 20
end

-- Retrieves the number of distinct items in the inventory(does not count stacks)
function get_inventory_count()
  return #storage.inventory
end

-- Returns true if the inventory is full, otherwise returns false
function is_inventory_full()
  return get_inventory_count() >= max_inventory()
end

-- Adds an item to the inventory, regardless if it is full or not
-- does not stack items
function add_to_inventory(item)
  table.insert(storage.inventory, item)
end

-- Checks items within an arbitrary radius of the entity's current location.
-- If there is room in the entity's inventory, the item will be picked up and
-- placed in the inventory.
function check_drops()
  local pos = entity.position()
  local drops = world.itemDropQuery(pos, 5)
  for _,id in ipairs(drops) do
    if ( not is_inventory_full() ) then
      
      local item = world.takeItemDrop(id, entity.id())
      if ( item ~= nil ) then
        log("Got a " .. item.name)
        --DUMP.dumpTable(item)
        add_to_inventory(item)
      end
      
    end
  end
end

-- Finds an item of the given item type (ex: harvestingtool) and returns its item descriptor.
-- Returns nil if there were no items of that type available.
function get_inventory_itemtype(itemtype)
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
function get_inventory_item(itemname_regex)
  for _,item in ipairs(storage.inventory) do
    if ( string.find(item.name, itemname_regex) ) then
      return item
    end
  end
  return nil
end

function unequip(slot)
  local itemd = entity.getItemSlot(slot)
  if ( itemd ~= nil and string.len(itemd.name) > 0 and itemd.count > 0 ) then
    add_to_inventory(itemd)
    entity.setItemSlot(slot, nil)
  end
end

-- TODO : remove_from_inventory
-- TODO : Figure out which slot it uses by checking item type
function equip(item, slot)
  unequip(slot)
  entity.setItemSlot(slot, item)
end

function drop_all_items()
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


---- From http://snippets.luacode.org/snippets/Deep_Comparison_of_Two_Values_3
--function deepcompare(t1,t2)
--  local ty1 = type(t1)
--  local ty2 = type(t2)
--  if ty1 ~= ty2 then return false end
--
--  -- non-table types can be directly compared
--  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
--
--  for k1,v1 in pairs(t1) do
--    local v2 = t2[k1]
--    if v2 == nil or not deepcompare(v1,v2) then return false end
--  end
--  for k2,v2 in pairs(t2) do
--    local v1 = t1[k2]
--    if v1 == nil or not deepcompare(v1,v2) then return false end
--  end
--  return true
--end
