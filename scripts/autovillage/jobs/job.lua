JOB = {}

function assign_job(name)
  if ( name == nil or JOB[name] == nil ) then return false end
  
  storage.job = name
  return JOB[name].assign()
end

function update_job()
  if ( storage.job == nil or JOB[storage.job] == nil ) then return false end
  
  return JOB[storage.job].update()
end

function enter_job_state()
  if ( storage.job == nil or JOB[storage.job] == nil ) then return false end
  
  return JOB[storage.job].enter()
end

function leave_job_state()
  if ( storage.job == nil or JOB[storage.job] == nil ) then return end
  
  JOB[storage.job].leave()
end

--[[

Many during work: work/craftsmen clothing

[Resources]
  Lumberjack                                                                  >> wood
  Farmer                                                                      >> ingredients, crops, seeds, milk, eggs, stuff
  Hunter                                                                      >> meats,pelts,leather,brains,bones
  Miner                   {flashlight, safety helmet, lantern stick, torch}          >> ores/rocks
  Gatherer                                                                    >> ingredients, petals, fibres, mushrooms, etc.
      
[Production]
  Herbalist     
  Recycler/Custodian      {flashlight, toxic waste, safety helmet, dangerous barrel}
  Chef                    {wooden cooking table}     >> food
  Tailor                  {yarn spinner}                                                    >> clothing
  Blacksmith              {metalwork station, iron anvil}                                       >> armor, tools
  Metalworker             {stone furnace, refinery}                                       >> ?
  Woodcutter              {wooden crafting table}                               >> ?
  Electrician             {wiring tool, wiring station}                         >>  electrical
  Librarian               {books, bookshelves}                >>  books
      
[Military]
  Guard                   {armors, flashlight}
  Adventurer              {armors, flashlight, torch}
  Medic                   {}
  Explorer                {flashlight}
  
[Special]
  Musician                {}
  Actor                   {}
  Builder
  Priest                  {clothing depicting deity}
  Mayor                   {formal clothing}
  
[Sale]
  Trader
  Merchant
    Musical Instruments
    Misc              <petals, plant fibre>
    Farmers Market    <Anything farmers produce, incl. seeds>
    Pharmacy          <stim packs,medical kit, bandage>
    Ores              <ores,bars>
    Food              <food>
    Tools             <flashlights, rope, hunting bow, flares, brain extractor, pickaxe, hoe, drill, paint tool, lantern, torches, campfire, grappling hook, axe, matter manipulator>
    Melee Weapons     
    Guns              
    Throwables        <throwing items, grenades, bomb>
    Books             <codex, paper, books>
    Clothing          <non-armor clothing, dyes>
    Armor             <armors: helm, chest, pants>
    Electrical        <wiring tool, wire, switches>
  Bartender       {rum barrel} <wines, beers, whiskey>
    
  
]]
