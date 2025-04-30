local raster = {util = {}}

local ocelot = component.proxy(component.list("ocelot")())
local gpu = component.proxy(component.list("gpu")())

function raster.drawPixel(x, y, bg, fg)
    -- get original character for "merging"
    local char, fg, bg = gpu.get(x, y) -- thx wah
    if bg ~= nil then gpu.setBackground(bg) end
    if fg ~= nil then gpu.setForeground(fg) end
    -- convert from braille to char code
    -- bitwise or
    -- print the thing
    -- i do NOT need to convert the thing.
    ocelot.log(char)
    char = utf8.codepoint(char)
    if char < 0x2800 or char > 0x28ff then -- check if char is not a braille character
        char = 0 -- yes
    end
    -- now i just need to print the character + the new character but i forgot how to do it plus its late gn
    ocelot.log(char)
end

return raster