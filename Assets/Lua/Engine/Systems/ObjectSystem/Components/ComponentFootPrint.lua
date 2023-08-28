---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/12/6 17:47
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentFootPrint = class("ComponentFootPrint", ComponentBase)
ComponentFootPrint.m_ComponentId = ComponentDefine.ComponentType.k_ComponentFootPrint
local k_GrassLand = "Grass"        -- 草地
local k_HardLand = "Hard"         -- 硬地
local k_SoilLand = "Soil"          -- 土地
local k_SandLand = "Sand"          -- 沙地
local k_SnowLand = "Snow"          -- 雪地
local k_ShallowLand = "Shallow"    -- 浅水
local k_ShallowDeepThreshold = 1
local k_ShallowThreshold = 0.4
local k_DustOffset = 0.2
local FootEffectType = {
    k_Human = 1,
    k_Horse = 2,
    k_Hard = 3,
    k_Grass = 4,
    k_Soil = 5,
    k_Sand = 6,
    k_Snow = 7,
    k_Shallow = 8,
    k_ShallowDeep = 9,
    k_Rain = 10,
}
local FootPrintPlayType = {
    k_FootPrint = 1,
    k_Effect = 2,
}

local Core_EntityUtility = SGEngine.Core.EntityUtility
local Core_RenderSetting = SGEngine.Rendering.RenderSetting
local Core_StateDefine = SGEngine.Core.StateDefine

function ComponentFootPrint:Init(object)
    ComponentFootPrint.__super.Init(self, object)
    self.m_FootEffectAvailableInstanceMap = {}
end

function ComponentFootPrint:Update(deltaTime)
end

function ComponentFootPrint:LateUpdate()
end

function ComponentFootPrint:Destroy()
    for i, targetList in pairs(self.m_FootEffectAvailableInstanceMap) do
        for i, footprintEffect in pairs(targetList) do
            if footprintEffect then
                EffectManager.DestroyEffect(footprintEffect.m_InstanceId)
            end
        end
    end
    self.m_FootEffectAvailableInstanceMap = nil
    ComponentFootPrint.__super.Destroy(self)
end

function ComponentFootPrint:Reset()
end

function ComponentFootPrint:OnModelLoadComplete()
end

function ComponentFootPrint:OnFootPrintCallback(bodyPart, intParam)
    local footTransform
    self.m_Owner:CheckAndAddMoveWave()

    if string.IsNullOrEmpty(bodyPart) then
        return
    end
    if self.m_Owner:IsState(Core_StateDefine.k_StateRide) then
        local boneName = self:TransformBodyPartToBoneNameHorse(bodyPart)
        if boneName == nil then
            Logger.LogInfo("[ComponentFootPrint].(OnFootPrintCallback)no bone:%s", bodyPart)
            return
        end
        local mount = self.m_Owner.m_StateComponent.m_StateRideParam.m_Mount
        if mount ~= nil then
            footTransform = mount:GetBodyPartTransform(boneName)
        end
    else
        local boneName = self:TransformBodyPartToBoneNameHuman(bodyPart)
        if boneName == nil then
            Logger.LogInfo("[ComponentFootPrint].(OnFootPrintCallback) no bone:%s", bodyPart)
            return
        end
        footTransform = self.m_Owner:GetBodyPartTransform(boneName)
    end
    if footTransform == nil then
        --Logger.LogInfo("[ComponentFootPrint].(OnFootPrintCallback) no footTransform:%s", bodyPart)
        return
    end
    local tagName = Core_EntityUtility.GetGroundTagsByTransform(footTransform)
    self:HandleFootPrint(tagName, footTransform.position, intParam)
end

function ComponentFootPrint:TransformBodyPartToBoneNameHuman(bodyPart)
    if bodyPart == "lf" then
        return "Bip001 L Foot"
    elseif bodyPart == "rf" then
        return "Bip001 R Foot"
    end
    return nil
end

function ComponentFootPrint:TransformBodyPartToBoneNameHorse(bodyPart)
    if bodyPart == "lf" then
        return "Bip001 L Foot"
    elseif bodyPart == "rf" then
        return "Bip001 R Foot"
    elseif bodyPart == "lh" then
        return "Bip001 L Hand"
    elseif bodyPart == "rh" then
        return "Bip001 R Hand"
    end
    return nil
end

function ComponentFootPrint:HandleFootPrint(tagName, position, intParam)
    --Logger.LogInfo("ComponentFootPrint.HandleFootPrint tagName:%s, intParam:%s", tagName, intParam)
    local footEffectType = nil
    local probability = 0

    if intParam == FootPrintPlayType.k_Effect then
        footEffectType, probability = self:InitEffectType(tagName, position)
    elseif intParam == FootPrintPlayType.k_FootPrint then
        footEffectType, probability = self:InitFootPrintEffectType(tagName, position)
    end

    if footEffectType == nil then
        --Logger.LogInfo("ComponentFootPrint.HandleFootPrint footEffectType == nil")
        return
    end
    self:PlayFootPrint(footEffectType, position, intParam, probability)
end

function ComponentFootPrint:InitFootPrintEffectType(tagName, position)
    local footEffectType
    local probability = 0
    local isRainEnable = Core_RenderSetting.GetActiveSetting():IsRainActive()
    local isSnowEnable = Core_RenderSetting.GetActiveSetting():IsSnowActive()
    footEffectType = FootEffectType.k_Human
    if self.m_Owner:IsState(Core_StateDefine.k_StateRide) then
        footEffectType = FootEffectType.k_Horse
    end
    
    if isRainEnable then
        probability = 0
    elseif isSnowEnable then
        probability = 100
    elseif tagName == k_GrassLand then
        probability = 100
    elseif tagName == k_SoilLand then
        probability = 100
    elseif tagName == k_SandLand then
        probability = 100
    elseif tagName == k_SnowLand then
        probability = 100
    elseif tagName == k_ShallowLand then
        ---get water
        local waterHeight = Core_EntityUtility.GetWaterHeightByPositionXYZ(position.x, position.y, position.z, self.m_Owner.m_Core)
        ---get ground
        local groundHeight = Core_EntityUtility.GetHeightOnFloorByPositionXYZ(position.x, position.y, position.z)
        if groundHeight - waterHeight > 0 then
            position.y = groundHeight
            probability = 100
        elseif waterHeight - groundHeight >= 0 and waterHeight - groundHeight < k_ShallowThreshold then
            position.y = waterHeight + k_DustOffset
            probability = 0
        elseif waterHeight - groundHeight >= k_ShallowThreshold and waterHeight - groundHeight < k_ShallowDeepThreshold then
            position.y = waterHeight + k_DustOffset
            probability = 0
        end
    end

    return footEffectType, probability
end

function ComponentFootPrint:InitEffectType(tagName, position)
    local footEffectType
    local probability = 0

    local isRainEnable = Core_RenderSetting.GetActiveSetting():IsRainActive()
    if isRainEnable then
        if tagName ~= k_ShallowLand then
            footEffectType = FootEffectType.k_Rain
        end

        probability = 100
    elseif tagName == k_GrassLand then
        footEffectType = FootEffectType.k_Grass
        probability = 60
    elseif tagName == k_SoilLand then
        footEffectType = FootEffectType.k_Soil
        probability = 100
    elseif tagName == k_SandLand then
        footEffectType = FootEffectType.k_Sand
        probability = 100
    elseif tagName == k_SnowLand then
        footEffectType = FootEffectType.k_Snow
        probability = 100
    elseif tagName == k_ShallowLand then
        probability = 100
        ---get water
        local waterHeight = Core_EntityUtility.GetWaterHeightByPositionXYZ(position.x, position.y, position.z, self.m_Owner.m_Core)
        ---get ground
        local groundHeight = Core_EntityUtility.GetHeightOnFloorByPositionXYZ(position.x, position.y, position.z)
        if groundHeight - waterHeight > 0 then
            footEffectType = FootEffectType.k_Sand
            position.y = groundHeight
        elseif waterHeight - groundHeight >= 0 and waterHeight - groundHeight < k_ShallowThreshold then
            footEffectType = FootEffectType.k_Shallow
            position.y = waterHeight + k_DustOffset
        elseif waterHeight - groundHeight >= k_ShallowThreshold and waterHeight - groundHeight < k_ShallowDeepThreshold then
            footEffectType = FootEffectType.k_ShallowDeep
            position.y = waterHeight + k_DustOffset
        end
    end

    return footEffectType, probability
end

function ComponentFootPrint:PlayFootPrint(footEffectType, position, intParam, probability)
    --Logger.LogInfo("ComponentFootPrint. PlayFootPrint: footEffectType:%s, intParam:%s, probability:%s",footEffectType, intParam, probability)
    local random = math.random(0, 100)
    if random > probability then
        --Logger.LogInfo("[ComponentFootPrint].(PlayFootPrint) random fail, random: %s, probability : %s", random, probability)
        return
    end

    self:SetEffectAtPos(position, footEffectType)

    if intParam == FootPrintPlayType.k_Effect then
        if self.m_Owner:IsState(Core_StateDefine.k_StateRide) then
            self:PlayAudio(FootEffectType.k_Horse)
        else
            self:PlayAudio(footEffectType)
        end
    end
end

function ComponentFootPrint:SetEffectAtPos(position, footEffectType)
    local footDustEffect = self:GetEffect(footEffectType)
    if footDustEffect == nil then
        Logger.LogInfo("[ComponentFootPrint].(SetFootDustAtPos) GetFootDust fail, footEffectType: %s", footEffectType)
        return
    end
    footDustEffect:SetFootEffectType(footEffectType)
    footDustEffect:Start(false)
    footDustEffect:ResetTransform(false)
    footDustEffect:SetPosition(position)
    local angle = self.m_Owner:GetAngle()
    footDustEffect:Rotate(0, angle, 0)
end

function ComponentFootPrint:GetEffect(footEffectType)
    --Logger.LogInfo("[ComponentFootPrint].(GetEffect) GetGetEffect ,footEffectType: %s", footEffectType)

    local targetList = self.m_FootEffectAvailableInstanceMap[footEffectType]
    if targetList == nil then
        targetList = {}
        self.m_FootEffectAvailableInstanceMap[footEffectType] = targetList
    end

    if not targetList then
        return
    end

    local effectConfig = FootPrintEffectConfig[footEffectType]
    if effectConfig == nil then
        Logger.LogInfo("[ComponentFootPrint].(GetEffect) Get FootPrintEffectConfig failed ,footEffectType: %s", footEffectType)
        return
    end
    local length = #targetList
    if length == 0 then
        --Logger.LogInfo("ComponentFootPrint.GetFootPrint no available, CreateNew: %s", footprintEffectId)
        local effectIndex, effect = self.m_Owner.m_EffectComponent:PlayNormalEffect(effectConfig.EffectId)
        return effect
    else
        --Logger.LogInfo("ComponentFootPrint.available, GetOld: %s", footprintEffectId)
        local effect = targetList[length]
        table.remove(targetList, length)
        return effect
    end
end

function ComponentFootPrint:PlayAudio(footEffectType)
    
end

function ComponentFootPrint:PushFootprintToPool(footprintEffect)
    if footprintEffect == nil then
        return
    end
    local footEffectType = footprintEffect.m_FootEffectType
    local targetList = self.m_FootEffectAvailableInstanceMap[footEffectType]
    if targetList == nil then
        EffectManager.DestroyEffect(footprintEffect.m_InstanceId)
        return
    end
    --Logger.LogInfo("PushFootprintToPool: id: %s", footprintEffect.m_InstanceId)
    table.insert(targetList, footprintEffect)
end

return ComponentFootPrint