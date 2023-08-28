local _key2index = {Id=1,Value=2}

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

---@type GameSettings[]
local _T=
{
    ["RoleOffBattleTime"] = setmetatable({"RoleOffBattleTime","2"}, _o),
    ["CheckModelVisibileTime"] = setmetatable({"CheckModelVisibileTime","0.3"}, _o),
    ["CheckShadowVisibileTime"] = setmetatable({"CheckShadowVisibileTime","1"}, _o),
    ["EnterCloseupZoomScale"] = setmetatable({"EnterCloseupZoomScale","0.4"}, _o),
    ["ExitCloseupZoomScale"] = setmetatable({"ExitCloseupZoomScale","0.95"}, _o),
    ["CloseupMotorMinZoomScale"] = setmetatable({"CloseupMotorMinZoomScale","0.56"}, _o),
    ["CloseupMotorMaxZoomScale"] = setmetatable({"CloseupMotorMaxZoomScale","1"}, _o),
    ["CloseupInitZoomScale"] = setmetatable({"CloseupInitZoomScale","0.85"}, _o),
    ["LookAtTargetDistance"] = setmetatable({"LookAtTargetDistance","4.5"}, _o),
    ["LookAtTargetSpeed"] = setmetatable({"LookAtTargetSpeed","5"}, _o),
    ["LookForwardSpeed"] = setmetatable({"LookForwardSpeed","0.5"}, _o),
    ["RoleWetness"] = setmetatable({"RoleWetness","1"}, _o),
    ["RoleWetFadeinTime"] = setmetatable({"RoleWetFadeinTime","3"}, _o),
    ["RoleWetFadeoutTime"] = setmetatable({"RoleWetFadeoutTime","5"}, _o),

}

return _T