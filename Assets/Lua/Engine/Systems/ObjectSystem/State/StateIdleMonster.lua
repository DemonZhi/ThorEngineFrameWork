---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/1/26 20:06
---
local StateDefine = SGEngine.Core.StateDefine
local StateIdleMonster = class("StateIdleMonster", StateBase)
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local Core_EntityUtility = SGEngine.Core.EntityUtility

local TurnType = {
    None = 0,
    TurnToTarget = 1,
    TurnToDir = 2,
}

function StateIdleMonster.Ctor(owner, stateComponent)
    StateIdleMonster.__super.Ctor(owner, stateComponent)
end

local function ClearAllParam(stateIdleParam)
    if stateIdleParam == nil then
        return
    end

    stateIdleParam.m_Position = nil
    stateIdleParam.m_ActType = nil
    stateIdleParam.m_TurnType = nil
    stateIdleParam.m_TargetID = nil
    stateIdleParam.m_TargetAngle = nil
    stateIdleParam.m_TurnSpeed = nil
end

function StateIdleMonster.Init(owner, stateComponent)
    StateIdleMonster.__super.Init(owner, stateComponent)
    if stateComponent.m_StateIdleParam == nil then
        stateComponent.m_StateIdleParam = {}
    end
    local stateIdleParam = stateComponent.m_StateIdleParam
    local animationName = stateIdleParam.m_AnimationName
    if animationName == nil then
        owner:PlayAnimation(StateConsts.k_IdleAnimationName)
        ClearAllParam(stateIdleParam)
    else
        owner:PlayAnimation(animationName)
        stateIdleParam.m_AnimationName = nil
    end
end

function StateIdleMonster.Destroy(owner, stateComponent)
    StateIdleMonster.__super.Destroy(owner, stateComponent)
end

function StateIdleMonster.OnBeginMove(owner, stateComponent)
    owner:ChangeToMove()
end

function StateIdleMonster.Update(deltaTime, owner, stateComponent)
    StateIdleMonster.__super.Update(deltaTime, owner, stateComponent)
    StateIdleMonster.Turn(owner, stateComponent, deltaTime)
end

function StateIdleMonster.Turn(owner, stateComponent, deltaTime)
    local stateIdleParam = stateComponent.m_StateIdleParam
    local turnType = stateIdleParam.m_TurnType
    local targetID = stateIdleParam.m_TargetID
    local targetAngle = stateIdleParam.m_TargetAngle
    local target = ObjectManager.GetObject(targetID)
    local turnSpeed = stateIdleParam.m_TurnSpeed or owner.CurrentRotateSpeed
    if turnType == TurnType.TurnToTarget then
        if target ~= nil then
            local targetAngle = Core_EntityUtility.GetAngleBetweenObjects(targetID, owner:GetObjectID())
            local angle = Mathf.MoveTowardsAngle(owner:GetAngle(), targetAngle, turnSpeed * deltaTime)
            owner:SetAngle(angle)
        end
    elseif turnType == TurnType.TurnToDir then
        local angle = Mathf.MoveTowardsAngle(owner:GetAngle(), targetAngle, turnSpeed * deltaTime)
        owner:SetAngle(angle)
    end
end

function StateIdleMonster.OnStateIdle(owner)
    owner:ChangeToIdle()
end

return StateIdleMonster