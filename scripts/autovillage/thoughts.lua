
-- thought = { timestamp, thought, target, parameters }

THOUGHT = {
  ["hot"] = { msg = { "it's <?very> hot <?place>", "I'm boiling", "I need to cool off <?somewhere>" },
              group = "temp" },
  ["cold"] = { msg = { "<stutter>it's <?very> cold <?place>", "<stutter>I'm freezing", "bbrrrrrrr", "<stutter><must> <wantheat>", "<stutter><need> warmth" },
               group = "temp" },
  ["windy"] = { msg = { "it's <?very> windy <?place>", "<very> windy" } },
  ["dark"] = { msg = { "it's <?very> dark <?place>", "I need <?more> light" },
               group = "light" },
  ["bright"] = { msg = { "it's <?very> bright <?place>", "we don't need this much light", "I need to turn off some of these lights" },
               group = "light" },
  ["oxygen"] = { msg = { "I can't breathe", "Lack of oxygen" } },
  ["stuck"] = { msg = { "I'm stuck", "<help> <?please>", "help me <?please>" } },
  
  ["drowning"] = { msg = { "I'm drowning", "<help> <please>", "save me <?please>" } },
  ["poisoned"] = { msg = { "I'm poisoned", "<?I> <need> a <cure>", "<?I> <need> <help>", "<?I> <must> <find> a <cure>" } },
  ["burned"] = { msg = { "I'm <burning> <?up>", "<help> <please>", "<?I> <need> <help>", "need water" } },
  
  ["attacked"] = { msg = { "I'm under attack", "I'm hit" } },
  
  ["good temp"] = { msg = { "the temperature is <ideal>", "ah, the <ideal> temperature", "it feels really <ideal>" },
               group = "temp" },
  ["good light"] = { msg = { "the lighting here is <ideal>", "ah, the <ideal> lighting", "the light here is really <ideal>" },
               group = "light" }
}

function check_thoughts()
  local temp = world.temperature(entity.position())
  local wind = world.windLevel(entity.position())
  local light = world.lightLevel(entity.position())
  local breath = world.breathable(entity.position())
  local stuck = world.pointCollision(entity.position(), true)

  local liquid = world.liquidAt(entity.position())
  local drowning = false
  if ( liquid ~= nil ) then
    drowning = liquid.id ~= 0
  end
  
  -- temperature
  if ( temp < 1 ) then
    add_thought("cold")
  elseif ( temp > 40 ) then
    add_thought("hot")
  else
    remove_thought("temp")
  end
  
  -- wind
  if ( wind > 50 ) then
    add_thought("windy")
  else
    remove_thought("windy")
  end
  
  -- lighting
  if ( light < 0.01 ) then
    add_thought("dark")
  elseif ( light > 0.9 ) then
    add_thought("bright")
  else
    remove_thought("light")
  end
  
  -- breath
  if ( not breath ) then
    add_thought("oxygen")
  else
    remove_thought("oxygen")
  end
  
  -- stuck
  if ( stuck ) then
    add_thought("stuck")
  else
    remove_thought("stuck")
  end
  
  -- poison
  if ( storage.poisoned > 0 ) then
    add_thought("poisoned")
  else
    remove_thought("poisoned")
  end
  
  -- burning
  if ( storage.burned > 0 ) then
    add_thought("burned")
  else
    remove_thought("burned")
  end
  
  -- drowning
  if ( drowning ) then
    add_thought("drowning")
  else
    remove_thought("drowning")
  end
  
  -- being attacked
  if ( storage.under_attack > 0 ) then
    add_thought("attacked")
  else
    remove_thought("attacked")
  end

end

-- 
-- @param thought the thought ID
-- @param target -1 for self, otherwise the target entity id
-- @param params additional parameters that belong to the thought
function add_thought(thought, target, params)
  if ( target == nil ) then target = -1 end
  if ( storage.thoughts == nil ) then storage.thoughts = {} end
  
  -- assign category
  local category = nil
  if ( THOUGHT[thought] and THOUGHT[thought].group ) then
    category = THOUGHT[thought].group
  end
  
  -- Create the thought
  local new_thought = {  ["timestamp"] = world.time(),
                         ["thought"] = thought,
                         ["target"] = target,
                         ["params"] = params }
                                    
  --if ( category == nil or category == "all" or category == "any" or category == "" ) then
  --  table.insert(storage.thoughts, new_thought)
  --else
  storage.thoughts[category or thought] = new_thought
  --end
end

function remove_thought(category)
  storage.thoughts[category] = nil
end

function get_thought_message(thought)
  return THOUGHT[thought] and THOUGHT[thought].msg and THOUGHT[thought].msg[math.random(1, #THOUGHT[thought].msg)] or ""
end

function update_thoughts()
  if ( storage.thoughts == nil ) then storage.thoughts = {} end
  if ( storage.next_thought == nil ) then storage.next_thought = 0 end
  
  check_thoughts()
  
  
  if ( storage.last_say + storage.next_thought < world.time() ) then
    local thought_str = ""
    
    for k,v in pairs(storage.thoughts) do
      
      local msg = get_thought_message(v.thought)
      if ( string.len(msg) > 0 ) then
        if ( string.len(thought_str) > 0 ) then
          thought_str = thought_str .. "<join>"
        end
        thought_str = thought_str .. msg
      end
    end -- for
    
    -- If there are any thoughts..
    if ( string.len(thought_str) > 0 ) then
      thought_str = thought_str .. "."
      
      storage.next_thought = math.random(12,15)
      talk(thought_str)
    end
    
  end
end
