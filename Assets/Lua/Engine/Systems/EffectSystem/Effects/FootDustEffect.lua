---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/12/6 22:55
---
local EffectBase = require("Engine/Systems/EffectSystem/Effects/EffectBase")
local EffectStatus = require("Engine/Systems/EffectSystem/EffectStatus")
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local Core_EntityUtility = SGEngine.Core.EntityUtility
local FootDustEffect = class("FootDustEffect", EffectBase)

function FootDustEffect:Ctor(...)
    FootDustEffect.__super.Ctor(self,...)
end

function FootDustEffect:GetPoolingStrategyType()
    return PoolingStrategyTypeEnum.EffectDefault
end

function FootDustEffect:Finish()
    self:SetActive(false)
    self.m_Status = EffectStatus.Ended
    local owner = self.m_Owner
    if not owner then
        return
    end
    local footPrintComponent = owner.m_FootprintComponent
    if not footPrintComponent then
        return
    end
    self.m_Owner.m_FootprintComponent:PushFootprintToPool(self)
end

---这里需要将effect缓存在ComponentFootprint中，所以一直返回false 不会被EffectManager的Update Destroy
function FootDustEffect:IsFinish()
    return false
end

function FootDustEffect:IsAvailable()
    return self.m_Status ~= EffectStatus.Ended
end

function FootDustEffect:SetFootEffectType(footEffectType)
    self.m_FootEffectType = footEffectType
end

function FootDustEffect:IsNeedEffectBehaviour()
    return false
end

return FootDustEffect