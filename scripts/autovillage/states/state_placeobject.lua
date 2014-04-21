function place_object(object)
  return push_state("placeobject", { ["object"] = object })
end

function is_sapling_placable(x, y)
  for ix = -1,3 do
    if world.material({x+ix, y-1}, "foreground") ~= "dirt" then
      return false
    end

    for iy = 0,8 do
      if world.tileIsOccupied({x+ix, y+iy}) then
        return false
      end
    end
  end
  return true
end

function find_placable(object)
  local lim = 100
  local dx = 0
  local dy = -1
  local x = 0
  local y = 0
  local entity_pos = entity.position()

  for i = 0, lim*lim do
    if -lim < x and x <= lim and -lim < y and y <= lim then
      if is_sapling_placable(entity_pos[1]+x, entity_pos[2]+y) then
        return {entity_pos[1]+x, entity_pos[2]+y}
      end
    end

    if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y) then
      dx, dy = -dy, dx
    end
    x = x + dx
    y = y + dy
  end
  return nil
end

STATE["placeobject"] = {
  enter = function(ctx)
    if not ctx.object then
      return false
    end

    ctx.target = find_placable(ctx.object)
    if not ctx.target then
      return false
    end

    inv_equip(ctx.object, "primary")
    return true
  end,

  update = function(ctx)
    if world.magnitude( world.distance(entity.position(), ctx.target)) < 10 then
      entity.setFacingDirection( ctx.target[1] - entity.position()[1] )
      entity.setAimPosition( ctx.target )

      world.placeObject(ctx.object.name, ctx.target, entity.facingDirection(), ctx.object.data)
      inv_unequip_destroy("primary")
      --entity.beginPrimaryFire()
      -- TODO: Place object
      return false
    else
      walk_to( ctx.target )
    end

    return true
  end,

  leave = function(ctx)
    --entity.endPrimaryFire()
    inv_unequip("primary")
  end
}