JOB["lumberjack"] = {
  tooltype = "harvestingtool",
  goals = { "rainbowwood", "baseboard", "darkwood", "fullwood1", "fullwood2", "medievalladder", "ornatewood", "platform", "platform2", "woodenplatform", "woodenwindow1", "woodenwindow2", "woodenpanelling" },
  
  assign = function()
    talk("I've become a lumberjack", "just got my degree in woodcutting")
    return true
  end,
  
  enter = function()
    talk("time to <chop> some trees", "I'll go find some wood to <chop>")
    inv_equip_itemtype("harvestingtool", "primary")
    
    return true
  end,
  
  update = function()
  
    -- Inventory is full. Return items to home.
    if ( inv_is_full() ) then
      -- return items to base state
      push_state("haul")
      return true
    end
    
    -- Something dropped nearby. Go pick it up.
    local drops_all = world.itemDropQuery(entity.position(), 100, { inSightOf = entity.id(), notAnObject = true, order = "nearest" } )
    if ( drops_all ~= nil ) then
      local drops = {}
      for _,item in ipairs(drops_all) do
        if ( world.lightLevel(world.entityPosition(item)) > 0.01 ) then
          table.insert(drops,item)
        end
      end
      if ( #drops > 0 ) then
        push_state("scavenge")
        return true
      end
    end

    -- TODO: Plant saplings


    -- find target tree
    if ( storage.job_target == nil or world.entityExists(storage.job_target) == false ) then
      --world.logInfo("Looking for target")
      storage.job_target = nil
      entity.endPrimaryFire()
      local nearby = world.entityQuery(entity.position(), 500, { inSightOf = entity.id(), order = "nearest" })
      
      -- Check if the plant is similar to a tree
      for i,v in ipairs(nearby) do
        if get_entity_type(v) == "tree" then
          log("Found a tree (" .. tostring(world.entityName(v)) .. ")" )
          walk_to( world.entityPosition(v) )
          storage.job_target = v
          debugv = "tree found"
          return true
        end
      end

      -- look for more trees if none are nearby
      talk("I'll just wander around a bit first.")
      push_state("wander")
      return true

    else --if ( storage.is_chopping_tree == false ) then
      local targetPos = world.entityPosition(storage.job_target)
      if ( world.magnitude( world.distance(entity.position(), targetPos )) < 4 ) then
        --log("chopping target")
        entity.setFacingDirection( targetPos[1] - entity.position()[1] )
        entity.setAimPosition(vec2.add(targetPos,{0,0.1}))
        entity.beginPrimaryFire()
        debugv = "trying to hit"
      else
        --entity.say("too far")
        --entity.jump()
        entity.endPrimaryFire()
        walk_to( targetPos )
        debugv = "out of range, " .. world.magnitude( world.distance(entity.position(), targetPos))
        return true
        --walk_to( targetPos )
        --storage.job_target = nil
      end
    end
    
    -- TODO: stop working at night
    return storage.job_target ~= nil and world.entityExists(storage.job_target)
  end,
  
  leave = function()
    talk("I think I'll give it a rest", "I've <done> <?working> for today", "I've <done> my <?daily> duties <?today>", "I'v <done> my job for today")
    inv_unequip("primary")
  end,
  
  promote = function()
    talk("just got promoted and now I can cut more wood")
  end
}

function get_entity_type(entityId)
  local entityType = world.entityType(entityId)
  local entityPos = world.entityPosition(entityId)

  -- if it's not a plant
  if entityType ~= "plant" then return entityType end

  -- plant is somehow burried
  if world.pointCollision(entityPos) then
    return "plant"
  end

  -- if it's not rooted
  if not world.pointCollision(vec2.sub(entityPos, {0,1})) then return "vine" end

  -- check approx. 5 tiles above the root, if the plant ends then it's not a tree
  for i = 1,3 do
    local testPos = vec2.add(entityPos, {0,i})
    if world.pointCollision(testPos) or not world.tileIsOccupied(testPos) then
      return "plant"
    end
  end

  -- otherwise it is a tree! (yay logic!)
  return "tree"
end
