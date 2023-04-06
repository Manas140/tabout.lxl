-- mod-version:3
local core = require "core"
local DocView = require "core.docview"
local command = require "core.command"
local keymap = require "core.keymap"

local function predicate()
  return core.active_view:is(DocView)
    and not core.active_view.doc:has_selection(), core.active_view.doc
end

-- Chars to Tab Out of
local skipChars = '[%[%]%(%){};:%.<>`=\'\"]'

-- Closing Chars
local closeChars = {
  ['{'] = '}',
  ['('] = ')',
  ['['] = ']',
  ['\''] = '\'',
  ["\""] = "\"",
}

local function toSkip(chr)
  return chr:match(skipChars) ~= nil
end

command.add(predicate, {
  ["tabout:main"] = function (doc)
    local l, c = doc:get_selection()

    local prev = doc:get_char(l, c-1)
    local next = doc:get_char(l, c)
    local line = doc.lines[l]

    if toSkip(next) and (doc:get_text(l, 1, l, c):find('^%s+$') == nil and c > 1) then
      doc:set_selection(l, c+1)
    elseif toSkip(prev) then
      local text = line:sub(c, -1)
      local new_pos = nil

      local similar = text:find(prev, 1, true)
      local close = closeChars[prev]
      local skip = text:find(skipChars) or #line

      if similar ~= nil then -- cursor to next similar char
        new_pos = similar - 1
      elseif close ~= nil then -- cursor to closing char or skip current char
        new_pos = (text:find(close)-1 or skip)
      else
        new_pos = skip -- cursor skips current char or on line end
      end
      doc:set_selection(l, c+new_pos)
    else
      command.perform "doc:indent"
    end
  end
})

keymap.add {
  ["tab"] = { "tabout:main" }
}
