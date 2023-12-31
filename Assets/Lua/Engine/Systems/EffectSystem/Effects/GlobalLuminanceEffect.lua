---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/3/26 15:11
---

local EffectBase = require("Engine/Systems/EffectSystem/Effects/EffectBase")
local GlobalLuminanceEffect = class("GlobalLuminanceEffect", EffectBase)
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")

function GlobalLuminanceEffect:Ctor(...)
    GlobalLuminanceEffect.__super.Ctor(self,...)
    self.m_PoolingStrategyType = PoolingStrategyTypeEnum.DontDestroyOnLoad
end

function GlobalLuminanceEffect:OnLoadModelSuccess()
    local type = System.Type.GetType("SGEngine.Core.GlobalLuminanceControl")
    self.m_GlobalLuminanceControl = self.m_Instance:GetComponent(type)
    if self.m_GlobalLuminanceControl ~= nil then
        self.m_GlobalLuminanceControl:SetAutoUpdate(true)
    end
end

function GlobalLuminanceEffect:Update(deltaTime)
    self.__super.Update(self, deltaTime)
end

function GlobalLuminanceEffect:SetPlaySpeed(speed)
    if self.m_GlobalLuminanceControl ~= nil then
        self.m_GlobalLuminanceControl:SetPlayspeed(speed)
    end
end

function GlobalLuminanceEffect:Destroy()
    self.m_GlobalLuminanceControl = nil
    self.__super.Destroy(self)
end

return GlobalLuminanceEffect