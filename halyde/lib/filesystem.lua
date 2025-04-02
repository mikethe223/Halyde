local loadfile = ... -- raw loadfile from boot.lua
local component

if loadfile then
  component = loadfile("/halyde/lib/component.lua")(loadfile)
else
  component = require("component")
end

local filesystem = {}

function filesystem.processPath(path) -- returns the address and absolute path of a filesystem path as well as sanitizing it
  checkArg(1, path, "string")
  absPath = path:gsub("/+", "/"):gsub("/$", "")
  local address = nil
  if absPath:find("^/mnt/.../") then
     address = component.get(path:sub(6,8))
    if not address then
      address = computer.getBootAddress()
    else
      absPath = absPath:sub(9)
    end
  else
    address = computer.getBootAddress()
  end
  if not address then
    return nil, "no such device"
  end
  return address, absPath
end

function filesystem.exists(path) -- check if path exists
  checkArg(1, path, "string")
  local address, absPath = filesystem.processPath(path)
  if not address then
    return false
  end
  return component.invoke(address, "exists", absPath)
end

function filesystem.open(path, mode) -- opens a file and returns its handle
  checkArg(1, path, "string")
  checkArg(2, mode, "string", "nil")
  if not mode then
    mode = "r"
  end
  if not (mode == "r" or mode == "w" or mode == "rb" or mode == "wb") then
    return nil, "invalid handle type"
  end
  local address, absPath = filesystem.processPath(path)
  local handle = component.invoke(address, "open", absPath, mode)
  local properHandle = {}
  properHandle.handle = handle
  properHandle.address = address
  function properHandle.read(self, amount)
    checkArg(2, amount, "number")
    return component.invoke(self.address, "read", self.handle, amount)
  end
  function properHandle.write(self, data)
    checkArg(2, data, "string")
    return component.invoke(self.address, "write", self.handle, data)
  end
  function properHandle.close(self)
    return component.invoke(self.address, "close", self.handle)
  end
  return properHandle
end

return(filesystem)