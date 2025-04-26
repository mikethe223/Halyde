local event = import("event")
--local keyboard = import("keyboard")

local gpu = component.proxy(component.list("gpu")()) -- replace with component.gpu once implemented
_G.termlib = {}
termlib.cursorPosX = 1
termlib.cursorPosY = 1

local width, height = gpu.getResolution()
termlib.width = width
termlib.height = height

local ANSIColorPalette = {
  ["dark"] = {
    [0] = 0x000000,
    [1] = 0x800000,
    [2] = 0x008000,
    [3] = 0x808000,
    [4] = 0x000080,
    [5] = 0x800080,
    [6] = 0x008080,
    [7] = 0xC0C0C0
  },
  ["bright"] = {
    [0] = 0x808080,
    [1] = 0xFF0000,
    [2] = 0x00FF00,
    [3] = 0xFFFF00,
    [4] = 0x0000FF,
    [5] = 0xFF00FF,
    [6] = 0x00FFFF,
    [7] = 0xFFFFFF
  }
}

defaultForegroundColor = ANSIColorPalette["bright"][7]
defaultBackgroundColor = ANSIColorPalette["dark"][0]

gpu.setForeground(defaultForegroundColor)
gpu.setBackground(defaultBackgroundColor)

local function scrollDown()
  if gpu.copy(0,1,width,height,0,-1) then
    gpu.set(1,height,string.rep(" ",width))
    termlib.cursorPosY=height
  end
end

local function newLine()
  termlib.cursorPosX=1
  termlib.cursorPosY = termlib.cursorPosY + 1
  if termlib.cursorPosY>height then
    scrollDown()
  end
end

function parseCodeNumbers(code)
  o = {}
  for num in code:sub(3,-2):gmatch("[^;]+") do
    table.insert(o,tonumber(num))
  end
  return o
end

function _G.print(text,endNewLine)

  -- you don't know how tiring this was just for ANSI escape code support

  if endNewLine==nil then
    endNewLine = true
  end

  if not text or not tostring(text) then
    return
  end
  text = tostring(text)
  readBreak = 0
  -- readBreak is for when, inside the for loop, there normally would have been an increase in the "i" variable because it has read more than one character.
  -- unfortunately, changing the "i" variable would have unpredictable effects, so to not risk anything, this workaround was done.
  section = ""

  function printSection()
    if #section==0 then
      return
    end
    gpu.set(termlib.cursorPosX,termlib.cursorPosY,section)
    termlib.cursorPosX = termlib.cursorPosX+unicode.wlen(section)
    if termlib.cursorPosX>width then
      newLine()
    end
    section=""
  end

  for i=1,#text do
    if readBreak>0 then
      readBreak = readBreak - 1
      goto continue
    end

    if string.byte(text,i)==10 then
      printSection()
      newLine()
    elseif string.byte(text,i)==13 then
      printSection()
      termlib.cursorPosX=1
    elseif string.byte(text,i)==0x1b and i<=#text-2 then
      printSection()
      --ocelot.log("0x1b char detected")
      codeType = string.sub(text,i+1,i+1)
      if codeType=="[" then
        -- Control Sequence Introducer
        --ocelot.log("Control Sequence Introducer")
        codeEndIdx = string.find(text,"m",i)
        code = string.sub(text,i,codeEndIdx)
        --ocelot.log("Code: "..code.." ("..i..", "..codeEndIdx..")")
        readBreak = readBreak + #code - 1
        nums = parseCodeNumbers(code)
        codeEnd = code:sub(-1)
        --ocelot.log("Code end: "..codeEnd..", "..#codeEnd)
        if codeEnd == "m" then
          -- Select Graphic Rendition
          --ocelot.log("Select Graphic Rendition, ID "..nums[1])
          if nums[1]>=30 and nums[1]<=37 then
            gpu.setForeground(ANSIColorPalette["dark"][nums[1]%10])
          end
          if nums[1]==39 or nums[1]==0 then
            gpu.setForeground(defaultForegroundColor)
          end
          if nums[1]>=40 and nums[1]<=47 then
            gpu.setBackground(ANSIColorPalette["dark"][nums[1]%10])
          end
          if nums[1]==49 or nums[1]==0 then
            gpu.setBackground(defaultBackgroundColor)
          end
          if nums[1]>=90 and nums[1]<=97 then
            gpu.setForeground(ANSIColorPalette["bright"][nums[1]%10])
          end
          if nums[1]>=100 and nums[1]<=107 then
            gpu.setBackground(ANSIColorPalette["bright"][nums[1]%10])
          end
        end
      end
    else
      --gpu.set(termlib.cursorPosX,termlib.cursorPosY,string.sub(text,i,i))
      section = section..string.sub(text,i,i)
    end
    ::continue::
  end
  printSection()
  if endNewLine then
    newLine()
  end
end

function _G.clear()
  local xRes, yRes = gpu.getResolution()
  gpu.fill(1,1,xRes,yRes," ")
  termlib.cursorPosX, termlib.cursorPosY = 1, 1
end

function _G.read()
  local curtext = ""
  local cursorPosX, cursorPosY = termlib.cursorPosX, termlib.cursorPosY
  local cursorWhite = true
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
          termlib.cursorPosX, termlib.cursorPosY = cursorPosX, cursorPosY
          print(curtext.." ", false)
        elseif key == "enter" then
          termlib.cursorPosX, termlib.cursorPosY = cursorPosX, cursorPosY
          print(curtext)
          return curtext
        end
      end
      termlib.cursorPosX, termlib.cursorPosY = cursorPosX, cursorPosY
      print(curtext, false)
    else
      cursorWhite = not cursorWhite
    end
  end
end
