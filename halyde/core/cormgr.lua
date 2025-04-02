_G.cormgr = {}
_G.cormgr.corList = {}

function _G.cormgr.loadCoroutine(path)
  local cor = coroutine.create(function()
    import(path)
  end)
  table.insert(_G.cormgr.corList, cor)
  coroutine.yield()
end

function handleError(errormsg)
  -- nothing for now
  assert(false, errormsg)
end

_G.cormgr.loadCoroutine("/halyde/core/loader.lua")

while true do
  for i = 1, #_G.cormgr.corList do
    local result, errormsg = coroutine.resume(_G.cormgr.corList[i])
    if coroutine.status(_G.cormgr.corList[i]) == "dead" then
      table.remove(_G.cormgr.corList, i)
      if not result then
        handleError(errormsg)
      end
    end
    computer.pullSignal(1)
  end
end