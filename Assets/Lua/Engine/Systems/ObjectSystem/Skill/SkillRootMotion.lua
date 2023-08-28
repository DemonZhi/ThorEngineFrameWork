local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local BattleMessage = require("MainGame/Message/BattleMessage")
---@class SkillRootMotion:SkillBase
local SkillRootMotion = class("SkillRootMotion", SkillBase)
local SyncConsts = ComponentDefine.SyncConsts
local StateDefine = SGEngine.Core.StateDefine
local MoveSyncType = ComponentDefine.MoveSyncType

function SkillRootMotion:Ctor()
    SkillRootMotion.__super.Ctor(self)
end

function SkillRootMotion:Init(object, skillConfig, targetObjectId, targetPosition)
    self.m_IsHero = object:IsHero()
    SkillRootMotion.__super.Init(self, object, skillConfig, targetObjectId, targetPosition)
end

function SkillRootMotion:Destroy()
    SkillRootMotion.__super.Destroy(self)
end

function SkillRootMotion:SetCoreInitParam()
    SkillRootMotion.__super.SetCoreInitParam(self)
    local owner = self.m_Owner
    local config = self.m_Config
    local acceptInputFromJoystick = false
    local useColliderDetection = true
    local extendParam = config.SkillModuleParams
    if extendParam and #extendParam > 0 then
        acceptInputFromJoystick = extendParam[1] == 1
        useColliderDetection = extendParam[2] == 1
    end
    self:SetParamToCore(useColliderDetection, owner:GetRadius(), acceptInputFromJoystick)
    owner:SetCurrentMoveSpeed(config.MovingSpeed)
    owner:SetCurrentRotateSpeed(config.RotateSpeed)
end

function SkillRootMotion:Update(deltaTime)
    SkillRootMotion.__super.Update(self, deltaTime)

    if self.m_IsSkillStarted and self.m_IsHero then
        self.m_FrameCount = self.m_FrameCount + 1
        self:CheckAndSync()
    end
end

function SkillRootMotion:SetParamToCore(useColliderDetection, colliderRadiusOffset, acceptInputFromJoystick)
    self.m_Owner.m_Core:OnSyncState(StateDefine.k_StateSkill, useColliderDetection, colliderRadiusOffset, acceptInputFromJoystick)
end

--region 事件
function SkillRootMotion:OnSkillStart()
    self.m_IsSkillStarted = true
    self.m_FrameCount = 0
end

function SkillRootMotion:OnSkillEnd()
    self.m_IsSkillStarted = false
    if self.m_IsHero then
        local owner = self.m_Owner
        local posX, posY, posZ = owner:GetPositionXYZ()
        local angle = owner:GetAngle()
        BattleMessage.SendSkillMoveXYZ(posX, posY, posZ, angle, MoveSyncType.k_SkillMoveStop)
    end
end
--endregion

--region 同步
function SkillRootMotion:CheckAndSync()
    local moveAngle = self.m_Owner:GetStateTargetAngle(StateDefine.k_StateSkill)
    if self:NeedSync(moveAngle) then
        self:SyncMove(moveAngle)
    end
end

function SkillRootMotion:NeedSync(moveAngle)
    --if self.m_FrameCount % SyncConsts.k_SyncPosFrameCountPrecise == 0 then
    --    return true
    --end
    --if self.m_LastSyncAngle == nil or Mathf.DeltaAngle(self.m_LastSyncAngle, moveAngle) >= SyncConsts.k_SyncPosDifAngleMaxPrecise then
    --    return true
    --end
    return true
end

function SkillRootMotion:SyncMove(moveAngle)
    local owner = self.m_Owner
    local x, y, z = owner:GetPositionXYZ()
    BattleMessage.SendSkillMoveXYZ(x, y, z, moveAngle, MoveSyncType.k_SkillMove)
    self.m_LastSyncAngle = moveAngle
end

function SkillRootMotion:UpdateSyncInfo(syncInfo)
    SkillRootMotion.__super.UpdateSyncInfo(self, syncInfo)
    local owner = self.m_Owner
    self.m_CurrentSyncInfo = syncInfo
    local angle = syncInfo.m_Angle
    owner:SetStateTargetAngle(StateDefine.k_StateSkill, angle)
end
--endregion

return SkillRootMotion