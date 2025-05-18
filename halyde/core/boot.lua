local loadfile = ...
local filesystem = loadfile("/halyde/lib/filesystem.lua")(loadfile)

_G._OSVERSION = "Halyde 1.0.0"

function _G.import(module, ...)
  local args = table.pack(...)
  local modulepath
  if module:find("^/") then
    if filesystem.exists(module) then
      modulepath = module
    end
  elseif filesystem.exists("/halyde/lib/"..module..".lua") then
    modulepath = "/halyde/lib/"..module..".lua"
  elseif shell and shell.workingDirectory and filesystem.exists(shell.workingDirectory..module) then
    modulepath = shell.workingDirectory..module
  end
  assert(modulepath, "module not found\npossible locations:\n/halyde/lib/"..module..".lua")
  local handle = filesystem.open(modulepath)
  local data = ""
  local tmpdata = ""
  repeat
    tmpdata = handle:read(math.huge or math.maxinteger)
    data = data .. (tmpdata or "")
  until not tmpdata
  return(assert(load(data, "="..modulepath))(table.unpack(args)))
end

--local handle = assert(filesystem.open("/bazinga.txt", "w"))
--assert(handle:write("Bazinga!"))
--handle:close()

import("/halyde/core/cormgr.lua")
