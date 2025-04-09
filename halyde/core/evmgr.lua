_G.evmgr = {}
_G.evmgr.eventQueue = {}
local maxEventQueueLength = 10 -- increase if events start getting dropped

local ocelot = component.proxy(component.list("ocelot")())

while true do
  local args
  repeat
    args = {computer.pullSignal(0)}
    if args and args[1] then
      --ocelot.log("Sending signal "..args..","..computer.uptime())
      table.insert(evmgr.eventQueue, args)
      while #evmgr.eventQueue > maxEventQueueLength do
        --ocelot.log("Queue length breach, removing first signal")
        table.remove(evmgr.eventQueue, 1)
      end
    end
  until not args or not args[1]
  --ocelot.log("done")
  coroutine.yield()
end