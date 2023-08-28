---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/9/16 10:29
---

local RoleDamageCalculator = require("MainGame/Game/Logic/Skill/Damage/DamageCalculator/RoleDamageCalculator")
local SectorDamageCalculator = class("SectorDamageCalculator", RoleDamageCalculator)
local StringUtil = require("Engine/Common/Utilities/StringUtil")
local GeometryUtil = require("Engine/Common/Utilities/GeometryUtil")

function SectorDamageCalculator:ParseConfigData(data)
    local dataList = string.split(data, ";")
    self.m_Radius = tonumberWithDefault(string.GetValueByIndex(dataList, 1, ""), nil,0)
    self.m_Degree = tonumberWithDefault(string.GetValueByIndex(dataList, 2, ""), nil,0)
    self.m_Center = StringUtil.String2Vector3(string.GetValueByIndex(dataList, 3, ""), ",")
end

function SectorDamageCalculator:IsWithin(attackObject, targetObject)
    local centerPos = attackObject:GetPosition()
    local forward = attackObject:GetTransform().forward
    local targetPos = targetObject:GetPosition()
    local rotation = attackObject:GetRotation()
    local relativePos = targetPos - (centerPos + rotation * self.m_Center)
    local x = relativePos.x
    local z = relativePos.z
    local r = self.m_Radius
    if (x * x + z * z) <= r * r then
        if (math.abs(Vector3.Angle(forward, relativePos)) <= self.m_Degree / 2) then
            return true;
        end
    end
    return false;
end

return SectorDamageCalculator