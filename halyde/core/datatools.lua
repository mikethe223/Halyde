function table.find(table, item)
  for k, v in pairs(table) do
    if v == item then
      return(v)
    end
  end
end