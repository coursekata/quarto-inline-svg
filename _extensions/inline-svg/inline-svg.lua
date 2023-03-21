---Base64 encoder.
---@param data string
---@return string
---Copyright: Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>.
---License: LGPL2.
---@source http://lua-users.org/wiki/BaseSixtyFour
function base64(data)
  local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
      end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return chars:sub(c + 1, c + 1)
      end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

---Split a string by character sequence.
---@param str string a string that may have multiple lines in it
---@param chars string a character string to split on
---@return table parts a table with one entry per part in the string (squished)
local function split(str, chars)
  parts = {}
  for line in str:gmatch("[^" .. chars .. "]+") do
    table.insert(parts, line)
  end
  return parts
end

---Determine if a file exists and is readable.
---@param path string the file to check
---@return boolean is_readable whether the file exists and is readable
---@source http://lua-users.org/wiki/FileInputOutput
local function file_exists(path)
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

---Read an entire file.
---@param path string the file to read
---@return string contents the contents of the file
---@source http://lua-users.org/wiki/FileInputOutput
local function read(path)
  local fh = assert(io.open(path, "rb"))
  local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
  fh:close()
  return contents
end

---Read an SVG file to string, discarding the XML header tag.
---@param path string the path to the SVG file
---@return string contents the contents of the file (less the <xml> header tag)
local function read_svg(path)
  local svg_content = read(path)
  local svg_lines = split(svg_content, "\r\n")
  table.remove(svg_lines, 1)
  return table.concat(svg_lines, "")
end

---Match any of the given strings.
---@param str string the string to match
---@param targets table the strings to match against
---@return boolean matched whether the string is present in the targets
local function match_any(str, targets)
  for _, target in ipairs(targets) do
    if str:match(target) then
      return true
    end
  end
  return false
end

---Check if string ends with substring.
---@param str string the string to check
---@param ending string the substring to search end of string for
---@return boolean matched whether the string ends with the substring
---@source http://lua-users.org/wiki/StringRecipes
local function ends_with(str, ending)
  return ending == "" or str:sub(- #ending) == ending
end

-- Find references to generated SVGs and replace with SVGs.
local formats = { "html*", "markdown*", "commonmark*", "gfm", "markua" }
if match_any(FORMAT, formats) then
  function Image(elem)
    if file_exists(elem.src) and ends_with(elem.src, ".svg") then
      local svg = read_svg(elem.src)
      elem.src = "data:image/svg+xml;base64," .. base64(svg)
      return { elem }
    end
  end
end
