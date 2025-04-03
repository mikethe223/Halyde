_G.evmgr = {}
_G.evmgr.eventQueue = {}
local maxEventQueueLength = 10 -- increase if events start getting dropped

while true do
  local args
  repeat
    args = computer.pullSignal(0)
    if args then
      table.insert(evmgr.eventQueue, table.pack(computer.uptime(), args))
      while #evmgr.eventQueue > maxEventQueueLength do
        table.remove(evmgr.eventQueue, 1)
      end
    end
  until not args
  coroutine.yield()
end