local args = {...}
local fromFile, toFile = args[1], args[2]
args = nil
local fs = import("filesystem")

if fromFile:sub(1, 1) ~= "/" then
  fromFile = shell.workingDirectory .. fromFile
end
if toFile:sub(1, 1) ~= "/" then
  toFile = shell.workingDirectory .. toFile
end
if fromFile == toFile then
  print("\27[91mSource and destination are the same.")
end
if not fs.exists(fromFile) then
  print("\27[91mSource file does not exist.")
end
if fs.exists(toFile) then
  print("Destination file already exists. Overwrite it? [Y/n] ", false)
  if read():lower() == "n" then
    print("Aborted.")
    return
  end
end
fs.rename(fromFile, toFile)
