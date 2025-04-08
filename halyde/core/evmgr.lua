_G.evmgr = {}
_G.evmgr.eventQueue = {}
local maxEventQueueLength = 10 -- increase if events start getting dropped

local ocelot = component.proxy(component.list("ocelot")())

while true do
  local args
  repeat
    args = computer.pullSignal(0)
    if args then
      ocelot.log("Sending signal "..args..","..computer.uptime())
      table.insert(evmgr.eventQueue, {computer.uptime(),args})
      while #evmgr.eventQueue > maxEventQueueLength do
        ocelot.log("Queue length breach, removing first signal")
        table.remove(evmgr.eventQueue, 1)
      end
      --ocelot.log("Event queue:")
      for i = 1, #evmgr.eventQueue do
        --ocelot.log("Args 1 and 2:")
        --ocelot.log(tostring(evmgr.eventQueue[i][1]))
        --ocelot.log(tostring(evmgr.eventQueue[i][2]))
      end
    end
  until not args
  coroutine.yield()
end
