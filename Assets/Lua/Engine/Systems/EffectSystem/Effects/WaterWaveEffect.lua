
local EffectBase = require("Engine/Systems/EffectSystem/Effects/EffectBase")
local WaterWaveEffect = class("WaterWaveEffect", EffectBase)

function WaterWaveEffect:Ctor(...)
    WaterWaveEffect.__super.Ctor(self, ...)
end

function WaterWaveEffect:OnLoadModelSuccess()
    WaterWaveEffect.__super.OnLoadModelSuccess(self)
    local type = System.Type.GetType("SGEngine.Core.WaterWaveEffect")
    self.m_WaterWaveEffect = self.m_Instance:GetComponent(type)
    if self.m_WaterWaveEffect ~= nil then
       self.m_WaterWaveEffect:Begin()
    end
end

function WaterWaveEffect:SetPlaySpeed(speed)
    self.m_Speed = speed
    if self.m_WaterWaveEffect ~= nil then
        self.m_WaterWaveEffect:SetPlaySpeed(speed)
    end
end

function WaterWaveEffect:Destroy()
    self.__super.Destroy(self)
    if self.m_WaterWaveEffect ~= nil then
       self.m_WaterWaveEffect:End()
       self.m_WaterWaveEffect = nil
    end
end

return WaterWaveEffect