_G.cormgr = {}
_G.cormgr.corList = {}

--local ocelot = component.proxy(component.list("ocelot")())

local component = import("component")
local filesystem = import("filesystem")
local gpu = component.proxy(component.list("gpu")())

function _G.cormgr.loadCoroutine(path, ...)
  local args = {...}
  local cor = coroutine.create(function()
    local result, errorMessage = xpcall(function(...)
      import(...)
    end, function(errorMessage)
      return errorMessage .. "\n \n" .. debug.traceback()
    end, path, table.unpack(args))
    if not result then
      if print then
        gpu.freeAllBuffers()
        print("\n\27[91m" .. errorMessage)
      else
        error(errorMessage)
      end
    end
    --import(path, table.unpack(args))
  end)
  table.insert(_G.cormgr.corList, cor)
end

function handleError(errormsg)
  if errormsg == nil then
    error("unknown error")
  else
    error(tostring(errormsg).."\n \n"..debug.traceback())
  end
end

local function runCoroutines()
  for i = 1, #_G.cormgr.corList do
    if cormgr.corList[i] then
      local result, errorMessage = coroutine.resume(cormgr.corList[i])
      if cormgr.corList[i] then
        if not result then
          handleError(errorMessage)
        end
        if coroutine.status(cormgr.corList[i]) == "dead" then
          table.remove(cormgr.corList, i)
          i = i - 1
        end
        --computer.pullSignal(0)
        --coroutine.yield()
      end
    end
  end
end

local handle = filesystem.open("/halyde/config/startupapps.cfg", "r")
local data = ""
local tmpdata
repeat
  tmpdata = handle:read(math.huge or math.maxinteger)
  data = data .. (tmpdata or "")
until not tmpdata
for line in data:gmatch("([^\n]*)\n?") do
  if line ~= "" then
    --[[ if _G.print then
      print(line)
    end ]]
    _G.cormgr.loadCoroutine(line)
    runCoroutines()
  end
end
-- _G.cormgr.loadCoroutine("/halyde/core/shell.lua")

while true do
  runCoroutines()
  if #_G.cormgr.corList == 0 then
    computer.shutdown()
  end
end
