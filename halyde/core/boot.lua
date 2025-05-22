local loadfile = ...
local filesystem = loadfile("/halyde/lib/filesystem.lua")(loadfile)

_G._OSVERSION = "Halyde 1.4.0"
_G._OSLOGO = ""
local handle, tmpdata = filesystem.open("/halyde/config/oslogo.ans", "r"), nil
repeat
  tmpdata = handle:read(math.huge)
  _OSLOGO = _OSLOGO .. (tmpdata or "")
until not tmpdata

local gpu = component.proxy(component.list("gpu")())
local screenAddress = component.list("screen")()
--local screen = component.proxy(screenAddress)

gpu.bind(screenAddress)
--local maxWidth, maxHeight = gpu.maxResolution()
--local aspectX, aspectY = screen.getAspectRatio()
--local screenRatio = aspectX * 2 / aspectY

-- Calculate potential dimensions
--local widthLimited = math.floor(maxHeight * screenRatio)
--local heightLimited = math.floor(maxWidth / screenRatio)

--local targetWidth, targetHeight

--if widthLimited <= maxWidth then
  -- height is the limiting factor
--  targetWidth = widthLimited
--  targetHeight = maxHeight
--else
  -- width is the limiting factor
--  targetWidth = maxWidth
--  targetHeight = heightLimited
--end

--targetWidth = math.min(targetWidth, maxWidth)
--targetHeight = math.min(targetHeight, maxHeight)

--gpu.setResolution(targetWidth, targetHeight)
gpu.setResolution(gpu.maxResolution())

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
