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
    local remaining = math.abs(world.magnitude( world.distance(current, target) ))
    
    -- if we have reached the target
    if ( remaining < 3 ) then
      return false
    end
    
    return moveTo(target)
  end,

  leave = function(ctx)
  end
}
