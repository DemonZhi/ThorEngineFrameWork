---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2022/2/16 11:47
---
local SGMagicArea = class("SGMagicArea", SGCtrl)
SGMagicArea.m_ObjectType = ObjectTypeEnum.MagicArea

function SGMagicArea:Ctor()
    SGMagicArea.__super.Ctor(self)
    self.m_EffectList = {}
end

function SGMagicArea:Init()
    SGMagicArea.__super.Init(self)
    self.m_IsLoadEffectFinished = false
end

function SGMagicArea:RegisterCommonComponents()
    self.m_FightResultComponent = ComponentFightResult.New()
    self:AddComponent(self.m_FightResultComponent, false)
end

function SGMagicArea:Deserialize(netBuffer)
    SGMagicArea.__super.Deserialize(self, netBuffer)
    local configID = netBuffer:ReadInt()
    self.m_OwnerID = netBuffer:ReadInt()
    self.m_TargetID = netBuffer:ReadInt()
    local config = MagicAreaConfig[configID]
    if not config then
        Logger.Error("LUA:[SGMagicArea]Deserialize: none config for configID :", configID)
        return
    end
    self.m_Config = config
end

function SGMagicArea:LoadModel()
    self:LoadEffect()
    self:OnModelLoadComplete()
end

function SGMagicArea:LoadEffect()
    local idList = self.m_Config.EffectList
    self.m_IsLoadEffectFinished = true
    if not idList or #idList == 0 then
        return
    end
    for i, v in pairs(idList) do
        local effectIndex = EffectManager.CreateEffect(self, v, true)
        if effectIndex > -1 then
            table.insert(self.m_EffectList, effectIndex)
        end
    end
    --SGEngine.Core.DebugDraw.DrawCircle(self:GetPosition(), 2.5, UnityEngine.Color.red)
end

function SGMagicArea:DestroyEffect()
    if self.m_EffectList == nil then
        return
    end
    for i, v in pairs(self.m_EffectList) do
        EffectManager.DestroyEffect(v)
    end

    local length = #self.m_EffectList
    for i = length, 1, -1 do
        local index = self.m_EffectList[i]
        EffectManager.DestroyEffect(index)
        table.remove(self.m_EffectList, i)
    end
end

function SGMagicArea:SetPosition(position, needFixY)
    SGMagicArea.__super.SetPosition(self, position, needFixY)
    if needFixY then
        position = self:GetPosition()
    end
    for i, v in pairs(self.m_EffectList) do
        local effect = EffectManager.GetEffect(v)
        if effect then
            effect:SetPosition(position)
        end
    end
end

function SGMagicArea:SetPositionXYZ(positionX, positionY, positionZ, needFixY)
    SGMagicArea.__super.SetPositionXYZ(self, positionX, positionY, positionZ, needFixY)
    if needFixY then
        positionX, positionY, positionZ = self:GetPositionXYZ()
    end
    for i, v in pairs(self.m_EffectList) do
        local effect = EffectManager.GetEffect(v)
        effect:SetPositionXYZ(positionX, positionY, positionZ)
    end
end

function SGMagicArea:Destroy()
    self:DestroyEffect()
    SGMagicArea.__super.Destroy(self)
end

return SGMagicArea