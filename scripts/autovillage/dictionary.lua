

function make_stutter(message)
  local idx = 0
  local result = string.sub(message, 1, string.find(message, "[%a']"))
  
  -- Add stutter effect for each word
  for word in string.gmatch(message, "[%a']+[^%a']*") do
    -- Stutter a random number of times
    local stutter_count = math.random(math.random(0,1), math.random(1,3))
    for i = 0, stutter_count do
      result = result .. string.sub(word, 1, 1) .. "-"
    end
    
    result = result .. word
  end
  
  return result
end

function dict_parse(message)
  
  -- check if the text should stutter a bit
  local stutter = false
  if ( string.find(message, "<stutter>", 0, true) ) then
    stutter = true
    message = string.gsub(message, "<stutter>", "")
  end
  
  -- Find random synonyms for words
  local lastmsg = ""
  while ( message ~= lastmsg ) do
    lastmsg = message
    message = string.gsub(message, "<([^%a]*)([^>]*)>", 
                          function(a,b)
                            if ( string.find(a, "?", 0, true) ) then
                              if ( math.random(0,WORDS[b] and #WORDS[b] or 2) == 0 ) then
                                return ""
                              end
                            end
                            return WORDS[b] and WORDS[b][math.random(1, #WORDS[b])] or b
                          end
                        )
  end
  
  -- proper spacing
  message = string.gsub(message, "  ", " ")
  message = string.gsub(message, "^%s*", "")
  message = string.gsub(message, "%s*$", "")
  
  -- proper punctuation
  message = string.gsub(message, " ([%p])", "%1")
  
  -- Proper capitalization
  message = string.gsub(message, "([%.%?] ?%l)", string.upper)
  message = string.gsub(message, "^(%l)", string.upper)
  
  -- Apply stutter
  if ( stutter == true ) then
    message = make_stutter(message)
  end
  
  return message
end

WORDS = {
  ["very"] = { "very", "too", "really", "way too", "extremely", "terribly", "unusually", "awfully", "excessively", "incredibly" },
  ["slightly"] = { "slightly", "a bit", "a little", "reasonably" },
  ["more"] = { "some", "more", "additional", "a little bit of" },
  ["less"] = { "less", "fewer" },
  ["ideal"] = { "perfect", "ideal", "excellent", "wonderful" },
  ["wantheat"] = { "get warm", "turn the heat up", "find a fire", "find a heater", "turn up the heat", "get warmer", "find warmth", "light a fire" },
  ["must"] = { "should", "need to", "have to", "must" },
  ["need"] = { "need", "must have", "demand", "require", "desire" },
  ["please"] = { "please", "pretty please" },
  ["join"] = { ". ", ", and " },
  ["burning"] = { "burning", "melting", "flaming" },
  ["help"] = { "help", "medic", "assistance", "support", "guidance", "aid", "doctor" },
  ["place"] = { "here", "right here", "at this location", "presently" },
  ["find"] = { "find", "get", "have" },
  ["cure"] = { "cure", "antidote", "medicine", "remedy", "medication" },
  ["insult"] = { "bucket", "hoser", "knob", "thief", "chicken" },
  ["chop"] = { "chop", "cut", "mince", "cleave", "hack" },
  ["done"] = { "done", "finished", "completed", "performed", "concluded" },
  ["loot"] = { "loot", "stuff", "goods" },
  ["somewhere"] = { "somewhere", "someplace" }
}
