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
  -- nothing for now
  assert(false, errormsg)
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
    _G.cormgr.loadCoroutine(line)
  end
end
_G.cormgr.loadCoroutine("/halyde/core/shell.lua")

while true do
  for i = 1, #_G.cormgr.corList do
    local result, errormsg = coroutine.resume(_G.cormgr.corList[i])
    if coroutine.status(_G.cormgr.corList[i]) == "dead" then
      table.remove(_G.cormgr.corList, i)
      if not result then
        handleError(errormsg)
      end
    end
    computer.pullSignal(0)
  end
  if #_G.cormgr.corList == 0 then
    computer.shutdown()
  end
end