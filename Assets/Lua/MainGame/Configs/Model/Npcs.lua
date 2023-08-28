local _key2index = {Id=1,ModelID=2}

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

---@type Npcs[]
local _T=
{
    [1] = setmetatable({1,39}, _o),
    [2] = setmetatable({2,35}, _o),

}

return _T