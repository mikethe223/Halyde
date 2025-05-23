local computer = import("computer")
local event = {}

--local ocelot = component.proxy(component.list("ocelot")())
function event.pull(...)
  local args = {...}
  local evtype, timeout
  
  if #args == 0 then
    -- No arguments, wait for any event indefinitely
    evtype = nil
    timeout = nil
  elseif #args == 1 then
    -- If one argument is provided, it could be either the event type or timeout
    if type(args[1]) == "number" then
      -- It's a timeout
      evtype = nil
      timeout = args[1]
    else
      -- It's an event type
      evtype = args[1]
      timeout = nil
    end
  else
    -- Both event type and timeout provided
    evtype = args[1]
    timeout = args[2]
  end
  
  local startTime = computer.uptime()
  local result = {}
  
  repeat
    -- Check event queue for matching event
    for i = 1, #evmgr.eventQueue do
      if not evtype or evmgr.eventQueue[i][1] == evtype then
        -- Found matching event (or any event if no type specified)
        result = table.copy(evmgr.eventQueue[i])
        table.remove(evmgr.eventQueue, i)
        return table.unpack(result)
      end
    end
    
    -- Check if we've timed out
    if timeout and computer.uptime() >= startTime + timeout then
      return nil  -- Timed out, return nil
    end
    
    -- Yield to allow other processes to run and more events to be added
    coroutine.yield()
  until false  -- Loop until we find an event or timeout
end

return event
