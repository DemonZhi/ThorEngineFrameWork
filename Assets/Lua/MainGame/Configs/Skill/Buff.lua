local _key2index = {ID=1,Name=2,Desc=3,IconPath=4,EffectIds=5}

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

---@type BuffConfig[]
local _T=
{
    [201008] = setmetatable({201008,"Buff201008","stun","",nil}, _o),
    [201002] = setmetatable({201002,"Buff201002","stun2","",nil}, _o),
    [202003] = setmetatable({202003,"Buff202003","stun3","",nil}, _o),
    [200002] = setmetatable({200002,"Buff200002","stun2","",nil}, _o),
    [23570401] = setmetatable({23570401,"Caught23570401","caught1","",{80}}, _o),
    [1001] = setmetatable({1001,"Drag1001","Drag1","",nil}, _o),
    [1002] = setmetatable({1002,"Freeze204102","freeze","",nil}, _o),

}

return _T