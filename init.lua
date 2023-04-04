-- mod-version:3
local core = require "core"
local DocView = require "core.docview"
local command = require "core.command"
local keymap = require "core.keymap"

local function predicate()
  return core.active_view:is(DocView)
    and not core.active_view.doc:has_selection(), core.active_view.doc
end

local skipChars = {
  '{', '}',
  '(', ')',
  '<', '>', 
  '[', ']',
  '=', ':',
  ';', '.',
  '`', '"',
  "'",
}

local function toSkip(chr)
  for _, a in pairs(skipChars) do 
    if chr == a then return true end 
  end 
end

command.add (predicate, {
  ["tabout:main"] = function (doc)
    local l, c = doc:get_selection()
    
    local prev = doc:get_char(l, c-1)
    local next = doc:get_char(l, c)

    if toSkip(next) then
      doc:set_selection(l, c+1)
    elseif toSkip(prev) and c <= #doc.lines[l] then 
      local i = 0
      while c+i <= #doc.lines[l] do 
        if toSkip(doc:get_char(l, c+i)) then 
          doc:set_selection(l, c+i)
          break
        elseif c+i == #doc.lines[l] then 
          doc:set_selection(l, #doc.lines[l])
        end
        i = i+1
      end
    else
      command.perform "doc:indent"
    end
  end,
})

keymap.add {
  ["tab"] = "tabout:main",  
}
