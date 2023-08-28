
local EffectBase = require("Engine/Systems/EffectSystem/Effects/EffectBase")
local RadialBlurEffect = class("RadialBlurEffect", EffectBase)

function RadialBlurEffect:Ctor(...)
    RadialBlurEffect.__super.Ctor(self,...)
end

function RadialBlurEffect:OnLoadModelSuccess()
    RadialBlurEffect.__super.OnLoadModelSuccess(self)
    local type = System.Type.GetType("SGEngine.Core.RadialBlurEffect")
    self.m_RadialBlurEffect = self.m_Instance:GetComponent(type)
end

function RadialBlurEffect:SetPlaySpeed(speed)
    self.m_Speed = speed
    if self.m_RadialBlurEffect ~= nil then
        self.m_RadialBlurEffect:SetPlaySpeed(speed)
    end
end

function RadialBlurEffect:Destroy()
    self.__super.Destroy(self)
    self.m_RadialBlurEffect = nil
end

return RadialBlurEffect