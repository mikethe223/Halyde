import("termlib")
local event = import("event")

_G.shell = {}
_G.shell.workingDirectory = "/"

print("\n │\n │ ".._OSVERSION..'\n │ Welcome! Type "help" to get started.\n │\n ')
while true do
  coroutine.yield()
  print(shell.workingDirectory .. " >")
  termlib.nextPosX = #(shell.workingDirectory .. " >  ")
  termlib.nextPosY = termlib.nextPosY - 1
  read()
  termlib.nextPosX = 1
  print("no shell parser yet")
end