local raster = import("raster")
local ANSIColorPallete = import("halyde.core.termlib.lua").ANSIColorPalette

raster.drawPixel(4, 3, ANSIColorPallete["bright"][3])
raster.drawPixel(40, 34, nil, ANSIColorPallete["bright"][4])
raster.drawPixel(3, 3)