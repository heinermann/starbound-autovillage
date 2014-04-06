
-- Map the world using more generic locations


function map_add(thing, position, description)
  local x = position[1] / 1000.0
  local y = position[2] / 1000.0
  local xy = tostring(x) .. "_" .. tostring(y)
 
  -- Map thing based on its x/y coordinate
  if ( storage.map == nil ) then storage.map = {} end
  if ( storage.map[y] == nil ) then storage.map[y] = {} end
  if ( storage.map[y][x] == nil ) then storage.map[y][x] = {} end
  
  storage.map[y][x][thing] = true
  
  -- Map xy coordinate based on thing
  if ( storage.mapThing == nil ) then storage.mapThing = {} end
  if ( storage.mapThing[thing] == nil ) then storage.mapThing[thing] = {} end
  
  storage.mapThing[thing][xy] = description or true
end