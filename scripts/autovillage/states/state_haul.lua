STATE["haul"] = {
  enter = function(ctx)
    -- get all nearest containers
    objs = world.objectQuery(entity.position(), 1000, { order = "nearest", 
                                                        callScript = "entity.configParameter",
                                                        callScriptArgs = { "objectType" },
                                                        callScriptResult = "container"} )
    if ( objs == nil ) then return false end
    
    -- Remove containers that are full
    while ( #objs > 0 and not world.containerAvailable(objs[1], { name = "fullwood1", count = 1 }) ) do
      table.remove(objs, 1)
    end
    if ( #objs == 0 ) then return false end
  
    ctx.target_bin = objs[1]
    talk("time to take the <loot> home", "bringing home <?all> the <loot>", "taking the <loot> back <?home>")
    return true
  end,

  update = function(ctx)
    local bin = ctx.target_bin
    
    -- if the target crate is gone
    if ( bin == nil or not world.entityExists(bin) ) then
      return false
    end
    
    local bin_position = world.entityPosition(bin)
    
    -- if we reach the target crate
    if ( world.magnitude( world.distance(entity.position(), bin_position )) < 3 ) then
      deposit_all("metallic", bin)
      deposit_all("rainbowwood", bin)
      deposit_all("fullwood1", bin)
      deposit_all("fullwood2", bin)
      deposit_all("plantfibre", bin)
      deposit_all("shroom", bin)
      deposit_all("rawtentacle", bin)
      return false
    else
      walk_to( bin_position )
    end
    
    return true
  end,

  leave = function(ctx)
  end
}
