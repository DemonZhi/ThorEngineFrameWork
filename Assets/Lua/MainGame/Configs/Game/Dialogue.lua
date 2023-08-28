local _key2index = {Id=1,Content=2}

local _o = 
{
    __index = function(myTable, key)
        local temp = _key2index[key]
        if temp == nil then
            --error("don't have the key in the table, key = "..key)
            return nil
        end
        return myTable[temp]
    end,
    __newindex = function(myTable, key, value)
        error("can't modify read-only table!")
    end
}

---@type DialogueConfig[]
local _T=
{
    [1] = setmetatable({1,"死吧！！虫子！！"}, _o),
    [2] = setmetatable({2,"锤他！锤他！"}, _o),
    [3] = setmetatable({3,"You Are Not Prepared！"}, _o),
    [4] = setmetatable({4,"Run!Little one，RUN！！！"}, _o),
    [5] = setmetatable({5,"Die!!"}, _o),

}

return _T