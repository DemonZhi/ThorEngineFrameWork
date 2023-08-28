---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/1/26 20:47
---
local StateDefine = SGEngine.Core.StateDefine
---@class StateMove3rd : StateMove
local StateMove3rd = class("StateMove3rd", StateMove)
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local StateDefine = SGEngine.Core.StateDefine
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
local SyncConsts = ComponentDefine.SyncConsts
local MoveSyncType = ComponentDefine.MoveSyncType

function StateMove3rd.Ctor(owner, stateComponent)
    StateMove3rd.__super.Ctor(owner, stateComponent)
    if stateComponent.m_StateMoveParam == nil then
        stateComponent.m_StateMoveParam = {}
    end
    local stateParam = stateComponent.m_StateMoveParam
    stateParam.m_IsSprint = false
    stateParam.m_PredictStep = 0
    stateParam.m_CoreHasStopped = false
end

function StateMove3rd.Init(owner, stateComponent)
    StateMove3rd.__super.Init(owner, stateComponent)
    StateMove3rd.CheckAnimation(owner, stateComponent)
end

function StateMove3rd.Run(owner)
    --Logger.LogInfo("Run")
    local aniNam = StateMove3rd.GetRunAnimationName(owner)
    if owner:IsPlayingAnimation(aniNam) == false  then
        local attributeDefine = ComponentDefine.AttributeDefine
        local moveSpeed = owner.m_AttrComponent:GetAttribute(attributeDefine.k_MoveSpeed)
        local rotateSpeed = owner.m_AttrComponent:GetAttribute(attributeDefine.k_RotateSpeed)
        owner:SetCurrentMoveSpeed(moveSpeed)
        owner:SetCurrentRotateSpeed(rotateSpeed)
        StateMove3rd.PlayAnimation(owner, aniNam)
    end
    StateMove3rd.SetParamToCore(owner, false)
end

function StateMove3rd.Sprint(owner)
    --Logger.LogInfo("Sprint")
    if owner:IsPlayingAnimation(StateConsts.k_SprintAnimationName) == false  then
        local attributeDefine = ComponentDefine.AttributeDefine
        local moveSpeed = owner.m_AttrComponent:GetAttribute(attributeDefine.k_SprintSpeed)
        local rotateSpeed = owner.m_AttrComponent:GetAttribute(attributeDefine.k_SprintRotateSpeed)
        owner:SetCurrentMoveSpeed(moveSpeed)
        owner:SetCurrentRotateSpeed(rotateSpeed)
        StateMove3rd.PlayAnimation(owner, StateConsts.k_SprintAnimationName)
    end
    StateMove3rd.SetParamToCore(owner, false)
end

function StateMove3rd.RideRun(owner)
    --Logger.LogInfo("RideRun")
    local rideData = owner.m_StateComponent.m_StateRideParam
    if not rideData then
        return
    end
    local config = rideData.m_MountConfig
    if not config then
        return
    end

    StateMove3rd.SetParamToCore(owner, true)
    if owner:IsPlayingAnimation(config.RunAnimation) == false  then
        owner:SetCurrentMoveSpeed(config.MoveSpeed)
        owner:SetCurrentRotateSpeed(config.RotateSpeed)
        StateMove3rd.PlayAnimation(owner, config.RunAnimation, 0)
    end

    local mount = rideData.m_Mount
    if not mount then
        return
    end
    if mount:IsModelLoadFinish() == true then
        if mount:IsPlayingAnimation(StateConsts.k_RunAnimationName) == false  then
            mount:PlayAnimation(StateConsts.k_RunAnimationName, 0, 0.1)
        end
    end
    StateMove3rd.RideRunBegin(owner)
end

function StateMove3rd.Destroy(owner, stateComponent)
    local stateMoveParam = stateComponent.m_StateMoveParam
    owner:UnRegAnimationCallBack(StateConsts.k_RunStopAnimationName)
    stateMoveParam.m_IsSprint = false
    stateMoveParam.m_CoreHasStopped = false
    stateMoveParam.m_PredictStep = 0
    stateMoveParam.m_ShouldCacheSyncInfo = false
    --stateMoveParam.m_IsSprintStopping = false
    StateMove3rd.__super.Destroy(owner, stateComponent)
end

function StateMove3rd.Update(deltaTime, owner, stateComponent)
    --local stateParam = stateComponent.m_StateMoveParam
    --if owner:IsState(StateDefine.k_StateMove) == false then
    --    return
    --end

    --if stateParam.m_IsSprintStopping == false then
    --    return
    --end
    --
    --if stateParam.m_UsingRootMotion == false then
    --    local syncInfo = stateParam.m_CurrentSyncInfo
    --    local angle = syncInfo.m_Angle
    --    local predictPos = owner:PredictPosOnGroundByController(angle, syncInfo.speed, 1)
    --    owner:SetPosition(predictPos)
    --    owner:SetAngle(angle)
    --end

    if not stateComponent.m_StateMoveParam.m_CoreHasStopped then
        return
    end

    if stateComponent.m_StateMoveParam.m_CurrentSyncInfo == nil then
        ---可能是跳跃结束的时候直接调了Move，没有SyncInfo
        return
    end

    if StateMove3rd.CheckPredict(owner) then
        StateMove3rd.PredictMove(owner)
    else
        local type = stateComponent.m_StateMoveParam.m_CurrentSyncInfo.m_SyncType
        if type ~= MoveSyncType.k_RideMoveStop and type ~= MoveSyncType.k_SprintStop and type ~= MoveSyncType.k_SprintTurn then
            StateMove3rd.StopMove(owner)
        end
    end
end

function StateMove3rd.SprintEnd(owner)
    --Logger.LogInfo("OnSprintEnd")
    owner.m_StateComponent.m_StateMoveParam.m_IsSprintStopping = false
end

function StateMove3rd.OnBeginMove(owner, stateComponent)
    StateMove3rd.CheckAnimation(owner, stateComponent)
end

function StateMove3rd.OnStopMove(owner, stateComponent)
    stateComponent.m_StateMoveParam.m_CoreHasStopped = true
    if stateComponent.m_StateMoveParam.m_CurrentSyncInfo == nil then
        ---可能是跳跃结束的时候直接调了Move，没有SyncInfo
        local isSprint = stateComponent.m_StateMoveParam.m_IsSprint
        if isSprint == true then
            StateMove3rd.StopSprint(owner)
        else
            StateMove3rd.StopMove(owner)
        end
        return
    end
    local type = stateComponent.m_StateMoveParam.m_CurrentSyncInfo.m_SyncType
    --Logger.LogInfo("StateMove3rd.OnStopMove: type:%s", type)
    if type == MoveSyncType.k_MoveStop or type == MoveSyncType.k_SprintStop or type == MoveSyncType.k_RideMoveStop then
        local isSprint = StateMove3rd.IsSprint(type)
        --if isSprint then
        --    stateParam.m_IsSprintStopping = true
        --end
        if owner:IsState(StateDefine.k_StateRide) then
            StateMove3rd.StopRideMove(owner)
        elseif isSprint then
            StateMove3rd.StopSprint(owner)
        else
            StateMove3rd.StopMove(owner)
        end
    elseif type == MoveSyncType.k_SprintTurn then
        StateMove3rd.SprintTurn(owner)
    end
end

function StateMove3rd.CheckPredict(owner)
    local stateComponent = owner.m_StateComponent
    local stateParam = stateComponent.m_StateMoveParam
    if not stateParam.m_CurrentSyncInfo then
        return false
    end
    local syncType = stateParam.m_CurrentSyncInfo.m_SyncType
    if stateParam.m_PredictStep > SyncConsts.k_Max3rdPredictStep then
        --Logger.LogInfo("Return false  MaxPredictStep:{%d}, frameCount{%d}", stateParam.m_PredictStep, Time.frameCount)
        return false
    end

    if syncType == MoveSyncType.k_Sprint
            or syncType == MoveSyncType.k_Move or syncType == MoveSyncType.k_RideMove then
        return true
    end
    --Logger.LogInfo("Return false  All false:m_PredictStep:{%d},syncType:{%d}, frameCount{%d}", stateParam.m_PredictStep, syncType, Time.frameCount)
    return false
end

function StateMove3rd.CheckAnimation(owner, stateComponent)
    local currentSyncInfo = stateComponent.m_StateMoveParam.m_CurrentSyncInfo

    if owner:IsState(StateDefine.k_StateRide) then
        stateComponent.m_StateMoveParam.m_IsSprint = false
        StateMove3rd.RideRun(owner)
    else
        ---可能是跳跃结束的时候直接调了Move，没有SyncInfo
        if currentSyncInfo ~= nil then
            local type = currentSyncInfo.m_SyncType
            stateComponent.m_StateMoveParam.m_IsSprint = StateMove3rd.IsSprint(type)
        end
        local isSprint = stateComponent.m_StateMoveParam.m_IsSprint
        if isSprint == true then
            StateMove3rd.Sprint(owner)
        else
            StateMove3rd.Run(owner)
        end
    end
end

function StateMove3rd.GetMoveSpeed(owner, syncType)
    local currentMoveType = syncType
    local attributeDefine = ComponentDefine.AttributeDefine
    if currentMoveType == MoveSyncType.k_Move or currentMoveType == MoveSyncType.k_MoveStop then
        return owner.m_AttrComponent:GetAttribute(attributeDefine.k_MoveSpeed)
    elseif currentMoveType == MoveSyncType.k_Sprint or currentMoveType == MoveSyncType.k_SprintStop or currentMoveType == MoveSyncType.k_SprintTurn then
        return owner.m_AttrComponent:GetAttribute(attributeDefine.k_SprintSpeed)
    elseif currentMoveType == MoveSyncType.k_RideMove or currentMoveType == MoveSyncType.k_RideMoveStop then
        local config = owner.m_StateComponent.m_StateRideParam.m_MountConfig
        if config == nil then
            return owner.m_AttrComponent:GetAttribute(attributeDefine.k_MoveSpeed)
        end
        return config.MoveSpeed
    end
end

function StateMove3rd.GetRotateSpeed(owner, syncType)
    local currentMoveType = syncType
    local attributeDefine = ComponentDefine.AttributeDefine
    if currentMoveType == MoveSyncType.k_Move or currentMoveType == MoveSyncType.k_MoveStop then
        return owner.m_AttrComponent:GetAttribute(attributeDefine.k_RotateSpeed)
    elseif currentMoveType == MoveSyncType.k_Sprint or currentMoveType == MoveSyncType.k_SprintStop or currentMoveType == MoveSyncType.k_SprintTurn then
        return owner.m_AttrComponent:GetAttribute(attributeDefine.k_SprintRotateSpeed)
    elseif currentMoveType == MoveSyncType.k_RideMove or currentMoveType == MoveSyncType.k_RideMoveStop then
        local config = owner.m_StateComponent.m_StateRideParam.m_MountConfig
        if config == nil then
            return owner.m_AttrComponent:GetAttribute(attributeDefine.k_RotateSpeed)
        end
        return config.RotateSpeed
    end
end

function StateMove3rd.GetTargetAngle(owner, syncInfo)
    if owner:IsState(StateDefine.k_StateRide) then
        return syncInfo.m_JoystickAngle
    end
    return syncInfo.m_Angle
end

function StateMove3rd.PredictMove(owner)
    local stateComponent = owner.m_StateComponent
    local stateParam = stateComponent.m_StateMoveParam
    stateParam.m_PredictStep = stateParam.m_PredictStep + 1
    --Logger.LogDebug("PredictMove:{%d}, frameCount{%d}", stateParam.m_PredictStep, Time.frameCount)
    local syncInfo = stateParam.m_CurrentSyncInfo
    local angle = syncInfo.m_Angle
    local moveSpeed = StateMove3rd.GetMoveSpeed(owner, syncInfo.m_SyncType)
    owner:PredictMoveOnGroundByPhysics(angle, moveSpeed, 1)
end

function StateMove3rd.OnStateMoveGround(owner, syncInfo)
    if not syncInfo then
        return
    end
    local stateComponent = owner.m_StateComponent
    local stateParam = stateComponent.m_StateMoveParam
    stateParam.m_CoreHasStopped = false
    stateParam.m_PredictStep = 0
    if stateParam.m_ShouldCacheSyncInfo == true then
        --Logger.LogInfo("CacheSyncInfoTo:{%f},{%f},{%f}, angle:%f,joy:%f, frameCount:%d,  type:%d",
        --        syncInfo.m_TargetPosition.x, syncInfo.m_TargetPosition.y, syncInfo.m_TargetPosition.z, syncInfo.m_Angle,
        --        syncInfo.joystickAngle, Time.frameCount, syncInfo.m_SyncType)
        stateParam.m_CachedSyncInfo = syncInfo
        return
    end
    stateParam.m_CurrentSyncInfo = syncInfo
    stateParam.m_CachedSyncInfo = nil
    local type = syncInfo.m_SyncType
    StateMove3rd.AdjustSpeed(owner, syncInfo)
    --Logger.LogInfo("UpdateSyncInfoTo:{%f},{%f},{%f}, angle:%f,joy:%f, frameCount:%d,  type:%d",
    --        syncInfo.m_TargetPosition.x, syncInfo.m_TargetPosition.y, syncInfo.m_TargetPosition.z, syncInfo.m_Angle,
    --        syncInfo.m_JoystickAngle, Time.frameCount, syncInfo.m_SyncType)
    if type == MoveSyncType.k_Move or type == MoveSyncType.k_Sprint or type == MoveSyncType.k_RideMove then
        local angle = StateMove3rd.GetTargetAngle(owner, syncInfo)
        owner.m_MoveComponent:Move(syncInfo.m_TargetPosition, angle)
    elseif type == MoveSyncType.k_MoveStop or type == MoveSyncType.k_SprintStop or type == MoveSyncType.k_RideMoveStop or type == MoveSyncType.k_SprintTurn then
        local position = syncInfo.m_TargetPosition:Clone()
        local time = Time.deltaTime
        local angle = syncInfo.m_Angle
        local moveSpeed = StateMove3rd.GetMoveSpeed(owner, type)
        position = position:Sub(owner:GetPosition())
        if position:SqrMagnitude() > moveSpeed * time * moveSpeed * time then
            ---fix y
            ---急转要让动画转完再转
            if type == MoveSyncType.k_SprintTurn then
                owner.m_MoveComponent:Move(syncInfo.m_TargetPosition, nil)
            else
                owner.m_MoveComponent:Move(syncInfo.m_TargetPosition, angle)
            end
        else
            owner:SetPosition(syncInfo.m_TargetPosition)
            ---急转要让动画转完再转
            if type ~= MoveSyncType.k_SprintTurn then
                owner:SetAngle(angle)
            end
            owner.m_Core:OnJoyStickRelease()
        end
    --elseif type == MoveSyncType.k_SkillMove or type == MoveSyncType.k_SkillMoveStop then
    --    owner.m_SkillComponent:OnStateSkillMove(syncInfo)
    end
end

---todo 这里可以优化一下不用每次都SetSpeed
function StateMove3rd.AdjustSpeed(owner, syncInfo)
    local position = owner:GetPosition()
    local positionDif = position:Sub(syncInfo.m_TargetPosition)
    local moveSpeed = StateMove3rd.GetMoveSpeed(owner, syncInfo.m_SyncType)
    if positionDif:SqrMagnitude() > (SyncConsts.k_MaxPositionDifference * SyncConsts.k_MaxPositionDifference) then
        --Logger.LogInfo("SpeedUp")
        moveSpeed = moveSpeed * 1.2
        owner:SetCurrentMoveSpeed(moveSpeed)
    else
        owner:SetCurrentMoveSpeed(moveSpeed)
    end
end

function StateMove3rd.IsSprint(type)
    return type == MoveSyncType.k_Sprint or type == MoveSyncType.k_SprintStop or type == MoveSyncType.k_SprintTurn
end

function StateMove3rd.StopMove(owner)
    if owner:ContainAnimation(StateConsts.k_RunStopAnimationName) then
        local stateComponent = owner.m_StateComponent
        stateComponent.m_StateMoveParam.m_IsSprint = nil
        owner.m_MoveComponent:StopMove()
        StateMove3rd.PlayAnimation(owner, StateConsts.k_RunStopAnimationName, 0.1, function(eventName)
            if (eventName == AnimationEventDefines.k_EventEnd) then
                owner.m_Core:DelState(StateDefine.k_StateMove)
            end
        end)
    else
        owner.m_Core:DelState(StateDefine.k_StateMove)
    end
end

function StateMove3rd.StopSprint(owner)
    StateMove3rd.PlayAnimation(owner, StateConsts.k_SprintStopAnimationName, 0.1, function(eventName)
        if eventName == AnimationEventDefines.k_EventRearSwing then
            local stateComponent = owner.m_StateComponent
            stateComponent.m_StateMoveParam.m_IsSprintStopping = false
            StateMove3rd.SprintEnd(owner)
        elseif (eventName == AnimationEventDefines.k_EventEnd) then
            owner.m_Core:DelState(StateDefine.k_StateMove)
        end
    end)
end

function StateMove3rd.SprintTurn(owner)
    owner.m_StateComponent.m_StateMoveParam.m_ShouldCacheSyncInfo = true
    StateMove3rd.PlayAnimation(owner, StateConsts.k_SprintTurnAnimationName, 0.1, function(eventName)
        if eventName == AnimationEventDefines.k_EventEnd then
            local stateComponent = owner.m_StateComponent
            local angle = stateComponent.m_StateMoveParam.m_CurrentSyncInfo.m_Angle
            owner:SetAngle(angle)
            --Logger.LogInfo("SprintTurn:SetAngle:" ..tostring(angle))
            stateComponent.m_StateMoveParam.m_ShouldCacheSyncInfo = false
            local syncInfo = stateComponent.m_StateMoveParam.m_CachedSyncInfo
            if syncInfo == nil then
                return
            end
            --Logger.LogInfo("Use CachedSyncInfoTo:{%f},{%f},{%f}, angle:%f,joy:%f, frameCount:%d,  type:%d",
            --        syncInfo.m_TargetPosition.x, syncInfo.m_TargetPosition.y, syncInfo.m_TargetPosition.z, syncInfo.m_Angle,
            --        syncInfo.joystickAngle, Time.frameCount, syncInfo.m_SyncType)
            StateMove3rd.OnStateMoveGround(owner, syncInfo)
        end
    end)
end

function StateMove3rd.StopRideMove(owner)
    local stateRideData = owner.m_StateComponent.m_StateRideParam
    local config = stateRideData.m_MountConfig
    local mount = stateRideData.m_Mount
    StateMove3rd.PlayAnimation(owner, config.RunStopAnimation, 0.1, function(eventName)
        StateMove3rd.OnRideMoveStopEvent(owner, eventName)
    end)
    if mount:IsModelLoadFinish() == true then
        mount:PlayAnimation(StateConsts.k_RunStopAnimationName, 0, 0.1)
    end
    StateMove3rd.RideMoveStop(owner)
end

function StateMove3rd.OnRideMoveStopEvent(owner, eventName)
    if eventName == AnimationEventDefines.k_EventRearSwing then
        StateMove3rd.RideMoveEnd(owner)
    elseif (eventName == AnimationEventDefines.k_EventEnd) then
        owner.m_Core:DelState(StateDefine.k_StateMove)
    end
end

function StateMove3rd.SetParamToCore(owner, needFollowTargetAngle)
    owner.m_Core:OnSyncState(StateDefine.k_StateMove, needFollowTargetAngle)
end

function StateMove3rd.RideRunBegin(owner)
end
function StateMove3rd.RideMoveStop(owner)
end
function StateMove3rd.RideMoveEnd(owner)
end

return StateMove3rd