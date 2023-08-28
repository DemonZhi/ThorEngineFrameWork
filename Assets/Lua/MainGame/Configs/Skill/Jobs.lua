local _key2index = {Id=1,Name=2,MaleModelID=3,FemaleModelID=4,SearchDistance=5}

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

---@type JobConfig[]
local _T=
{
    [1] = setmetatable({1,"小甜甜的刀",24,31,20}, _o),
    [2] = setmetatable({2,"小甜甜的枪",30,16,20}, _o),
    [3] = setmetatable({3,"萝莉",29,29,20}, _o),
    [4] = setmetatable({4,"萝莉",29,29,20}, _o),
    [5] = setmetatable({5,"萝莉",29,29,20}, _o),
    [6] = setmetatable({6,"老虎头",34,34,20}, _o),

}

return _T