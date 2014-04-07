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
    local drops = world.itemDropQuery(entity.position(), 500, { inSightOf = entity.id(), notAnObject = true, order = "nearest" } )
    if ( drops ~= nil and #drops > 0 ) then
      push_state("scavenge")
      return true
    end

    -- TODO: Plant saplings


    -- find target tree
    if ( storage.job_target == nil or world.entityExists(storage.job_target) == false ) then
      --world.logInfo("Looking for target")
      storage.job_target = nil
      entity.endPrimaryFire()
      local nearby = world.entityQuery(entity.position(), 1000, { inSightOf = entity.id(), order = "nearest" })
      
      -- look for more trees if none are nearby
      if ( nearby == nil or #nearby == 0 ) then
        push_state("wander")
        return true
      end
      
      for i,v in ipairs(nearby) do
        if ( world.entityType(v) == "plant" and world.entityExists(v) ) then
          log("Found a " .. tostring(world.entityType(v)) )
          walk_to( world.entityPosition(v) )
          storage.job_target = v
          return true
        end
      end -- for
    else --if ( storage.is_chopping_tree == false ) then
      local targetPos = world.entityPosition(storage.job_target)
      if ( world.magnitude( world.distance(entity.position(), targetPos )) < 3 ) then
        --log("chopping target")
        entity.setFacingDirection( targetPos[1] - entity.position()[1] )
        entity.setAimPosition({targetPos[1], targetPos[2]+0.25})
        entity.beginPrimaryFire()
      else
        --entity.say("too far")
        --entity.jump()
        entity.endPrimaryFire()
        walk_to( world.entityPosition(storage.job_target) )
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
