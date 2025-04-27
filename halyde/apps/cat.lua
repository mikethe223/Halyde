local args = {...}
local file = args[1]
args = nil
local fs = import("filesystem")
if not file then
  shell.run("help cat")
  return
end
if file:sub(1, 1) ~= "/" then
  file = shell.workingDirectory .. file
end
if not fs.exists(file) then
  print("\27[91mFile does not exist.")
end
local handle = fs.open(file, "r")
local data
repeat
  data = handle:read(math.huge or math.maxinteger)
  print(data, false)
until not data
