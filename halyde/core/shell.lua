import("termlib")
local event = import("event")

--local ocelot = component.proxy(component.list("ocelot")())

print("\n │\n │ ".._OSVERSION..'\n │ Welcome! Type "help" to get started.\n │')
while true do
  coroutine.yield()
  read()
  --ocelot.log(tostring(args[1]))
end