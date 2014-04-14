STATE = {}

function push_state(name, ctx)
  if ( STATE[name] == nil ) then return end
  if ( storage.state == nil ) then storage.state = {} end
  if ( ctx == nil ) then ctx = {} end

  -- enter callback
  if ( STATE[name] ~= nil ) then
    entity.endPrimaryFire()
    if ( #storage.state < 100 ) then
      table.insert(storage.state, { ["name"] = name, ["context"] = ctx })
      local state_index = #storage.state
      local state = storage.state[#storage.state]
      if ( not STATE[state.name].enter(state.context) ) then
        table.remove(storage.state, state_index)
      end

    else
      log("State overflow!!!!! Report this!")
    end
  else
    log("State not found: " .. name)
  end
end

function pop_state()
  if ( storage.state == nil or #storage.state == 0 ) then 
    log("Warning: pop_state when stack is empty!")
    return
  end
  
  -- leave callback
  local state = storage.state[#storage.state]
  if ( STATE[state] ~= nil ) then
    STATE[state].leave()
  end
  
  --
  entity.endPrimaryFire()
  table.remove(storage.state)
end


function update_state()
  if ( storage.state == nil or #storage.state == 0 ) then return end
  
  local state = storage.state[#storage.state]
  local state_index = #storage.state
  if ( STATE[state.name] ~= nil ) then
    if ( STATE[state.name].update(state.context) == false ) then
      table.remove(storage.state, state_index)
    end
  else
    pop_state()
  end
  
end

function current_state()
  if ( storage.state == nil or #storage.state == 0 ) then
    return "none"
  end

  return storage.state[#storage.state].name
end
