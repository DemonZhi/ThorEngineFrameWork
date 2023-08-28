local _key2index = {Id=1,Path=2}

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

---@type BezierCurveConfig[]
local _T=
{
    [1] = setmetatable({1,"Assets/Art/Effects/Skills/BezierCurves/curve1.prefab"}, _o),
    [2] = setmetatable({2,"Assets/Art/Effects/Skills/BezierCurves/curve2.prefab"}, _o),
    [3] = setmetatable({3,"Assets/Art/Effects/Skills/BezierCurves/curve3.prefab"}, _o),
    [4] = setmetatable({4,"Assets/Art/Effects/Skills/BezierCurves/curve4.prefab"}, _o),
    [5] = setmetatable({5,"Assets/Art/Effects/Skills/BezierCurves/curve5.prefab"}, _o),
    [6] = setmetatable({6,"Assets/Art/Effects/Skills/BezierCurves/curve6.prefab"}, _o),

}

return _T