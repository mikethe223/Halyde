function drawPixel(x, y, bg, fg)
    mergePixels(x, y, bg, fg)
end

function mergePixels(x, y, bg, fg)
    -- get original character for "merging"
    local original = gpu.get(x, y)[0]
    if bg ~= nil then gpu.setBackground(bg) end
    if fg ~= nil then gpu.setForeground(fg) end
    -- convert from braille to char code
    -- convert from 
    -- 1 4    1 2
    -- 2 5 -> 3 4
    -- 3 6    5 6
    -- 7 8    7 8 using complicate bit thingery
    -- bitwise or
    -- unconvert
    -- print the thing
end

function XY2Braille(x, y)
    return math.floor(x/2), math.floor(y/4)
end
function Braille2XY(x, y)
    return math.floor(x*2), math.floor(y*4)
end