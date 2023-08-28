local _key2index = {ID=1,LinerenderPath=2}

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

---@type CampConfig[]
local _T=
{
    [4] = setmetatable({4,"Assets/Art/Effects/common/line/line.prefab"}, _o),
    [5] = setmetatable({5,"Assets/Art/Effects/common/line/line.prefab"}, _o),

}

return _T