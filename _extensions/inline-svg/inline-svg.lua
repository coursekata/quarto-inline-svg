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

---Get the basename from a file path.
---@param path string the file path
---@return string
local function basename(path)
  return path:match('[\\/]([^\\/]+)$')
end

---Remove the suffix from a file path.
---@param path string the file path to modify
---@return string name_only the name of the file or directory with no extension
local function remove_extension(path)
  local removed = path:match("(.+)%..+$")
  if (removed == nil) then
    return path
  end
  return removed
end

---Check if string ends with substring.
---@param str string the string to check
---@param ending string the substring to search end of string for
---@return boolean matched whether the string ends with the substring
---@source http://lua-users.org/wiki/StringRecipes
local function ends_with(str, ending)
  return ending == "" or str:sub(- #ending) == ending
end


---Use a default value if the given string is empty.
---@param str string the string to check
---@param default string the default to use if the string is empty
---@return string result either the string or the default
local function default_string(str, default)
  return (str and str ~= '') and str or default
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

-- Find references to generated SVGs and replace with SVGs.
local formats = { "html*", "markdown*", "commonmark*", "gfm", "markua" }
if match_any(FORMAT, formats) then
  function Image(elem)
    local title = default_string(elem.attr['title'], "Untitled figure")
    local desc = default_string(elem.attr['alt'], "No description")
    if file_exists(elem.src) and ends_with(elem.src, ".svg") then
      -- image name is unique, so we can use it for IDs
      local img_name = remove_extension(basename(elem.src))
      local title_id = img_name .. "--title"
      local desc_id = img_name .. "--desc"

      -- read the SVG and add the accessibility components
      local svg_content = read(elem.src)
      svg_lines = split(svg_content, "\r\n")
      table.remove(svg_lines, 1)
      svg_lines[1] = svg_lines[1]:gsub(">$",
        string.format(' role="img" aria-labelledby="%s" aria-describedby="%s">', title_id, desc_id))
      table.insert(svg_lines, 2, string.format('<title id="%s">%s</title>', title_id, title))
      table.insert(svg_lines, 3, string.format('<desc id="%s">%s</desc>', desc_id, desc))

      -- inline the SVG
      elem = pandoc.RawInline("html", table.concat(svg_lines, ""))
      return { elem }
    end
  end
end
