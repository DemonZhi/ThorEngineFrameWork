local _key2index = {ID=1,Stages=2,Effects=3,MountPoint=4,EndEffects=5}

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

---@type MissileConfig[]
local _T=
{
    [1] = setmetatable({1,{1},{2},"Weapon",nil}, _o),
    [2] = setmetatable({2,{2,1},{2},"",nil}, _o),
    [3] = setmetatable({3,{3,1},{2},"",nil}, _o),
    [4] = setmetatable({4,{4,1},{2},"",nil}, _o),
    [5] = setmetatable({5,{5,1},{2},"",nil}, _o),
    [6] = setmetatable({6,{6,1},{2},"",nil}, _o),
    [7] = setmetatable({7,{7,1},{2},"",nil}, _o),

}

return _T