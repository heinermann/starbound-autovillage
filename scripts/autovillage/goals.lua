
GOALS = {
  SEEK_HEAT = 1,
  SEEK_COLD = 2,
  SEEK_INDOORS = 3,
  SEEK_LIGHT = 4,
  SEEK_OXYGEN = 5,
  BREAK_FREE = 6,
  EXPLORE = 7
  
}

-- 
-- @param goal the goal ID
-- @param target -1 for self, otherwise the target entity id (to help/attack/etc)
-- @param params additional parameters that belong to the goal
function add_goal(category, goal, target, params)
  if ( target == nil ) then target = -1 end
  
  if ( storage.goals == nil ) then storage.goals = {} end
  
  local new_goal = {  ["timestamp"] = world.time(),
                      ["goal"] = goal,
                      ["target"] = target,
                      ["params"] = params }
                                    
  if ( category == "all" or category == "any" or category == nil ) then
    table.insert(storage.goals, new_goal)
  else
    storage.goals[category] = new_goal
  end
end


function update_goals()
  
end
