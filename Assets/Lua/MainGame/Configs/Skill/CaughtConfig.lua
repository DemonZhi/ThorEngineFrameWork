local _key2index = {ID=1,AniName=2,MountPoint=3,PositionOffset=4,RotationOffset=5}

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

---@type CaughtConfig[]
local _T=
{
    [1] = setmetatable({1,"stun","Bip001 R Hand",{-0.4,0.6,-0.61},{-30.79,55.99,142.8}}, _o),

}

return _T