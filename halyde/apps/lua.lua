print("\27[44m".._VERSION.."\27[0m shell")
print('Type "exit" to exit.')
while true do
  print("\27[44mlua>\27[0m ", false)
  local command = read()
  if command == "exit" then
    return
  else
    local function runCommand()
      assert(load(command))()
    end
    local result, reason = xpcall(runCommand, function(errMsg)
      return errMsg .. "\n\n" .. debug.traceback()
    end)
    if not result then
      print("\27[91m" .. reason)
    end
  end
end
