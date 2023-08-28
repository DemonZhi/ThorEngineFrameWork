local _key2index = {ID=1,EffectID=2,TargetHangPoint=3}

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

---@type ChainAttackConfig[]
local _T=
{
    [1] = setmetatable({1,3001,"Chest_B_Root"}, _o),

}

return _T