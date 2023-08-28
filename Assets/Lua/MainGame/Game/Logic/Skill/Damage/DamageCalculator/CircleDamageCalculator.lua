---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/9/16 10:29
---
local RoleDamageCalculator = require("MainGame/Game/Logic/Skill/Damage/DamageCalculator/RoleDamageCalculator")
local CircleDamageCalculator = class("CircleDamageCalculator", RoleDamageCalculator)
local StringUtil = require("Engine/Common/Utilities/StringUtil")
function CircleDamageCalculator:Ctor()
    CircleDamageCalculator.__super.Ctor(self)
    self.m_Center = Vector3.zero
    self.m_Radius = 0
end

function CircleDamageCalculator:ParseConfigData(data)
    local dataList = string.split(data,';')
    self.m_Radius = tonumberWithDefault(string.GetValueByIndex(dataList, 1, ""), 10, 0)
    self.m_Center = StringUtil.String2Vector3(string.GetValueByIndex(dataList, 2, ""),',')
end

function CircleDamageCalculator:IsWithin(attackObject, targetObject)
    local centerPos = attackObject:GetPosition()
    local rotation = attackObject:GetRotation()
    local targetPos = targetObject:GetPosition()
    local relativePos = targetPos - (centerPos + rotation * self.m_Center)
    local x = relativePos.x
    local z = relativePos.z
    local r = self.m_Radius
    if x * x + z * z <= r * r  then
        return true
    end
    return false
end


return CircleDamageCalculator