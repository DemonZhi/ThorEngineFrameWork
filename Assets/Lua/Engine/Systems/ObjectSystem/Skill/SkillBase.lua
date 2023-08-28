---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/12/1 10:31
---
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
local StateDefine = SGEngine.Core.StateDefine
---@class SkillBase
local SkillBase = class("SkillBase")
function SkillBase:Ctor()
    self.m_IsActive = false
end

function SkillBase:Init(object, skillConfig, targetObjectId)
    self.m_IsHandleJoyStickEvent = true    ---是否接受从状态机传来的摇杆事件
    self.m_Owner = object
    self.m_Config = skillConfig
    self.m_TargetObjectId = targetObjectId
    self.m_IsBreakable = false
    if not skillConfig then
        Logger.LogError("[SkillBase]Init:Empty Skill Config")
        return
    end
    self.m_SkillId = skillConfig.ID
    if self.m_Owner:IsHero() then
        self.m_Owner.m_Core:UseSkill(skillConfig.ID, skillConfig.SkillModule, targetObjectId, skillConfig.AnimName, self:GetParams())
    else
        self.m_Owner.m_Core:RawUseSkill(skillConfig.ID, skillConfig.SkillModule, targetObjectId, skillConfig.AnimName, self:GetParams())
    end
    self:SetCoreInitParam()
end

function SkillBase:SetCoreInitParam()
    local owner = self.m_Owner
    if owner == nil then
        return
    end

    owner:SetCurrentMoveSpeed(owner:GetMoveSpeed())
    owner:SetCurrentRotateSpeed(owner:GetRotateSpeed())
end

function SkillBase:Destroy()
    self.m_Owner = nil
    self.m_Config = nil
end

function SkillBase:Update(deltaTime)
end

function SkillBase:IsValid()
    return self.m_IsActive
end

function SkillBase:SetValid(active)
    self.m_IsActive = active
end

function SkillBase:GetParams()
    return nil
end

--region 事件
function SkillBase:OnSkillStart()

end

function SkillBase:OnSkillEnd()

end

function SkillBase:OnSkillEvent(eventName)
    if eventName == AnimationEventDefines.k_EventRearSwing then
        self.m_IsBreakable = true
    end
end

function SkillBase:OnSkillRearSwing()
end

function SkillBase:OnSkillFrontSwing()
end

function SkillBase:OnSkillMove()
    if self:IsBreakable() then
        self.m_Owner:ChangeToMove()
    end
end

function SkillBase:OnSkillMoveStop()
end

function SkillBase:IsBreakable()
    return self.m_IsBreakable
end

function SkillBase:GetTargetID()
    return self.m_TargetObjectId
end
--endregion

function SkillBase:UpdateSyncInfo(syncInfo)
    local position = syncInfo.m_TargetPosition
    self.m_Owner:SetPositionXYZ(position.x, position.y, position.z)
    self.m_Owner:SetAngle(syncInfo.m_Angle)
end

function SkillBase:SetParamToCore(...)
    self.m_Owner.m_Core:OnSyncState(StateDefine.k_StateSkill, ...)
end

return SkillBase