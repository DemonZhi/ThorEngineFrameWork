---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/3/9 16:34
---

local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local BattleMessage = require("MainGame/Message/BattleMessage")
---@class SkillCharge:SkillBase
local SkillCharge = class("SkillCharge", SkillBase)
local StateDefine = SGEngine.Core.StateDefine
local SyncConsts = ComponentDefine.SyncConsts
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
local MoveSyncType = ComponentDefine.MoveSyncType
SkillCharge.k_IdleAnimationSuffix = "_idle"
SkillCharge.k_PreAnimationSuffix = "_pre"
SkillCharge.k_MoveAnimationSuffix = "_move"
SkillCharge.SkillChargeStageEnum = {
    ChargePre = 1,
    Charging = 2,
    Cast = 3
}

function SkillCharge:Ctor()
    SkillCharge.__super.Ctor(self)
end

function SkillCharge:Init(object, skillConfig, targetObjectId)
    self.m_Owner = object
    self.m_Config = skillConfig
    if not skillConfig then
        Logger.LogError("[SkillBase]Init:Empty Skill Config")
        return
    end
    self.m_SkillId = skillConfig.ID
    self.m_TargetObjectId = targetObjectId
    self.m_IsMoving = false
    self.m_IsBreakable = false
    self.m_HasPassedRearSwing = false
    self.m_FrameCount = 0
    self.m_StateIndex = 1
    self.m_IsHandleJoyStickEvent = true
    local params = skillConfig.SkillModuleParams
    self.m_ChargeTimeList = params.m_TimeList
    self.m_ChargeSkillList = params.m_SkillIdList
    self.m_StartTime = Time.time
    self.m_CanMove = self.m_Config.MovingSpeed > 0
    local aniName = skillConfig.AnimName
    self.m_PreAnimationName = aniName..SkillCharge.k_PreAnimationSuffix
    self.m_MoveAnimationName = aniName..SkillCharge.k_MoveAnimationSuffix
    self.m_IdleAnimationName = aniName..SkillCharge.k_IdleAnimationSuffix
    self.m_Owner.m_Core:UseSkill(skillConfig.ID, skillConfig.SkillModule, targetObjectId, self.m_PreAnimationName, self:GetParams())
    self.m_Stage = SkillCharge.SkillChargeStageEnum.ChargePre
    --Logger.LogInfo("Init." ..tostring(Time.time))
    self:SetCoreInitParam()
end

function SkillCharge:SetCoreInitParam()
    local owner = self.m_Owner
    if owner == nil then
        return
    end
    owner:SetCurrentMoveSpeed(self.m_Config.MovingSpeed)
    owner:SetCurrentRotateSpeed(self.m_Config.RotateSpeed)
end

function SkillCharge:Destroy()
    --Logger.LogInfo("Des")
    self:OnSkillMoveStop()
    SkillCharge.__super.Destroy(self)
end

function SkillCharge:Update(deltaTime)
    SkillCharge.__super.Update(self, deltaTime)
    self.m_FrameCount = self.m_FrameCount + 1
    if self.m_IsMoving == true then
        self:CheckSync()
    end

    if self.m_Stage ~= SkillCharge.SkillChargeStageEnum.Charging then
        return
    end

    self:CheckAnimation()
    local spendTime = Time.time - self.m_StartTime
    local chargeTime = self.m_ChargeTimeList[self.m_StateIndex]
    if chargeTime < spendTime then
        self.m_StateIndex  = self.m_StateIndex + 1
    end

    if self.m_StateIndex > #self.m_ChargeTimeList then
        self.m_StateIndex = #self.m_ChargeTimeList
        self:UseFinalSkill()
    end
end

function SkillCharge:CheckAnimation()
    if self.m_CanMove and self.m_IsMoving then
        if self.m_Owner:IsPlayingAnimation(self.m_MoveAnimationName) == false then
            self.m_Owner:PlayAnimation(self.m_MoveAnimationName)
        end
    else
        if self.m_Owner:IsPlayingAnimation(self.m_IdleAnimationName) == false then
            self.m_Owner:PlayAnimation(self.m_IdleAnimationName)
        end
    end
end

function SkillCharge:UseFinalSkill()
    if self.m_Stage == SkillCharge.SkillChargeStageEnum.Cast then
       return
    end
    self.m_Stage = SkillCharge.SkillChargeStageEnum.Cast
    local finalSkillId = self.m_ChargeSkillList[self.m_StateIndex]
    --Logger.LogInfo("UseSKill." ..tostring(Time.time))
    self.m_Owner:UseSkill(finalSkillId)
end

--region 同步
function SkillCharge:SyncMove(targetAngle)
    local owner = self.m_Owner
    if not targetAngle then
        targetAngle = self.m_Owner:GetAngle()
    end
    if owner == nil then
        return
    end
    local pos = owner:GetPosition()
    local predictStepCount = SyncConsts.k_SyncPosPredictCount
    if predictStepCount > 0 then
        pos = owner:PredictPosOnGroundByController(targetAngle, owner:GetCurrentMoveSpeed(), predictStepCount)
    end

    BattleMessage.SendSkillMove(pos, targetAngle, MoveSyncType.k_SkillMove)
end

function SkillCharge:SyncStop()
    local owner = self.m_Owner
    if owner == nil then
        return
    end

    local posX, posY, posZ = owner:GetPositionXYZ()
    local angle = owner:GetAngle()
    BattleMessage.SendSkillMoveXYZ(posX, posY, posZ, angle, MoveSyncType.k_SkillMoveStop)
end

function SkillCharge:CheckSync()
    local targetAngle = self.m_Owner:GetAngle()
    if self:NeedSync(targetAngle) then
        self:SyncMove(targetAngle)
    end
end

function SkillCharge:NeedSync(targetAngle)
    if not self.m_IsMoving then
        return false
    end
    if self.m_FrameCount % SyncConsts.k_SyncPosFrameCount == 0 then
        return true
    end
    local currentAngle = self.m_Owner:GetAngle()
    if (targetAngle - currentAngle) >= SyncConsts.k_SyncPosDifAngle then
        return true
    end
    return false
end

function SkillCharge:SetCoreMove(active)
    self:SetParamToCore(active)
end
--endregion

function SkillCharge:OnSkillMove()
    if not self.m_IsMoving and self.m_Stage == SkillCharge.SkillChargeStageEnum.Charging then
        self:SetCoreMove(true)
        self.m_IsMoving = true
        self:SyncMove()
    end
end

function SkillCharge:OnSkillMoveStop()
    if self.m_IsMoving == true then
        self:SetCoreMove(false)
        self.m_IsMoving = false
        self:SyncStop()
    end
end

--region 事件
function SkillCharge:OnSkillEvent(eventName)
    SkillCharge.__super.OnSkillEvent(self, eventName)
    if eventName == AnimationEventDefines.k_EventRearSwing then
        self.m_HasPassedRearSwing = true
        if self.m_IsCharging == false  then
            self:UseFinalSkill()
        end
    end

    if eventName == AnimationEventDefines.k_EventEnd then
        self.m_Stage = SkillCharge.SkillChargeStageEnum.Charging
        self:CheckAnimation()
    end
end
--endregion

function SkillCharge:OnSkillButtonDown()
    --Logger.LogInfo("OnSkillButtonDown."..Time.frameCount)
    self.m_IsCharging = true
end

function SkillCharge:OnSkillButtonUp()
    --Logger.LogInfo("OnSkillButtonUp."..Time.frameCount)
    self.m_IsCharging = false
    if self.m_Stage == SkillCharge.SkillChargeStageEnum.Charging or self.m_HasPassedRearSwing == true then
        self:UseFinalSkill()
    end
end

return SkillCharge