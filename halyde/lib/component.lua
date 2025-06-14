local componentlib
if table.copy then
  componentlib = table.copy(component)
else
  componentlib = {}
end

function componentlib.get(address)
  checkArg(1, address, "string")
  assert(#address >= 3, "abbreviated address must be at least 3 characters long")
  local components = component.list()
  for currentAddress, name in pairs(components) do
    if currentAddress:find("^" .. address) then
      return(currentAddress)
    end
  end
  return nil, "full address not found"
end

componentlib.invoke = component.invoke

return componentlib
