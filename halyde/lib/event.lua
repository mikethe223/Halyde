local event = {}

local ocelot = component.proxy(component.list("ocelot")())

function event.pull(evtype, timeout)
  checkArg(1, evtype, "string", "nil")
  checkArg(2, timeout, "number", "nil")
  local startTime = computer.uptime()
  local args
  repeat
    for i = 1, #evmgr.eventQueue do
      ocelot.log(tostring(evmgr.eventQueue[i][1]).." ("..type(evmgr.eventQueue[i][1]).."), "..tostring(evmgr.eventQueue[i][2]))
      --ocelot.log(tostring(evmgr.eventQueue[i][3]))
      --ocelot.log(tostring(evmgr.eventQueue[i][4]))
      if evmgr.eventQueue[i][1] >= startTime and (evmgr.eventQueue[i][2] == evtype or not evtype) then
        args = evmgr.eventQueue[i]
        break
      end
    end
    if not args then
      coroutine.yield()
    end
  until args and not timeout or args and timeout and (args or computer.uptime() >= startTime + timeout)
  if args then
    --[[ table.remove(args, 1)
    return table.unpack(args) ]]
    return args[2]
  end
end

return event
