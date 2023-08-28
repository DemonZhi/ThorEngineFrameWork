local EffectBase = require("Engine/Systems/EffectSystem/Effects/EffectBase")
local ChainAttackEffect = class("ChainAttackEffect", EffectBase)

function ChainAttackEffect:Ctor(...)
    ChainAttackEffect.__super.Ctor(self,...)
end

function ChainAttackEffect:OnLoadModelSuccess()
    self.m_EffectInstance = self.m_Instance:GetComponent("SGEngine.Core.ChainLightingEffect")
    if self.m_TargetTransform then
        self.m_EffectInstance:SetTargetTransform(self.m_TargetTransform)
    end
    self.m_TargetTransform = nil
end

function ChainAttackEffect:Destroy()
    self.m_EffectInstance = nil
    self.__super.Destroy(self)
end

function ChainAttackEffect:SetTargetTransform(targetTransform)
    if self.m_EffectInstance == nil then
        self.m_TargetTransform = targetTransform
        return
    end

    self.m_EffectInstance:SetTargetTransform(targetTransform)
end

return ChainAttackEffect