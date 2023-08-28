local EffectBase = require("Engine/Systems/EffectSystem/Effects/EffectBase")
local GhostEffect = class("GhostEffect", EffectBase)

function GhostEffect:Ctor(...)
    GhostEffect.__super.Ctor(self,...)
end

function GhostEffect:Start(needLoadResource)
    self.__super.Start(self, needLoadResource)
end

function GhostEffect:OnLoadModelSuccess()
    local type = System.Type.GetType("SGEngine.Core.GhostEffect")
    self.m_GhostEffectBehaviour = self.m_Instance:GetComponent(type)
    if self.m_GhostEffectBehaviour ~= nil then
        self.m_GhostEffectBehaviour:Play(self.m_Owner:GetModel())
    end
end

function GhostEffect:Destroy()
    if self.m_GhostEffectBehaviour ~= nil then
        self.m_GhostEffectBehaviour:Clear()
        self.m_GhostEffectBehaviour = nil
    end

    self.__super.Destroy(self)
end

return GhostEffect