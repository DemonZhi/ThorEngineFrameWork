--网络数据发送
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local BattleMessage = require("MainGame/Message/BattleMessage")
---@class StateDodge:StateBase
local StateDodge = class("StateDodge", StateBase)
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
local SyncConsts = ComponentDefine.SyncConsts
local AttributeDefine = ComponentDefine.AttributeDefine
local StateDefine = SGEngine.Core.StateDefine
local k_EffectID = 5
StateDodge.k_DodgeSpeed = 20
local DodgeStateEnum = {
    None = 0,
    Dodging = 1,
    DodgeFinish = 2,
}

local k_DefaultEventMap = {}
k_DefaultEventMap["fs"] = 0
k_DefaultEventMap["rs"] = 1.8
k_DefaultEventMap["end"] = 2

function StateDodge.Ctor(owner, stateComponent)
    StateDodge.__super.Ctor(owner, stateComponent)
    if stateComponent.m_StateDodgeParam == nil then
        stateComponent.m_StateDodgeParam = {}
    end
end

function StateDodge.Init(owner, stateComponent)
    StateDodge.__super.Init(owner, stateComponent)
    local stateDodgeParam = stateComponent.m_StateDodgeParam
    stateDodgeParam.m_IsHero = owner:IsHero()
    stateDodgeParam.m_DodgeState = DodgeStateEnum.None
    stateDodgeParam.m_FrameCount = 0
    stateDodgeParam.m_EventMap = nil
    stateDodgeParam.m_StopPosition = nil
    if owner:IsHero() then
        local inputManager = SGEngine.Core.InputManager.Instance
        if inputManager.IsTouching then
            owner:SetAngle(inputManager.JoystickAngle)
        end
    end
    if owner:ContainAnimation(StateConsts.k_DodgeAnimationName) then
        StateDodge.PlayAnimation(owner, StateConsts.k_DodgeAnimationName,0.1, function(eventName)
            StateDodge.OnDodgeEvent(owner, stateComponent, eventName)
        end)
    else
        stateDodgeParam.m_EventMap = k_DefaultEventMap
        stateDodgeParam.m_LastCheckTime = 0
        stateDodgeParam.m_BeginTime = Time.time
    end
    --if owner:ContainAnimation(StateConsts.k_DodgeAnimationName) then
    --    owner:PlayAnimation(StateConsts.k_DodgeAnimationName)
    --end
    --stateDodgeParam.m_EventMap = k_DefaultEventMap
    --stateDodgeParam.m_LastCheckTime = 0
    --stateDodgeParam.m_BeginTime = Time.time

    owner:SetCurrentMoveSpeed(StateDodge.k_DodgeSpeed)
    owner:SetCurrentGravity(-owner.m_AttrComponent:GetAttribute(AttributeDefine.k_FallGravity))

    if stateDodgeParam.m_IsHero then
        owner.m_EffectComponent:PlayNormalEffect(k_EffectID)
        StateDodge.SyncStateDodge(owner)
    end
end

function StateDodge.Update(deltaTime, owner, stateComponent)
    local stateDodgeParam = stateComponent.m_StateDodgeParam

    if stateDodgeParam.m_EventMap then
        StateDodge.UpdateEventByEventMap(owner, stateComponent, stateDodgeParam)
    end

    if stateDodgeParam.m_DodgeState ~= DodgeStateEnum.Dodging then
        return
    end

    if owner == nil then
        return
    end
    if stateDodgeParam.m_IsHero then
        StateDodge.CheckSync(owner, stateDodgeParam)
    end
end

function StateDodge.UpdateEventByEventMap(owner, stateComponent, stateDodgeParam)
    local eventMap = stateDodgeParam.m_EventMap
    local beginTime = stateDodgeParam.m_BeginTime
    local lastCheckTime = stateDodgeParam.m_LastCheckTime

    local passedTime = Time.time - beginTime
    for eventName, time in pairs(eventMap) do
        if time >= lastCheckTime and time < passedTime then
            stateDodgeParam.m_LastCheckTime = passedTime
            StateDodge.OnDodgeEvent(owner, stateComponent, eventName)
            return
        end
    end
    stateDodgeParam.m_LastCheckTime = passedTime
end

function StateDodge.Destroy(owner, stateComponent)
    local stateDodgeParam = stateComponent.m_StateDodgeParam
    if stateDodgeParam.m_IsHero then
        StateDodge.SyncStateDodgeEnd(owner)
    end
    stateDodgeParam.m_DodgeState = DodgeStateEnum.DodgeFinish

    owner:SetCurrentGravity(0)
    StateDodge.__super.Destroy(owner)
end

function StateDodge.SetStopParamToCore(owner, position, angle)
    owner.m_Core:OnSyncState(StateDefine.k_StateDodge, position.x, position.y, position.z)
end

function StateDodge.SetCoreMoving(owner, isMoving)
    owner.m_Core:OnSyncState(StateDefine.k_StateDodge, isMoving)
end

function StateDodge.OnDodgeEvent(owner, stateComponent, eventName)
    local stateDodgeParam = stateComponent.m_StateDodgeParam
    if eventName == AnimationEventDefines.k_EventFrontSwing then
        --Logger.LogInfo("StateDodge.OnDodgeEvent  k_EventFrontSwing")
        StateDodge.SetCoreMoving(owner, true)
        stateDodgeParam.m_DodgeState = DodgeStateEnum.Dodging
    elseif eventName == AnimationEventDefines.k_EventRearSwing then
        --Logger.LogInfo("StateDodge.OnDodgeEvent  k_EventRearSwing")
        StateDodge.SetCoreMoving(owner, false)
        stateDodgeParam.m_DodgeState = DodgeStateEnum.DodgeFinish
    elseif eventName == AnimationEventDefines.k_EventEnd then
        --Logger.LogInfo("StateDodge.OnDodgeEvent  k_EventEnd")
        if stateDodgeParam.m_StopPosition ~= nil then
            owner:SetPosition(stateDodgeParam.m_StopPosition)
            owner:SetAngle(stateDodgeParam.m_StopAngle)
        end
        owner:DelState(StateDefine.k_StateDodge, nil)
    end
end

--------------------------------------------------------------------Sync---------------------------------------------------------------------------------
function StateDodge.CheckSync(owner, stateDodgeParam)
    if StateDodge.NeedSync(owner, stateDodgeParam) == false then
        return
    end
    --同步位置
    StateDodge.SyncStateDodgePos(owner)
end

function StateDodge.NeedSync(owner, stateDodgeParam)
    if stateDodgeParam.m_FrameCount % SyncConsts.k_SyncPosFrameCountPrecise == 0 then
        return true
    end
    return false
end

function StateDodge.SyncStateDodge(owner)
    local x, y, z = owner:GetPositionXYZ()
    local angle = owner:GetAngle()
    BattleMessage.SendStateDodge(x, y, z, angle)
end

function StateDodge.SyncStateDodgeEnd(owner)
    local x, y, z = owner:GetPositionXYZ()
    local angle = owner:GetAngle()
    BattleMessage.SendStateDodgeEnd(x, y, z, angle)
end

function StateDodge.SyncStateDodgePos(owner)
    local position = owner:GetPosition()
    BattleMessage.SendStateDodgePos(position)
end

function StateDodge.OnSyncStateDodge(owner)
    if owner == nil then
        Logger.LogInfo("[StateDodge](OnSyncStateDodge) owner nil")
        return
    end
    --Logger.LogInfo("[StateDodge](OnSyncStateDodge), %s, objId: %s", Time.frameCount, owner:GetObjectID())
    owner:ChangeToDodge()
end

function StateDodge.OnSyncStateDodgeEnd(owner, stopPosition, stopAngle)
    local componentState = owner.m_StateComponent
    local stateDodgeParam = componentState.m_StateDodgeParam
    stateDodgeParam.m_StopPosition = stopPosition
    stateDodgeParam.m_StopAngle = stopAngle
    --Logger.LogInfo("[StateDodge](OnSyncStateDodgeEnd):{%f},{%f},{%f}, , %s, objId: %s", stopPosition.x, stopPosition.y, stopPosition.z,  Time.frameCount, owner:GetObjectID())
    StateDodge.SetStopParamToCore(owner, stopPosition, stopAngle)
end

function StateDodge.OnBeginMove(owner, stateComponent)
    --if owner:IsHero() == false then
    --    return
    --end
    local stateDodgeParam = stateComponent.m_StateDodgeParam
    if stateDodgeParam.m_DodgeState == DodgeStateEnum.DodgeFinish then
        --Logger.LogInfo("stateDodgeParam.m_IsInitSprint, %s", stateDodgeParam.m_IsInitSprint)
        owner:DelState(StateDefine.k_StateDodge, nil)
        owner:ChangeToMove(nil, stateDodgeParam.m_IsInitSprint)
    end
end

return StateDodge