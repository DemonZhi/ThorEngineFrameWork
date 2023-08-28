local _key2index = {ID=1,Type=2,MaxTime=3,Speed=4,TurnSpeed=5,CurveID=6,TracePoint=7,IsFinishContinue=8}

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

---@type MissileStageConfig[]
local _T=
{
    [1] = setmetatable({1,2,5000,50,6750,0,"",false}, _o),
    [2] = setmetatable({2,1,3000,1.9,675,1,"",false}, _o),
    [3] = setmetatable({3,1,3000,0.9,675,2,"",false}, _o),
    [4] = setmetatable({4,1,3000,1.5,675,3,"",false}, _o),
    [5] = setmetatable({5,1,3000,0.5,675,4,"",false}, _o),
    [6] = setmetatable({6,1,3000,2,675,5,"",false}, _o),
    [7] = setmetatable({7,1,3000,0.4,675,6,"",false}, _o),

}

return _T