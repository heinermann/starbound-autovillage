STATE["scavenge"] = {
  enter = function(ctx)
    return true
  end,

  update = function(ctx)
    -- If there are nearby items, go and pick them up
    local drops = world.itemDropQuery(entity.position(), 500, { inSightOf = entity.id(), order = "nearest" } )
    
    -- otherwise wander a little and go back to whatever it was doing previously
    if ( drops == nil or #drops == 0 ) then
      push_state("wander")
      return false
    end
    
    walk_to( world.entityPosition(drops[1]) )
    return true
  end,

  leave = function(ctx)
  end
}
