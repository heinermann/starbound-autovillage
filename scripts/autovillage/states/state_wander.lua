function get_wander_pos()
  local p = entity.position()
  local wander_pos = { p[1] + math.random(-32,32), 
                       p[2] + 6 }
  
  -- find the surface (hit the ground from the sky)
  while ( not world.rectCollision({ wander_pos[1], wander_pos[2], wander_pos[1]+1, wander_pos[2]+2 }) ) do
    wander_pos[2] = wander_pos[2] - 1
  end
  
  -- find the surface (from the underground)
  while ( world.rectCollision({ wander_pos[1], wander_pos[2], wander_pos[1]+1, wander_pos[2]+2 }) ) do
    wander_pos[2] = wander_pos[2] + 1
  end
  
  wander_pos[2] = wander_pos[2] + 1.5
  return wander_pos
end

STATE["wander"] = {
  enter = function(ctx)
    ctx.wander_time = world.time() - 30
    ctx.wandered = false
    return true
  end,

  update = function(ctx)
    if ( ctx.wander_time + 5 < world.time() ) then
      ctx.wander_time = world.time()
      if ( not ctx.wandered ) then
        walk_to( get_wander_pos() )
        ctx.wandered = true
      else
        return false
      end
    end
    
    return true
  end,

  leave = function(ctx)
  end
}
