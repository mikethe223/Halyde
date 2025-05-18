local component = require("component")
if not component.isAvailable("internet") then
  io.stderr.write("This program requires an internet card to run.")
  return
end
local internet = component.internet
local computer = require("computer")
local fs = require("filesystem")
local installLocation
local drives = {}
for drive in fs.list("/mnt/") do
  table.insert(drives, drive)
end
if #drives == 1 and not component.invoke(component.get(drives[1]:sub(1, 3), "filesystem"), "isReadOnly") then
  installLocation = drives[1]
elseif #drives == 1 then
  io.stderr.write("All drives are read-only.\nHalyde cannot be installed.")
else
  local installDrivesText = "Possible drives to install to:"
  for i = 1, #drives do
    local address = component.get(drives[i]:sub(1, 3), "filesystem")
    local fsComponent = component.proxy(address)
    if not fsComponent.isReadOnly() then
      local label = fsComponent.getLabel()
      if label then
        installDrivesText = installDrivesText .. "\n  " .. tostring(i) .. ". - " .. label .. "(" .. address:sub(1, 5) .. "...)"
      else
        installDrivesText = installDrivesText .. "\n  " .. tostring(i) .. ". - " .. address:sub(1, 5) .. "..."
      end
    end
  end
  io.write(installDrivesText .. "\nPlease select a drive by entering its number or \"q\" to quit. ")
  local answer
  while true do
    answer = io.read()
    if tonumber(answer) and tonumber(answer) >= 1 and tonumber(answer) <= #drives then
      break
    elseif answer == "q" then
      return
    else
      print("Answer invalid, try again.")
    end
  end
  installLocation = "/mnt/" .. drives[tonumber(answer)]
end
if not installLocation then
  print("All drives are read-only.\nHalyde cannot be installed.")
  return
end
io.write("Are you sure you would like to install Halyde to " .. installLocation .. "? This will erase all data on this disk. [Y/n] ")
if io.read():lower() == "n" then
  return
end

-- installation
local computer = require("computer")
local oldFiles = {}
for oldFile in fs.list(installLocation) do
  if oldFile ~= "home/" then
    table.insert(oldFiles, oldFile)
  end
end
local function getFile(url)
  local request, data, tmpdata = nil, "", nil
  local status, errorMessage = pcall(function()
    request = internet.request(url)
    request:finishConnect()
  end)
  if not status then
    return false, errorMessage
  end
  local responseCode = request:response()
  if responseCode and responseCode ~= 200 then
    return false, responseCode
  end
  repeat
    tmpdata = request.read(math.huge)
    data = data .. (tmpdata or "")
  until not tmpdata
  return data
end

local function getFile(path)
  if path:sub(1,1) == "/" then
    if not fs.exists(path) then
      return false, "file does not exist"
    end
    local handle, data, tmpdata = fs.open(path, "r"), "", nil
    repeat
      tmpdata = handle:read(math.huge)
      data = data .. (tmpdata or "")
    until not tmpdata
    handle:close()
    return data
  else
    local request, data, tmpdata = nil, "", nil
    local status, errorMessage = pcall(function()
      request = internet.request(path)
      request:finishConnect()
    end)
    if not status then
      return false, errorMessage
    end
    local responseCode = request:response()
    if responseCode and responseCode ~= 200 then
      return false, responseCode
    end
    repeat
      tmpdata = request.read(math.huge)
      data = data .. (tmpdata or "")
    until not tmpdata
    return data
  end
end
print("a")
local webInstallConfig = getFile("https://raw.githubusercontent.com/Team-Cerulean-Blue/Halyde/refs/heads/main/argentum.cfg")
print("a")
webInstallConfig = load(webInstallConfig)
print("a")
webInstallConfig = webInstallConfig()
print("a")
installationOrder = {"halyde", "edit", "argentum"}
for i = 1, 3 do
  local webInstallConfig = webInstallConfig[installationOrder[i]]
  print("a")
  if webInstallConfig.directories then
    for _, directory in pairs(webInstallConfig.directories) do
      print("Creating " .. directory .. "...")
      fs.makeDirectory(installLocation .. directory)
    end
  end
  for _, file in pairs(webInstallConfig.files) do
    print("Downloading " .. file .. "...")
    local handle = fs.open(installLocation .. file, "w")
    handle:write(getFile("https://raw.githubusercontent.com/Team-Cerulean-Blue/Halyde/refs/heads/main/" .. file))
    handle:close()
  end
end
computer.shutdown(true)
