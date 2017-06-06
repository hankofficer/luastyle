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

function stylizeLuaCode(luaChunk)
  local stylizedLuaChunk = luaChunk

  return stylizedLuaChunk
end

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

for i=1,#arg do
  stylizeLuaFile(arg[i])
end