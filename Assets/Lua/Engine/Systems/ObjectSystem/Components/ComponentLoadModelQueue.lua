---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2022/8/30 10:15
---
---@class ComponentLoadModelQueue : ComponentBase
local ComponentLoadModelQueue = class("ComponentLoadModelQueue", ComponentBase)
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
ComponentLoadModelQueue.m_ComponentId = ComponentDefine.ComponentType.k_ComponentLoadModelQueue

local k_MaxLoadingCount = 3
ComponentLoadModelQueue.s_CurrentLoadingCount = 0
ComponentLoadModelQueue.s_HasLoadedCount = 0
ComponentLoadModelQueue.s_LastCheckFrame = 0
local k_WaitTime = 1
function ComponentLoadModelQueue:Init(owner)
    ComponentLoadModelQueue.__super.Init(self, owner)
end

function ComponentLoadModelQueue:Update(deltaTime)
    if self:NeedLoad() then
        self.m_Owner:LoadModel(self.m_Callback)
    end

    if self.m_BeginLoadTime == nil then
        return
    end

    if Time.time - self.m_BeginLoadTime > k_WaitTime then
        self:ClearFlag()
    end
end

function ComponentLoadModelQueue:CanLoad()
    if ComponentLoadModelQueue.s_CurrentLoadingCount >= k_MaxLoadingCount then
        return false
    end

    local currentFrame = Time.frameCount
    if ComponentLoadModelQueue.s_LastCheckFrame == currentFrame then
        if ComponentLoadModelQueue.s_HasLoadedCount >= k_MaxLoadingCount  then
            return false
        end
    else
        ComponentLoadModelQueue.s_LastCheckFrame = currentFrame
        ComponentLoadModelQueue.s_HasLoadedCount = 0
    end
    return true
end

function ComponentLoadModelQueue:NeedLoad()
    return self.m_BeginLoadTime == nil and self.m_IsRequestLoad == true
end

function ComponentLoadModelQueue:LoadModel(isPlayer, isHero, callback)
    self.m_IsRequestLoad = true
    if self:CanLoad() == true then
        ComponentLoadModelQueue.s_CurrentLoadingCount = ComponentLoadModelQueue.s_CurrentLoadingCount + 1
        self:SetFlag()
        self.m_Owner:LoadModelCore(isPlayer, isHero, callback)
    end
end

function ComponentLoadModelQueue:OnLoaded()
    self:ClearFlag()
    if self.m_Owner == nil or self.m_Owner:IsValid() == false then
        return
    end
    self.m_Owner:RemoveComponent(ComponentLoadModelQueue.m_ComponentId)
end

function ComponentLoadModelQueue:SetFlag()
    self.m_BeginLoadTime = Time.time
    self.m_IsRequestLoad = false
end

function ComponentLoadModelQueue:ClearFlag()
    if self.m_BeginLoadTime == nil then
        return
    end
    ComponentLoadModelQueue.s_HasLoadedCount = ComponentLoadModelQueue.s_HasLoadedCount + 1
    ComponentLoadModelQueue.s_CurrentLoadingCount = ComponentLoadModelQueue.s_CurrentLoadingCount - 1
    self.m_BeginLoadTime = nil
end

return ComponentLoadModelQueue