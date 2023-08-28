local EffectBase = require("Engine/Systems/EffectSystem/Effects/EffectBase")
local DestroyGrassEffect = class("DestroyGrassEffect", EffectBase)
local k_DestroyGrassEffectConfigID = 3

function DestroyGrassEffect:Ctor(...)
    DestroyGrassEffect.__super.Ctor(self,...)
end

function DestroyGrassEffect:Start(needLoadResource)
    self.__super.Start(self, needLoadResource)
end

function DestroyGrassEffect:OnLoadModelSuccess()
    local type = System.Type.GetType("SGEngine.Core.DestroyGrassEffect")
    self.m_DestroyGrassEffectBehaviour = self.m_Instance:GetComponent(type)
    if self.m_DestroyGrassEffectBehaviour ~= nil then
        local EffectManager = EffectManager
        local position = Vector3.zero
        self.m_DestroyGrassEffectBehaviour:RegDestroyGrassCallBack(function(x, y, z)
            local effectID = self.m_Owner.m_EffectComponent:PlayNormalEffect(k_DestroyGrassEffectConfigID)
            position:Set(x, y, z)
            EffectManager.SetEffectPosition(effectID, position)
        end)
        self.m_DestroyGrassEffectBehaviour:Excute()
    end
end

function DestroyGrassEffect:Destroy()
    self.__super.Destroy(self)
end

return DestroyGrassEffect