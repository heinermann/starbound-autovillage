STATE["scavenge"] = {
  enter = function(ctx)
    talk( "found something shiny on the ground",
          "gonna get rich",
          "I'll pick that up for you")
    return true
  end,

  update = function(ctx)
    -- If there are nearby items, go and pick them up
    local drops_all = world.itemDropQuery(entity.position(), 100, { inSightOf = entity.id(), notAnObject = true, order = "nearest" } )
    local drops = {}
    if ( drops_all ~= nil ) then
      for _,item in ipairs(drops_all) do
        if ( world.lightLevel(world.entityPosition(item)) > 0.01 ) then
          table.insert(drops,item)
        end
      end
    end
    
    -- otherwise wander a little and go back to whatever it was doing previously
    if ( #drops == 0 ) then
      push_state("wander")
      return false
    end
    
    return walk_to( world.entityPosition(drops[1]) )
  end,

  leave = function(ctx)
  end
}
