local event = {}

local ocelot = component.proxy(component.list("ocelot")())

function event.pull(type, timeout)
  checkArg(1, type, "string", "nil")
  checkArg(2, timeout, "number", "nil")
  local startTime = computer.uptime()
  local args
  repeat
    for i = 1, #evmgr.eventQueue do
      ocelot.log("Args 1 and 2:")
      ocelot.log(tostring(evmgr.eventQueue[i][1]))
      ocelot.log(tostring(evmgr.eventQueue[i][2]))
      ocelot.log(tostring(evmgr.eventQueue[i][3]))
      ocelot.log(tostring(evmgr.eventQueue[i][4]))
      if evmgr.eventQueue[i][1] >= startTime and (evmgr.eventQueue[i][2] == type or not type) then
        args = evmgr.eventQueue[i]
        break
      end
    end
    if not args then
      coroutine.yield()
    end
  until args and not timeout or args and timeout and (args or computer.uptime() >= startTime + timeout)
  if args then
    table.remove(args, 1)
    return table.unpack(args)
  end
end

return event