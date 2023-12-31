---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/12/1 10:32
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local SyncConsts = ComponentDefine.SyncConsts
local MoveSyncType = ComponentDefine.MoveSyncType
local EntityUtility = SGEngine.Core.EntityUtility
local SkillMovePro3rd = class("SkillMovePro3rd", SkillBase)
local StateDefine = SGEngine.Core.StateDefine
local k_AnimationSuffix = "_moving"

function SkillMovePro3rd:Ctor()
    SkillMovePro3rd.__super.Ctor(self)
end

function SkillMovePro3rd:Init(object, skillConfig, targetObjectId, targetPosition)
    self.m_PredictStep = 0
    SkillMovePro3rd.__super.Init(self, object, skillConfig, targetObjectId, targetPosition)
end

function SkillMovePro3rd:GetParams()
    self.m_HasMoveAnimation = self.m_Owner:ContainAnimation(self.m_Config.AnimName .. k_AnimationSuffix)
    return self.m_HasMoveAnimation
end

function SkillMovePro3rd:SetCoreInitParam()
    local owner = self.m_Owner
    if owner == nil then
        return
    end

    owner:SetCurrentMoveSpeed(self.m_Config.MovingSpeed)
    owner:SetCurrentRotateSpeed(self.m_Config.RotateSpeed)
end

function SkillMovePro3rd:Destroy()
    self.m_PredictStep = 0
    self.m_CurrentSyncInfo = nil
    SkillMovePro3rd.__super.Destroy(self)
end

function SkillMovePro3rd:OnSkillMove()
end

function SkillMovePro3rd:OnSkillMoveStop()
    --Logger.LogInfo("OnSkillMoveStop")
    if self:CheckPredict() then
        self:PredictMove()
    elseif self.m_CurrentSyncInfo.m_SyncType == MoveSyncType.k_SkillMoveStop then
        self.m_Owner.m_Core:OnSyncStateStopMove(StateDefine.k_StateSkill)
    end
end

function SkillMovePro3rd:CheckPredict()
    if self.m_PredictStep > SyncConsts.k_Max3rdPredictStep then
        return false
    end

    if self.m_CurrentSyncInfo == nil then
        return false
    end

    local syncType = self.m_CurrentSyncInfo.m_SyncType
    if syncType == MoveSyncType.k_SkillMove then
        return true
    end

    return false
end

function SkillMovePro3rd:PredictMove()
    self.m_PredictStep = self.m_PredictStep + 1
    local syncInfo = self.m_CurrentSyncInfo
    local moveAngle = syncInfo.m_MoveAngle
    local angle = syncInfo.m_Angle
    local owner = self.m_Owner
    local moveSpeed = owner:GetCurrentMoveSpeed()
    local predictPos = owner:PredictPosOnGroundByController(moveAngle, moveSpeed, 1)
    --Logger.LogInfo("PredictTo:{%f},{%f},{%f},%d", predictPos.x, predictPos.y, predictPos.z, Time.frameCount)
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSkill, predictPos.x, predictPos.y, predictPos.z, angle)
end
--endregion

function SkillMovePro3rd:UpdateSyncInfo(syncInfo)
    local owner = self.m_Owner
    self.m_PredictStep = 0
    self.m_CurrentSyncInfo = syncInfo
    local angle = syncInfo.m_Angle
    local syncType = syncInfo.m_SyncType
    local targetPosition = syncInfo.m_TargetPosition
    local x = targetPosition.x
    local y = targetPosition.y
    local z = targetPosition.z
    local position = targetPosition:Clone()
    --Logger.LogInfo("UpdateSyncInfoTo:{%f},{%f},{%f},%d, type:%d", targetPosition.x, targetPosition.y, targetPosition.z, Time.frameCount, syncType)
    syncInfo.m_MoveAngle = EntityUtility.Dir2Angle(position:Sub(self.m_Owner:GetPosition()))
    if syncType == MoveSyncType.k_SkillMove then
        owner.m_Core:OnSyncStateMove(StateDefine.k_StateSkill, x, y, z, angle)
    elseif syncType == MoveSyncType.k_SkillMoveStop then
        local moveSpeed = owner:GetCurrentMoveSpeed()
        if position:SqrMagnitude() > moveSpeed * Time.deltaTime * moveSpeed * Time.deltaTime then
            owner.m_Core:OnSyncStateMove(StateDefine.k_StateSkill, x, y, z, angle)
        else
            owner:SetPosition(targetPosition)
            owner:SetAngle(angle)
            owner.m_Core:OnSyncStateStopMove(StateDefine.k_StateSkill)
        end
    end
end

return SkillMovePro3rd