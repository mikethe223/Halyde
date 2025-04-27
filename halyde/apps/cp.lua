local args = {...}
local fromFile, toFile = args[1], args[2]
args = nil
local fs = import("filesystem")

if not fromFile or not toFile then
  shell.run("help cp")
  return
end
if fromFile:sub(1, 1) ~= "/" then
  fromFile = shell.workingDirectory .. fromFile
end
if toFile:sub(1, 1) ~= "/" then
  toFile = shell.workingDirectory .. toFile
end
if fromFile == toFile then
  print("\27[91mSource and destination are the same.")
  return
end
if not fs.exists(fromFile) then
  print("\27[91mSource file does not exist.")
  return
end
if fs.exists(toFile) and not (table.find(args, "-o") or table.find(args, "--overwrite")) then
  print("\27[91mDestination file already exists. Run this command again with -o to overwrite it.")
  return
end
fs.copy(fromFile, toFile)
