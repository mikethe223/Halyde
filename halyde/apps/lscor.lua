print("\27[93m"..tostring(#cormgr.corList).."\27[0m coroutines active")
for i=1, #cormgr.corList do
    if i==#cormgr.corList then
        print("\27[93m└ "..i.."\27[0m - "..cormgr.labelList[i].." \27[0m")
    else
        print("\27[93m├ "..i.."\27[0m - "..cormgr.labelList[i].." \27[0m")
    end

end
