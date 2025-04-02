local gpu = component.proxy(component.list("gpu")()) -- replace with component.gpu once implemented
local lineNumber = 1

function _G.print(text)
  local xRes, yRes = gpu.getResolution()
  if not text or not tostring(text) then
    return
  end
  local printText = tostring(text):gsub("\t", "  ")
  for line in printText:gmatch("([^\n]*)\n?") do
    while #line > xRes do
      gpu.set(1,lineNumber,line:sub(1,xRes))
      line = line:sub(xRes+1)
      lineNumber = lineNumber + 1
    end
    gpu.set(1,lineNumber,line)
    lineNumber = lineNumber + 1
  end
end

function _G.clear()
  local xRes, yRes = gpu.getResolution()
  gpu.fill(1,1,xRes,yRes," ")
  lineNumber = 1
end