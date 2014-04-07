--- Stubs for global functions NPC scripts can define, which will be called by C++

--- Called when the NPC is added to the world.
function init()
  entity.setInteractive(true)
  
  -- Initialize autoville variables if not already
  if ( storage.goals == nil ) then storage.goals = {} end
  if ( storage.thoughts == nil ) then storage.thoughts = {} end
  if ( storage.under_attack == nil ) then storage.under_attack = 0 end
  if ( storage.poisoned == nil ) then storage.poisoned = 0 end
  if ( storage.burned == nil ) then storage.burned = 0 end
  if ( storage.inventory == nil ) then storage.inventory = {} end
  self.pathing = {}
  
  storage.last_say = 0
  push_state("idle")
end

--- Update loop handler.
-- Called once every `scriptDelta` (as defined in *.npctype) game ticks
function main()
  update_thoughts()
  update_goals()
  update_state()
  check_drops()
  
  if ( storage.under_attack > 0 ) then 
    storage.under_attack = storage.under_attack - 1
  end
  
  if ( storage.poisoned > 0 ) then 
    storage.poisoned = storage.poisoned - 1
  end
  
  if ( storage.burned > 0 ) then 
    storage.burned = storage.burned - 1
  end
  
  if ( get_inventory_itemtype("harvestingtool") ~= nil ) then
    storage.job = "lumberjack"
  end
end

-- Retrieves the name of the NPC.
function name()
  return world.entityName(entity.id())
end

--- Called when the npc has died and is about to be removed.
function die()
  inv_drop_all()
end

-- pushes walk state
function walk_to(destination)
  push_state("walk", { ["destination"] = destination })
end

--- Called after the NPC has taken damage.
--
-- @tab args Map of info about the damage, structured as:
--    {
--      sourceId = <entity id of entity that caused the damage>,
--      damage = <numeric amount of damage that was taken>,
--      sourceDamage = <numeric amount of damage that was originally dealt>,
--      sourceKind = <string kind of damage being applied, as defined in "damageKind" value in a *.projectile config>
--    }
-- Note that "sourceDamage" can be higher than "damage" if - for instance -
-- some damage was blocked by a shield.
function damage(args)
  if ( args and args.sourceDamage > 0 ) then
    
    if ( args.sourceKind == "acid" or args.sourceKind == "testpoison") then
      storage.poisoned = 20
    elseif ( args.sourceKind == "fire" or args.sourceKind == "testburning" or args.sourceKind == "flamethrower"  or args.sourceKind == "heat") then
      storage.burned = 20
    else
      --world.logInfo(args.sourceKind)
      storage.under_attack = 20
    end
    
  end
end

--- Called when the NPC is interacted with.
-- Available interaction responses are:
--    "OpenCockpitInterface"
--    "SitDown"
--    "OpenCraftingInterface"
--    "OpenCookingInterface"
--    "OpenTechInterface"
--    "Teleport"
--    "OpenStreamingVideoInterface"
--    "PlayCinematic"
--    "OpenSongbookInterface"
--    "OpenNpcInterface"
--    "OpenNpcCraftingInterface"
--    "OpenTech3DPrinterDialog"
--    "ShowPopup"
--
-- @tab args Map of interaction event arguments:
--    {
--      sourceId = <Entity id of the entity interacting with this NPC>
--      sourcePosition = <The {x,y} position of the interacting entity>
--    }
--
-- @return[1] nil (no interaction response)
-- @treturn[2] string the interaction response that should be performed
-- @treturn[3] array the interaction response and configuration:
--    {
--       <interaction response string>,
--       <interaction response config table (map)>
--    }
function interact(args)
  if ( storage.job == nil ) then
    entity.say("This is a test.")
  else
    entity.say("I am a " .. storage.job)
  end
  return nil
end

-- Causes the NPC to speak. It randomly chooses one of the given arguments.
-- It then parses the text message, finds synonyms, punctuates it, etc. before
-- finally saying the message out loud.
function talk(...)
  local arg = {...}
  if ( #arg == 0 ) then return end

  local message = arg[math.random(1,#arg)]
  --world.logInfo("  ... " .. message)
  message = dict_parse(message)
  log(message)
  entity.say( message )
  storage.last_say = world.time()
end

function listen(from, message)
  
end

-- Logs a message with the given NPCs name attached.
function log(msg, ...)
  world.logInfo("[" .. world.entityName(entity.id()) .. "] " .. msg, ...)
end


--------------------------------------------------------------------------------
-- Sets the facing direction of the entity. Also changes the aim position.
-- @param {integer} direction The direction to face. A negative value
--                            will face left, and a positive value will
--                            face right.
function setFacingDirection(direction)
  entity.setFacingDirection(direction)
  entity.setAimPosition(vec2.add({ util.toDirection(direction), -1 }, entity.position()))
end
--------------------------------------------------------------------------------
-- Valid options:
--   openDoorCallback: function that will be passed a door entity id and should
--                     return true if the door can be opened
--   run: whether npc should run
function moveTo(targetPosition)
  targetPosition = {
    math.floor(targetPosition[1]) + 0.5,
    math.floor(targetPosition[2]) + 0.5
  }

  -- TODO just check if this is an x-only movement and the path is clear

--  world.debugLine(entity.position(), targetPosition, "red")
--  world.debugPoint(targetPosition, "red")

  local pathTargetPosition = self.pathing.targetPosition
  if pathTargetPosition == nil or
      targetPosition[1] ~= pathTargetPosition[1] or
      targetPosition[2] ~= pathTargetPosition[2] then

    if entity.findPath(targetPosition, 3, 4) then
      self.pathing.targetPosition = targetPosition
    else
      self.pathing.targetPosition = nil
    end

    self.pathing.delta = nil
  end

  if self.pathing.targetPosition then
    local pathDelta = entity.followPath()

    -- Store the path delta in case pathfinding doesn't succeed on the next try
    if pathDelta ~= nil then
      self.pathing.delta = pathDelta
    else
      self.pathing.targetPosition = nil
    end
  end

  local position = entity.position()
  local delta
  if self.pathing.delta ~= nil then
    delta = self.pathing.delta
  else
    delta = world.distance(targetPosition, position)
    delta = vec2.mul(vec2.norm(delta), math.min(world.magnitude(delta), 2))
  end

  setFacingDirection(delta[1])

  -- Open doors in the way
  local closedDoorIds = world.objectLineQuery(position, { position[1] + util.clamp(delta[1], -2, 2), position[2] }, { callScript = "hasCapability", callScriptArgs = { "closedDoor" } })
  for _, closedDoorId in pairs(closedDoorIds) do
    world.callScriptedEntity(closedDoorId, "openDoor")
  end

  -- Keep jumping
  if entity.isJumping() or (not entity.onGround() and self.pathing.jumpHoldTimer ~= nil) then
    if self.pathing.jumpHoldTimer ~= nil then
      entity.holdJump()

      self.pathing.jumpHoldTimer = self.pathing.jumpHoldTimer - entity.dt()
      if self.pathing.jumpHoldTimer <= 0 then
        self.pathing.jumpHoldTimer = nil
      end
    end

    entity.move(delta[1], false)

    return true
  end
  self.pathing.jumpHoldTimer = nil

  local region = {
    math.floor(position[1] + 0.5) - 1, math.floor(position[2] + 0.5) - 3,
    math.floor(position[1] + 0.5) + 1, math.floor(position[2] + 0.5) + 1,
  }
  local endpointGroundRegion = {
    region[1] + delta[1], region[2] + delta[2] - 1,
    region[3] + delta[1], region[2] + delta[2]
  }
  local verticalMovementRatio
  if delta[1] == 0 then
    verticalMovementRatio = 10 -- arbitrary "large" number
  else
    verticalMovementRatio = math.abs(delta[2]) / math.abs(delta[1])
  end

  -- The path might just be taking us up some stairs, so we'll only jump if the
  -- endpoint is not supported, or it's really taking us quite vertical
  if delta[2] > 0 and (not world.rectCollision(endpointGroundRegion, false) or verticalMovementRatio > 2.0) then
-- TODO only jump if we have clearance when adding the deltaY to head pos (i.e. move "region" up by deltaY and check)
    entity.jump()
    self.pathing.jumpHoldTimer = verticalMovementRatio
  elseif delta[2] < 0 and verticalMovementRatio > 1.75 then
-- TODO trace from end of path to feet and see if path is trying to move us through a platform
    -- Drop down through a platform
    entity.moveDown()
  else
    local direction = util.toDirection(delta[1])

    -- Might be a quick hop over an obstruction before we can follow the path,
    -- note that we're not including the first block at the feet in this check,
    -- but are checking a point just inside that block, so we don't always jump
    -- when running up to the top of stairs (unless there is a ledge there)
    local nextStepRegion = {
      region[1] + direction, region[2] + 1,
      region[3] + direction, region[4] + 1
    }
    if world.rectCollision(nextStepRegion, true) then
      entity.jump()
      self.pathing.jumpHoldTimer = 0
      entity.move(direction, false)
      return true
    end

    -- Jump over gaps
    local maxFallDistance = 8
    local nextStepLowerRegion = {
      nextStepRegion[1] + direction, nextStepRegion[2] - maxFallDistance,
      nextStepRegion[3] + direction, nextStepRegion[4]
    }

    if not world.rectCollision(nextStepLowerRegion, false) then
      local maxJumpDistance = 8

      local jumpRegion = {
        nextStepRegion[1] + direction, nextStepRegion[2] - maxFallDistance,
        nextStepRegion[3] + direction, nextStepRegion[4] - 3
      }
      for offset = 1, maxJumpDistance, 1 do
        if world.rectCollision(jumpRegion, false) then
          entity.jump()
          entity.move(delta[1], false)
          self.pathing.jumpHoldTimer = offset * 0.5
          return true
        end
        jumpRegion[1] = jumpRegion[1] + direction
        jumpRegion[3] = jumpRegion[3] + direction
      end

      return false, "ledge"
    end
  end

  entity.move(delta[1], false)

  return true
end

