Room = {}
Room.__index = Room

function Room.create(position)
  local o = {}
  setmetatable(o, Room)
  
  local pos = { position[1], position[2] }
  
  -- get room dimension
  local left = pos[1] - 200
  local top = pos[2] 
  local right = pos[1] + 200
  local bottom = pos[2]
  
  -- closest left door
  local doors = world.objectLineQuery(pos, {pos[1] - 200, pos[2]}, { callScript = "hasCapability", callScriptArgs = { "door" } })
  for _,id in ipairs(doors) do
    left = math.max(left, world.entityPosition()[1])
  end
  -- left wall
  local blocks = world.collisionBlocksAlongLine(pos, {pos[1] - 200, pos[2]}, true, 1)
  if ( blocks ~= nil and #blocks > 0 ) then
    left = math.max(left, blocks[1][1])
  end
  
  -- closest right door
  doors = world.objectLineQuery(pos, {pos[1] + 200, pos[2]}, { callScript = "hasCapability", callScriptArgs = { "door" } })
  for _,id in ipairs(doors) do
    right = math.min(right, world.entityPosition()[1])
  end
  -- right wall
  blocks = world.collisionBlocksAlongLine(pos, {pos[1] + 200, pos[2]}, true, 1)
  if ( blocks ~= nil and #blocks > 0 ) then
    right = math.min(right, blocks[1][1])
  end

  
  return o
end

