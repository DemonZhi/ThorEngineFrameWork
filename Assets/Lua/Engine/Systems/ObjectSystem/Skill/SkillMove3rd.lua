---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/12/1 10:32
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local SyncConsts = ComponentDefine.SyncConsts
local MoveSyncType = ComponentDefine.MoveSyncType
local SkillMove3rd = class("SkillMove3rd", SkillBase)
local StateDefine = SGEngine.Core.StateDefine

function SkillMove3rd:Ctor()
    SkillMove3rd.__super.Ctor(self)
end

function SkillMove3rd:Init(object, skillConfig, targetObjectId, targetPosition)
    self.m_PredictStep = 0
    SkillMove3rd.__super.Init(self, object, skillConfig, targetObjectId, targetPosition)
end

function SkillMove3rd:SetCoreInitParam()
    local owner = self.m_Owner
    if owner == nil then
        return
    end
    owner:SetCurrentMoveSpeed(self.m_Config.MovingSpeed)
    owner:SetCurrentRotateSpeed(self.m_Config.RotateSpeed)
end

function SkillMove3rd:Destroy()
    self.m_PredictStep = 0
    self.m_CurrentSyncInfo = nil
    SkillMove3rd.__super.Destroy(self)
end

function SkillMove3rd:OnSkillMove()
end

function SkillMove3rd:OnSkillMoveStop()
    if self:CheckPredict() then
        self:PredictMove()
    elseif self.m_CurrentSyncInfo.m_SyncType == MoveSyncType.k_SkillMoveStop then
        self.m_Owner.m_Core:OnSyncStateStopMove(StateDefine.k_StateSkill)
    end
end

function SkillMove3rd:CheckPredict()
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

function SkillMove3rd:PredictMove()
    local owner = self.m_Owner
    self.m_PredictStep = self.m_PredictStep + 1
    local syncInfo = self.m_CurrentSyncInfo
    local angle = syncInfo.m_Angle
    local moveSpeed = owner:GetCurrentMoveSpeed()
    local predictPos = owner:PredictPosOnGround(angle, moveSpeed, 1)
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSkill, predictPos.x, predictPos.y, predictPos.z, angle)
end

function SkillMove3rd:UpdateSyncInfo(syncInfo)
    local owner = self.m_Owner
    self.m_PredictStep = 0
    self.m_CurrentSyncInfo = syncInfo
    local angle = syncInfo.m_Angle
    local syncType = syncInfo.m_SyncType
    local targetPosition = syncInfo.m_TargetPosition
    local x = targetPosition.x
    local y = targetPosition.y
    local z = targetPosition.z
    --Logger.LogInfo("UpdateSyncInfoTo:{%f},{%f},{%f},%d, type:%d", targetPosition.x, targetPosition.y, targetPosition.z, Time.frameCount, syncType)
    if syncType == MoveSyncType.k_SkillMove then
        owner.m_Core:OnSyncStateMove(StateDefine.k_StateSkill, x, y, z, angle)
    elseif syncType == MoveSyncType.k_SkillMoveStop then
        local position = targetPosition:Clone()
        local moveSpeed = owner:GetCurrentMoveSpeed()
        position:Sub(owner:GetPosition())
        ---fix y
        if position:SqrMagnitude() > moveSpeed * Time.deltaTime * moveSpeed * Time.deltaTime or moveSpeed == 0 then
            owner.m_Core:OnSyncStateMove(StateDefine.k_StateSkill, x, y, z, angle)
        else
            owner:SetPosition(targetPosition)
            owner:SetAngle(angle)
            owner.m_Core:OnSyncStateStopMove(StateDefine.k_StateSkill)
        end
    end
end

return SkillMove3rd