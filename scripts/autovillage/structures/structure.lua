Structure = {}
Structure.__index = Structure

function Structure.create(position)
  local o = {}
  setmetatable(o, Structure)
  
  
  o.rooms = {}

  return o
end

