local _key2index = {ID=1,EffectList=2}

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

---@type MagicAreaConfig[]
local _T=
{
    [2020031] = setmetatable({2020031,nil}, _o),
    [2000031] = setmetatable({2000031,{171}}, _o),
    [100] = setmetatable({100,{172}}, _o),
    [101] = setmetatable({101,nil}, _o),

}

return _T