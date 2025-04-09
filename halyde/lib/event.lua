local event = {}

local ocelot = component.proxy(component.list("ocelot")())

function event.pull(evtype, ...)
  local timeout = ...
  checkArg(1, evtype, "string", "nil")
  checkArg(2, timeout, "number", "nil")
  local startTime = computer.uptime()
  local args = {}
  local finished = false
  repeat
    for i = 1, #evmgr.eventQueue do
      if evmgr.eventQueue[i][2] == evtype or not evtype then
        args = table.copy(evmgr.eventQueue[i])
        table.remove(evmgr.eventQueue, i)
        break
      end
    end
    if evtype then
      finished = args[1] == evtype
    end
    if timeout then
      finished = computer.uptime() >= startTime + timeout
    end
    if not finished then
      coroutine.yield()
    end
  until finished
  ocelot.log(tostring(args[1]))
  return table.unpack(args)
end

return event