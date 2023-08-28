local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentStateChecker = class("ComponentStateChecker", ComponentBase)
local StateDefine = SGEngine.Core.StateDefine
local Core_EntityUtility = SGEngine.Core.EntityUtility
local SkillType = SGEngine.Core.SkillDefines

ComponentStateChecker.m_ComponentId = ComponentDefine.ComponentType.k_ComponentStateChecker

function ComponentStateChecker:Init(object)
    ComponentStateChecker.__super.Init(self, object)
    self.m_FallCheckEnable = false
    self.m_SwimCheckEnable = false
    self.m_SwimSyncInfoCheckEnable = false
end

function ComponentStateChecker:OnModelLoadComplete()
end

function ComponentStateChecker:Destroy()
    ComponentStateChecker.__super.Destroy(self)
end

function ComponentStateChecker:Update(deltaTime)
    local owner = self.m_Owner
    if owner:IsModelLoadFinish() == false then
        return
    end

    if SceneManager.IsChangingScene() == true then
        return
    end

    if SceneManager.IsChangeSceneTaskDone() == false then
        return
    end

    if self.m_SwimCheckEnable and self:CheckIfCanSwim() then
        if owner:IsHero() then
            owner:ChangeToSwim()
        else           
            local jumpState = owner:GetState(StateDefine.k_StateJump)
            if jumpState ~= nil then
                jumpState.CheckInSwim3rd(owner)
            end

            local swimState3rd = owner:GetState(StateDefine.k_StateSwim)
            if swimState3rd ~= nil then
                swimState3rd.CheckInSwim3rd(owner)
            end
            self.m_SwimCheckEnable = false
        end
        return
    end

    if self.m_FallCheckEnable and self:CheckIfCanFall() then
        owner:ChangeToFall()
        return
    end

    if self.m_SwimSyncInfoCheckEnable == true then
        self.m_SwimSyncInfoCheckEnable = false
        if owner:IsHero() == false then
            local swimState3rd = owner:GetState(StateDefine.k_StateSwim)
            if swimState3rd ~= nil and swimState3rd.CheckInSwim3rd ~= nil then
                Logger.LogInfo("[ComponentStateChecker](m_SwimSyncInfoCheckEnable) CheckInSwim3rd")
                swimState3rd.CheckInSwim3rd(owner)
            end
        end
    end
end

function ComponentStateChecker:CheckIfCanSwim()
    local owner = self.m_Owner
    if owner:IsState(StateDefine.k_StateSwim) then
        --Logger.LogInfo("ComponentStateChecker CheckIfCanSwim k_StateSwim")
        return false
    end

    if owner:IsState(StateDefine.k_StateSkill) then
        local stateData = owner.m_StateComponent.m_StateSkillParam
        local currentSkill = stateData.m_CurrentSkill
        if currentSkill.m_Config.SkillModule == SkillType.k_SkillTypeJump then
            return self:CheckSwimByJump()
        elseif currentSkill ~= nil and currentSkill:IsBreakable() then
            --Logger.LogInfo("ComponentStateChecker CheckIfCanSwim currentSkill")
            return false
        end
    end

    if owner:IsState(StateDefine.k_StateJump) then
        return self:CheckSwimByJump()
    else
        --Logger.LogInfo("ComponentStateChecker CheckIfCanSwim unJump")
        return self:CheckSwimNormal()
    end
end

function ComponentStateChecker:CheckSwimNormal()
    local owner = self.m_Owner
    local waterDepth = 0
    local depthDif, waterDepth = Core_EntityUtility.GetHeightDifFromWaterToObjPos(owner.m_Core, waterDepth)
    local config = owner.m_CharacterConfig

    if depthDif >= config.InWaterDepth then
        return true
    end
    return false
end

function ComponentStateChecker:CheckSwimByJump()
    local owner = self.m_Owner
    local waterDepth = 0
    local depthDif, waterDepth = Core_EntityUtility.GetHeightDifFromWaterToObjPos(owner.m_Core, waterDepth)
    local groundHeight = Core_EntityUtility.GetObjHeightOnFloor(owner.m_Core)
    local currentSpeedY = owner:GetCurrentMoveSpeedY()
    local currentGravity = owner:GetCurrentGravity()
    local predictD = math.abs((currentSpeedY * currentSpeedY) / (2 * 3 * currentGravity))
    local config = owner.m_CharacterConfig
    local groundWaterDif = waterDepth - groundHeight - 0.1    ---这里稍微往下压一点 ，作为极限触底距离
    local finalDistance = math.min(groundWaterDif, config.InWaterDepth + 0.1 * predictD)   ---防止速度太大触底
    finalDistance = math.max(config.InWaterDepth, finalDistance)   --- 最少也要达到配置的深度
    --Logger.LogInfo("depthDif:%s waterDepth:%s, predictD: %s, groundWaterDif: %s", depthDif, waterDepth, predictD, groundWaterDif)
    --Logger.LogInfo("D: %s", finalDistance)

    if depthDif >= finalDistance then
        --Logger.LogInfo("ComponentStateChecker CheckSwimByJump: true")
        return true
    end
    --Logger.LogInfo("ComponentStateChecker CheckSwimByJump: false")
    return false
end

function ComponentStateChecker:CheckIfCanFall()
    local owner = self.m_Owner
    if owner:IsState(StateDefine.k_StateSwim) or owner:IsState(StateDefine.k_StateJump) then
        return false
    end

    if owner:IsState(StateDefine.k_StateSkill) then
        local stateData = owner.m_StateComponent.m_StateSkillParam
        local currentSkill = stateData.m_CurrentSkill
        if currentSkill and currentSkill:IsBreakable() == false then
            return false
        end
    end

    local depth = Core_EntityUtility.GetHeightDiffFromPlayerToGround(owner.m_Core)
    if depth > 1 then
        if UNITY_EDITOR then
            local x, y, z = owner:GetPositionXYZ()
            --Logger.LogDebug("[ComponentStateChecker](ChanIfCanFall) fall position x :%s, y:%s, z:%s,", x, y, z)
        end
        return true
    end
    return false
end

function ComponentStateChecker:SetSwimCheckActive(active)
    self.m_SwimCheckEnable = active
end

function ComponentStateChecker:SetFallCheckActive(active)
    self.m_FallCheckEnable = active
end

function ComponentStateChecker:SetSwimSyncInfoCheckActive(active)
    self.m_SwimSyncInfoCheckEnable = active
end

return ComponentStateChecker