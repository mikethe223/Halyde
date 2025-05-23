local shellcfg = import("/halyde/config/shell.cfg")
import("/halyde/core/termlib.lua")
local event = import("event")
local filesystem = import("filesystem")
local component = import("component")
local gpu = component.proxy(component.list("gpu")())

_G.shell = {}
_G.shell.workingDirectory = shellcfg["defaultWorkingDirectory"]
_G.shell.aliases = shellcfg["aliases"]

local function runAsCoroutine(path, ...)
  --ocelot.log("running " .. path .. " as coroutine")
  cormgr.loadCoroutine(path, ...)
  local corIndex = #cormgr.corList
  local cor = cormgr.corList[#cormgr.corList]
  repeat
    coroutine.yield()
  until cormgr.corList[corIndex] ~= cor
end

function _G.shell.run(command)
  checkArg(1, command, "string")
  if shell.aliases[command:match("[^ ]+")] then
    local _, cmdend = command:find("[^ ]+")
    command = shell.aliases[command:match("[^ ]+")] .. command:sub(cmdend + 1)
  end
  local gm, result, args, trimmedCommand = command:gmatch("[^ ]+"), nil, {}, command
  while true do
    result = gm()
    if not result then
      break
    end
    if result:find('"') then
      local location = trimmedCommand:find('"')
      local argBefore = result:sub(1, result:find('"') - 1) -- edge case where there is no space before the quote, get the argument there
      if argBefore and argBefore ~= "" then
        table.insert(args, argBefore)
      end
      trimmedCommand = trimmedCommand:sub(location + 1)
      if trimmedCommand:find('"') then
        table.insert(args, trimmedCommand:sub(1, trimmedCommand:find('"') - 1))
        trimmedCommand = trimmedCommand:sub(trimmedCommand:find('"') + 1)
        gm = trimmedCommand:gmatch('[^ ]+')
      else
        print("\27[91mmalformed shell command")
        return
      end
    else
      table.insert(args, result)
    end
  end
  -- execute the program
  local foundfile = false
  if not args[1] then
    return
  end
  if filesystem.exists(args[1]) and not filesystem.isDirectory(args[1]) then
    foundfile = true
    local path = args[1]
    table.remove(args, 1)
    runAsCoroutine(path, table.unpack(args))
  else
    for _, item in pairs(shellcfg["path"]) do
      if filesystem.exists(item..args[1]) and not filesystem.isDirectory(item .. args[1]) then
        foundfile = true
        local path = item..args[1]
        table.remove(args, 1)
        runAsCoroutine(path, table.unpack(args))
        break
      else -- try to look for it without the file extension
        local files = filesystem.list(item)
        for _, file in pairs(files) do
          if args[1] == file:match("(.+)%.[^%.]+$") and not filesystem.isDirectory(item .. file) then
            foundfile = true
            table.remove(args, 1)
            runAsCoroutine(item .. file, table.unpack(args))
            break
          end
        end
      end
    end
  end
  if not foundfile then
    print("No such file or command: "..args[1])
  end
end

print(shellcfg["startupMessage"]:format(shellcfg.splashMessages[math.random(1, #shellcfg.splashMessages)]))
while true do
  coroutine.yield()
  -- print(shell.workingDirectory .. " >")
  --print(shellcfg["prompt"]:format(shell.workingDirectory),false)
  -- termlib.cursorPosX = #(shell.workingDirectory .. " >  ")
  -- termlib.cursorPosY = termlib.cursorPosY - 1
  local shellCommand = read("shell", shellcfg.prompt:format(shell.workingDirectory))
  shell.run(shellCommand)
  gpu.freeAllBuffers()
end
