function init(args)
  entity.setInteractive(false)
  entity.setAnimationState("switchState", "on")
  entity.setInteractive(true)
end

function main()
end


--- Called when the object is interacted with.
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
function onInteraction(args)
  species = world.entitySpecies(args.sourceId)
  world.spawnNpc(entity.toAbsolutePosition({ 0.0, 2.0 }), species, "autovillager", 0);
  
  return nil
end
