local _key2index = {Id=1,EffectId=2}

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

---@type FootPrintEffectConfig[]
local _T=
{
    [1] = setmetatable({1,2008}, _o),
    [2] = setmetatable({2,2009}, _o),
    [3] = setmetatable({3,2010}, _o),
    [4] = setmetatable({4,2010}, _o),
    [5] = setmetatable({5,2010}, _o),
    [6] = setmetatable({6,2010}, _o),
    [7] = setmetatable({7,2010}, _o),
    [8] = setmetatable({8,2011}, _o),
    [9] = setmetatable({9,2012}, _o),
    [10] = setmetatable({10,2013}, _o),

}

return _T