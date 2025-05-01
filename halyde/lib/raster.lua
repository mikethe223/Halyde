local raster = {}

local ocelot = component.proxy(component.list("ocelot")())
local gpu = component.proxy(component.list("gpu")())

function raster.drawPixel(x, y, newbg, newfg)
    -- get original character for "merging"
    local char, fg, bg = gpu.get(x, y) -- thx wah
    ocelot.log(char)
    char = string.byte(char) -- convert from char to char code
    ocelot.log(tostring(char))
    if char < 0x2800 or char > 0x28ff then -- check if char is not a braille character
        char = 0 -- yes
    end
    ocelot.log(tostring(char))
    local newi = (x%2)+(y%4)*2 -- original unmodified location in the char
    if x%2==1 and (newi>1 and newi<6) then -- modify it
        newi = newi+1 -- trust me bro this works
    elseif x%2==0 and (newi>1 and newi<6) then
        newi = newi-1
    end
    ocelot.log(tostring(newi))
    newchar = char|(1<<newi) -- boom and its combined
    ocelot.log(tostring(newchar))
    -- termlib.cursorPosX = math.floor(x/2) -- math.floor() for good measure
    -- termlib.cursorPosY = math.floor(y/4)
    if newbg == nil then gpu.setBackground(bg) else gpu.setBackground(newbg) end
    if newfg == nil then gpu.setForeground(fg) else gpu.setForeground(newfg) end
    print(string.byte(newchar), false, false)
    -- print it without newline or wrapping 
    -- (in case someone wants to draw a pixel off-screen. why would you do that?)
end

return raster