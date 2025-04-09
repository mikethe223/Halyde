_G.cormgr = {}
_G.cormgr.corList = {}

--local ocelot = component.proxy(component.list("ocelot")())

local filesystem = import("filesystem")

function _G.cormgr.loadCoroutine(path)
  local cor = coroutine.create(function()
    import(path)
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
    local result, errorMessage = coroutine.resume(_G.cormgr.corList[i])
    if not result then
      handleError(errorMessage)
    end
    if coroutine.status(_G.cormgr.corList[i]) == "dead" then
      table.remove(_G.cormgr.corList, i)
      break
    end
    --computer.pullSignal(0)
    --coroutine.yield()
  end
end

local handle = filesystem.open("/halyde/config/startupapps.txt", "r")
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