local _key2index = {Id=1,ModelID=2,MoveSpeed=3,TurnSpeed=4,DeadType=5,DeadDissolveType=6,SkillList=7,WaveStrength=8}

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

---@type MonsterConfig[]
local _T=
{
    [1] = setmetatable({1,1,6,450,1,0,{100101,100102,100103},-20}, _o),
    [2] = setmetatable({2,5,6,450,1,0,{200401},-20}, _o),
    [3] = setmetatable({3,6,6,450,1,0,{200301},-20}, _o),
    [4] = setmetatable({4,21,6,450,1,0,{200501},-20}, _o),
    [5] = setmetatable({5,22,6,450,1,0,{200601,200602},-20}, _o),
    [6] = setmetatable({6,25,6,450,1,0,{40101,40102,40103,40104,40107,40108,40109},-20}, _o),
    [7] = setmetatable({7,26,6,450,1,0,{500101,500102,500103,500104,500201,500301,500401},-20}, _o),
    [8] = setmetatable({8,27,6,450,0,-1,{600101},-20}, _o),
    [9] = setmetatable({9,27,6,450,0,-1,{600102},-20}, _o),
    [10] = setmetatable({10,32,6,450,0,-1,{320201},-20}, _o),
    [11] = setmetatable({11,33,6,450,0,-1,{320601},-20}, _o),
    [4001] = setmetatable({4001,35,3,450,1,0,nil,-20}, _o),
    [4002] = setmetatable({4002,35,3,450,1,0,nil,-20}, _o),
    [2312] = setmetatable({2312,40,6,450,0,-1,nil,-20}, _o),
    [2313] = setmetatable({2313,40,6,450,0,-1,nil,-20}, _o),
    [4003] = setmetatable({4003,35,3,450,1,0,nil,-20}, _o),
    [4004] = setmetatable({4004,35,3,450,1,0,nil,-20}, _o),

}

return _T