local _key2index = {Id=1,EntityType=2,Radious=3,Count=4}

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

---@type ShadowVisbile[]
local _T=
{
    [0] = setmetatable({0,1,50,500}, _o),

}

return _T