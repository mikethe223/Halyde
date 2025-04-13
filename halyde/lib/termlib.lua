local event = import("event")
--local keyboard = import("keyboard")

local gpu = component.proxy(component.list("gpu")()) -- replace with component.gpu once implemented
local ocelot = component.proxy(component.list("ocelot")())
_G.termlib = {}
termlib.nextPosX, termlib.nextPosY = 1, 1

function _G.print(text)
  local xRes, yRes = gpu.getResolution()
  if not text or not tostring(text) then
    return
  end
  local printText = tostring(text):gsub("\t", "  ")
  for line in printText:gmatch("([^\n]*)\n?") do
    while #line > xRes do
      gpu.set(termlib.nextPosX, termlib.nextPosY, line:sub(1,xRes))
      line = line:sub(xRes+1)
      termlib.nextPosY = termlib.nextPosY + 1
      termlib.nextPosX = 1
    end
    gpu.set(termlib.nextPosX, termlib.nextPosY, line)
    termlib.nextPosY = termlib.nextPosY + 1
  end
end

function _G.clear()
  local xRes, yRes = gpu.getResolution()
  gpu.fill(1,1,xRes,yRes," ")
  termlib.nextPosX, termlib.nextPosY = 1, 1
end

function _G.read()
  local curtext = ""
  local nextPosX, nextPosY = termlib.nextPosX, termlib.nextPosY
  while true do
    local args = {event.pull("key_down", 0.5)}
    if args[4] then
      local keycode = args[4]
      local key = keyboard.keys[keycode]
      if args[3] >= 32 and args[3] <= 126 then
        curtext = curtext .. (unicode.char(args[3]) or "")
      else
        if key == "back" then
          curtext = curtext:sub(1, #curtext-1)
          termlib.nextPosX, termlib.nextPosY = nextPosX, nextPosY
          print(curtext.." ")
        elseif key == "enter" then
          return curtext
        end
      end
      termlib.nextPosX, termlib.nextPosY = nextPosX, nextPosY
      print(curtext)
    end
  end
end