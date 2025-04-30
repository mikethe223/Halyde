function drawPixel(x, y, bg, fg)
    -- get original character for "merging"
    local char = gpu.get(x, y)[0]
    if bg ~= nil then gpu.setBackground(bg) end
    if fg ~= nil then gpu.setForeground(fg) end
    -- convert from braille to char code
    -- convert from 
    -- 1 4    1 2
    -- 2 5 -> 3 4
    -- 3 6    5 6
    -- 7 8    7 8 using complicate bit thingery
    -- example would be 171 should be converted to 157
    -- or a more simple one: 16 to 4
    -- bitwise or
    -- unconvert
    -- print the thing
    char = string.byte(char)
    ocelot.log(char)
    char = formByte({getBit(char, 0), getBit(char, 2), getBit(char, 4), getBit(char, 1), getBit(char, 3), getBit(char, 5), getBit(char, 6), getBit(char, 7)})
    ocelot.log(char)
end

function XY2Braille(x, y)
    return math.floor(x/2), math.floor(y/4)
end
function Braille2XY(x, y)
    return math.floor(x*2), math.floor(y*4)
end
function getBit(a, which) 
    return 1 == ((a >> which) & 1);
end
function formByte(a)
    local x = 0
    for i = 1, 8 do
        x = x+(a[i]<<i)
    end
    return x
end