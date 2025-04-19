local shellcfg = import("/halyde/config/shell.cfg")
import("termlib")
local event = import("event")

_G.shell = {}
_G.shell.workingDirectory = "/"

print("\n │\n │ ".._OSVERSION..'\n │ Welcome! Type "help" to get started.\n │\n ')
while true do
  coroutine.yield()
  -- print(shell.workingDirectory .. " >")
  print(shellcfg["prompt"]:format(shell.workingDirectory),false)
  -- termlib.cursorPosX = #(shell.workingDirectory .. " >  ")
  -- termlib.cursorPosY = termlib.cursorPosY - 1
  read()
  termlib.cursorPosX = 1
  print("no shell parser yet")
end
