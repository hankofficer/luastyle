--[[
  Copyright (c) 2017 Bo-Han Liao

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

-- configuration
g_remove_leading_space = true
g_remove_trailing_space = true
g_reintent = true
g_add_space_for_comma = true
g_intent_word = '  '

-- parameter for development
g_debug = false

--[[
  Remove all leading spaces in a line
--]]
function removeLeadSpace(line)
  local newLine = line:match('^%s*(.+)')
  if newLine == nil then
    newLine = ''
  end
  return newLine
end

--[[
  Remove all trailing spaces in a line
--]]
function removeTrailSpace(line)
  local newLine = line:match('(.-)%s*$')
  if newLine == nil then
    newLine = ''
  end
  return newLine
end

--[[
  Detect how many clauses in a single line
--]]
function numOfClause(line)
  local clauseList = {
    {'then', 'elseif'},
    {'then', 'else'},
    {'then', 'end'},
    {'do', 'end'},
    {'repeat', 'until'}
  }
  local count = 0

  for _, clausePair in ipairs(clauseList) do
    local reg = clausePair[1]..'(.-)'..clausePair[2]
    if string.match(line, reg) then
      count = count + 1
    end
  end

  return count
end

--[[
  Detect intention changes
--]]
function intent(line)
  local currentIntent = 0
  local laterIntent = 0
  local keywordList = {
    --keywords    = {current, later}
    ['function']  = { 0, 1},
    ['if']        = { 0, 1},
    ['elseif']    = {-1, 1},
    ['else']      = {-1, 1},
    ['for']       = { 0, 1},
    ['while']     = { 0, 1},
    ['end']       = {-1, 0},
    ['repeat']    = { 0, 1},
    ['until']     = {-1, 0},
  }

  for keyword, diff in pairs(keywordList) do
    if string.match(line, keyword) then
      currentIntent = currentIntent + diff[1]
      laterIntent = laterIntent + diff[2]
    end
  end

  local n = numOfClause(line)
  currentIntent = currentIntent + n
  laterIntent = laterIntent - n

  return currentIntent, laterIntent
end

--[[
  Add a space after comma if there is no one.
--]]
function addSpaceForComma(line)
  outputTable = {}
  local i, j = 1, 1

  local cmtLine = string.find(line, '%-%-[^%[][^%[]')

  while true do
    local cmtStart, cmtEnd = string.find(line, '%-%-%[%[(.-)%]%]')
    j = string.find(line, ',%S', i)
    if j == nil then 
      -- Append remaining string
      table.insert(outputTable, line:sub(i))
      break
    elseif (cmtStart and cmtEnd and j > cmtStart and j < cmtEnd) or 
           (cmtLine and j > cmtLine) then
      -- Skip comments
      table.insert(outputTable, line:sub(i,j))
    else
      -- Add a space
      table.insert(outputTable, line:sub(i,j)..' ')
    end

    i = j + 1
  end

  return table.concat(outputTable)
end

--[[
  Stylize Lua script line by line
--]]
function stylizeLuaCode(luaChunk)
  local stylized = luaChunk
  local stylizedTbl = {}
  local intentLevel = 0

  for line in string.gmatch(luaChunk..'\n', "([^\n]*)\n") do
    if g_remove_leading_space then
      line = removeLeadSpace(line)
    end

    if g_remove_trailing_space then
      line = removeTrailSpace(line)
    end
    
    local currentIntent, laterIntent = intent(line)

    intentLevel = intentLevel + currentIntent

    if g_add_space_for_comma then
      line = addSpaceForComma(line)
    end

    if g_reintent then
      for i=1,intentLevel do
        line = g_intent_word..line
      end
    end
    
    if g_debug then
      line = string.format('%d %d %d\t%s',
                           intentLevel, currentIntent, 
                           laterIntent, line)
    end
    line = line..'\n'
    table.insert(stylizedTbl, line)

    intentLevel = intentLevel + laterIntent
  end

  if g_debug then
    print(table.concat(stylizedTbl))
    return luaChunk
  else
    return table.concat(stylizedTbl)
  end
end

--[[
  Stylize a Lua script
--]] 
function stylizeLuaFile(filename)
  local file = io.open(filename, 'r')
  if not file then
    print(string.format('Warning: %s is not existed.',filename))
    return
  end

  local stylizedLuaChunk = stylizeLuaCode(file:read('*all'))
  file:close()

  file = io.open(filename, 'w')
  file:write(stylizedLuaChunk)
  file:close()
end

--[[
  Display help
--]] 
function displayHelp()
  print('usage: '..arg[0]..' [options] [file_names]')
  print('    -h    Display this help message.')
end

--[[
  Main script
--]]
if #arg == 0 then
  displayHelp()
  return
end

for _,v in pairs(arg) do
  if v == '-h' then
    displayHelp()
    return
  end
end

-- Go through every Lua file, well, assuming they are Lua file.
for i=1,#arg do
  -- Only process .lua extension
  if string.find(arg[i], '%.lua$') then
    stylizeLuaFile(arg[i])
  end
end