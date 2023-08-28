local _key2index = {Id=1,Radius=2,LODDistance=3,CenterOffset=4,Prefab=5}

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

---@type InstancingModelInfoConfig[]
local _T=
{
    ["pre_trigger_test01"] = setmetatable({"pre_trigger_test01",4,{50.0,200.0},{0,2.25,0},"pre_trigger_test01_collider"}, _o),

}

return _T