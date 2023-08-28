---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/10/28 10:29
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentAttribute = class("ComponentAttribute", ComponentBase)
ComponentAttribute.m_ComponentId = ComponentDefine.ComponentType.k_ComponentAttribute
---这里存放的属性都是标准属性，如moveSpeed就是正常人物的移动速度，如果需要加减速的Debuff，可以再加一个Factor
---然后GetAttribute不直接返回value，而返回一个Function的return，这个function内部可以使用各种value进行计算
function ComponentAttribute:Init(object)
    ComponentAttribute.__super.Init(self, object)
    self.m_AttributeMap = {}
    self.m_ExtendAttributeMap = {}
    self.m_AttrFuncMap = {}
end

function ComponentAttribute:DeserializePlayerAttr(buffer)
    local server_id_ = buffer:ReadInt()
    local player_id_ = buffer:ReadInt()
    self.m_Owner.m_ObjectName = buffer:ReadString()

    self.m_JobId = buffer:ReadUByte()
    self.m_Gender = buffer:ReadUByte()
    local head_icon_id_ = buffer:ReadUInt()
    local avatar_id_ = buffer:ReadInt()
    local total_gs = buffer:ReadInt()
    local max_gs = buffer:ReadInt()
    local is_in_fight_ = buffer:ReadUByte() == 1
    local powerpoint = buffer:ReadInt()
    local max_powerpoint = buffer:ReadInt()
end

function ComponentAttribute:DeserializeHeroAttr(buffer)
    local exp1 = buffer:ReadInt()
    local exp2 = buffer:ReadInt()
    local gold = buffer:ReadInt()
    local bind_gold = buffer:ReadInt()
    local bind_diamond = buffer:ReadInt()
    local non_bind_diamond = buffer:ReadInt()
    local energy = buffer:ReadInt()
    local silver = buffer:ReadInt()
end

function ComponentAttribute:DeserializeExtendParam(buffer)
    local count = buffer:ReadInt()
    for i = 1, count do
        local key = buffer:ReadInt()
        local val = buffer:ReadInt()
    end
end

function ComponentAttribute:DeserializePropPoint(netBuffer)
    local total_point_ = netBuffer:ReadInt()
    local wash_cnt_ = netBuffer:ReadInt()
    local select_scheme_ = netBuffer:ReadUByte()
    local scheme_cnt = netBuffer:ReadUByte()
    for i = 1, scheme_cnt do
        for j = 1, 6 do
            local point = netBuffer:ReadInt()
        end
    end
end

function ComponentAttribute:SetAttributeByMap(attribute)
    for i, v in pairs(attribute) do
        self.m_AttributeMap[i] = v
    end
end

function ComponentAttribute:SetAttribute(attributeDefine, newValue)
    if self.m_AttributeMap == nil then
        return
    end

    local oldValue = self.m_AttributeMap[attributeDefine]
    if oldValue == newValue then
        return
    end
    self.m_AttributeMap[attributeDefine] = newValue
    --Logger.LogInfo("SetAttr: %s, old:%s, new:%s", attributeDefine, oldValue, newValue)
    if oldValue ~= nil then
        self:InvokeAttrChangeFunc(attributeDefine, oldValue, newValue)
    end
end

function ComponentAttribute:SetExtendAttribute(attributeDefine, value)
    if self.m_ExtendAttributeMap == nil then
        return
    end

    self.m_ExtendAttributeMap[attributeDefine] = value
end

function ComponentAttribute:GetAttribute(attributeDefine)
    if self.m_AttributeMap == nil then
        return nil
    end
    return self.m_AttributeMap[attributeDefine]
end

function ComponentAttribute:GetAttribute(attributeDefine)
    if self.m_AttributeMap == nil then
        return nil
    end
    return self.m_AttributeMap[attributeDefine]
end

function ComponentAttribute:ClearAllAttribute()
    self.m_AttributeMap = {}
end

function ComponentAttribute:Destroy()
    self:ClearAllAttribute()
    self.m_AttributeMap = nil
    ComponentAttribute.__super.Destroy(self)
end

function ComponentAttribute:GetMoveSpeed()
    return self:GetAttribute(ComponentDefine.AttributeDefine.k_MoveSpeed)
end

function ComponentAttribute:GetRotateSpeed()
    return self:GetAttribute(ComponentDefine.AttributeDefine.k_RotateSpeed)
end

function ComponentAttribute:GetJobID()
    return self.m_JobId or 0
end

function ComponentAttribute:GetGender()
    return self.m_Gender or 0
end

function ComponentAttribute:RegisterAttrChangeFunc(index, func)
    local funcMap = self.m_AttrFuncMap[index]
    if not funcMap then
        funcMap = {}
        self.m_AttrFuncMap[index] = funcMap
    end

    table.insert(funcMap, func)
end

function ComponentAttribute:InvokeAttrChangeFunc(index, oldValue, newValue)
    if not self.m_AttrFuncMap then
        return
    end
    local funcMap = self.m_AttrFuncMap[index]
    if not funcMap then
        return
    end

    for i, v in pairs(funcMap) do
        if v then
            v(self.m_Owner, oldValue, newValue)
        end
    end
end

function ComponentAttribute.GetAttrValueType(index)
    --TODO: ATTR_CONFIG
    if index == 7 or index == 8 then
        return "int"
    elseif index == 84 then
        return "ushort"
    end

    return "float"
end

return ComponentAttribute