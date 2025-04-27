local args = {...}
local directory = args[1]
args = nil
local fs = import("filesystem")

if directory == ".." then
  local backDirectory = shell.workingDirectory:match("(.+)/.-/")
  if backDirectory then
    backDirectory = backDirectory .. "/"
  else
    backDirectory = "/"
  end
  shell.workingDirectory = backDirectory
else
  if directory:sub(-1, -1) ~= "/" then
    directory = directory .. "/"
  end
  if directory:sub(1, 1) ~= "/" then
    directory = shell.workingDirectory .. directory
  end
  if fs.exists(directory) and fs.isDirectory(directory) or fs.exists(shell.workingDirectory .. directory) and fs.isDirectory(shell.workingDirectory .. directory) then
    shell.workingDirectory = directory
  else
    print("error: no such directory")
  end
end
