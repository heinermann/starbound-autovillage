STATE["idle"] = {
  enter = function(ctx)
    return true
  end,

  update = function(ctx)
    if ( storage.job ~= nil ) then
      push_state("job")
    else
      push_state("wander")
    end
    return true
  end,

  leave = function(ctx)
  end
}
