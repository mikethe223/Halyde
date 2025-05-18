local args = {...}
local directory = args[1]
args = nil
local fs = import("filesystem")

if not directory then
  shell.run("help mkdir")
  return
end
if directory:sub(1, 1) ~= "/" then
  directory = shell.workingDirectory .. directory
end
if fs.exists(file) then
  print("\27[91mAn object already exists at the specified path.")
end
fs.makeDirectory(file)
