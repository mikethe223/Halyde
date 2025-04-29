function drawPixel(x, y, bg, fg)
    mergePixels(x, y, bg, fg)
end

function mergePixels(x, y, bg, fg)
    -- get original character for "merging"
    local original = gpu.get(x, y)[0]
    if bg ~= nil then gpu.setBackground(bg) end
    if fg ~= nil then gpu.setForeground(fg) end
    
end

function XY2Braille(x, y)
    return math.floor(x/2), math.floor(y/4)
end