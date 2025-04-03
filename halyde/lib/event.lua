local event = {}

function event.pull(timeout, type)
  local startTime = computer.uptime()
  local args
  repeat
    for _, eventArgs in ipairs(_G.evmgr.eventQueue) do
      if eventArgs[1] >= startTime and (eventArgs[2] == type or not type) then
        args = eventArgs
      end
    end
    coroutine.yield()
  until args
  table.remove(args, 1)
  return args
end
return event