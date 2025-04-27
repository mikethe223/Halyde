local args = {...}
local file = args[1]
args = nil
local fs = import("filesystem")

if not file then
  shell.run("help rm")
  return
end
if file:sub(1, 1) ~= "/" then
  file = shell.workingDirectory .. file
end
if not fs.exists(file) then
  print("\27[91mFile does not exist.")
end
fs.remove(file)
