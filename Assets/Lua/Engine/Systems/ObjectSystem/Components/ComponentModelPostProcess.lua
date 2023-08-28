---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/3/22 21:29
---
local ComponentModelPostProcess = class("ComponentModelPostProcess", ComponentBase)
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
ComponentModelPostProcess.m_ComponentId = ComponentDefine.ComponentType.k_ComponentModelPostProcess

local k_3rdHideBodyPartList =
{
    "cornea",
    "eyelash",
}

function ComponentModelPostProcess:Init(owner)
    ComponentModelPostProcess.__super.Init(self, owner)
end

function ComponentModelPostProcess:OnModelLoadComplete()
    local owner = self.m_Owner
    if owner:IsValid() == false then
        return
    end

    if owner:IsModelLoadFinish() == false then
        return
    end

    local resourceId = owner.m_ResourceId
    local config = ModelConfig[resourceId]
    if not config then
        Logger.Error("[ComponentModelPostProcess:Init] Nil config for resourceId :".. resourceId)
        return
    end

    if owner:IsHero() then
        self:ApplyFullFeature(owner)
    else
        self:ApplySimplification(owner)
    end
end

function ComponentModelPostProcess:Reset()
    local owner = self.m_Owner

    if not owner then
        return
    end

    if owner:IsHero() then
        self:ApplyFullFeature(owner)
    else
        self:ApplySimplification(owner)
    end
end

function ComponentModelPostProcess:ApplySimplification(object)
    for i, v in pairs(k_3rdHideBodyPartList) do
        object:SetBodyPartActiveWithBlurSearch(v, false)
    end
end

function ComponentModelPostProcess:ApplyFullFeature(object)
    for i, v in pairs(k_3rdHideBodyPartList) do
        object:SetBodyPartActiveWithBlurSearch(v, true)
    end
end

return ComponentModelPostProcess