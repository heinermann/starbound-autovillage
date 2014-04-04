STATE["walk"] = {
  enter = function(ctx)
    entity.setRunning(false)
    if ( not ctx.destination ) then
      return false
    end
    
    return true
  end,

  update = function(ctx)
    local target = ctx.destination
    local current = entity.position()
    local remaining = world.magnitude( world.distance(current, target) );
    
    -- if we have reached the target
    if ( remaining < 3 ) then
      return false
    end
    
    moveTo(target)
    return true
  end,

  leave = function(ctx)
  end
}
