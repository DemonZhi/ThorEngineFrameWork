--网络数据接收
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local StateSwim3rd = class("StateSwim3rd", StateBase)
local StateDefine = SGEngine.Core.StateDefine
local SyncConsts = ComponentDefine.SyncConsts
local SwimType = ComponentDefine.SwimType
local SwimSyncType = ComponentDefine.SwimSyncType
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
local Core_EntityUtility = SGEngine.Core.EntityUtility
local DebugDraw = SGEngine.Core.DebugDraw
local SkillType = SGEngine.Core.SkillDefines

function StateSwim3rd.Ctor(owner, stateComponent)
    StateSwim3rd.__super.Ctor(owner, stateComponent)
    if stateComponent.m_StateSwimParam == nil then
        stateComponent.m_StateSwimParam = {}
    end
end

function StateSwim3rd.Init(owner, stateComponent)
    --Logger.LogInfo("StateSwim3rd Init")
    owner.m_StateCheckerComponent:SetSwimCheckActive(false)
    StateSwim3rd.__super.Init(owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam
    if stateSwimParam.m_IsInit ~= nil then
        --Logger.LogInfo("StateSwim3rd Init m_IsInit true")
        return
    end
    stateSwimParam.m_IsInit = true
    stateSwimParam.m_ShouldCacheSyncInfo = false
    stateSwimParam.m_InitAfterChangeScene = false
    stateSwimParam.m_IsFirstSync = true
    stateSwimParam.m_SwimType = SwimType.k_None   
    
    if owner:IsModelLoadFinish() == true then
        StateSwim3rd.CheckAlreadyInWater(owner, stateSwimParam)
    end
    
    if stateSwimParam.m_CachedSyncInfo ~= nil then
        --Logger.LogInfo("StateSwim3rd Init m_CachedSyncInfo")
        StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)       
    elseif StateSwim3rd.CanEnterJumpDive(owner, stateComponent) then
        --Logger.LogInfo("StateSwim3rd Init k_StateJump & m_IsDiving predict")
        StateSwim3rd.SwimJumpDive(owner)
    else       
        --Logger.LogInfo("StateSwim3rd Init  m_CachedSyncInfo nil ")
    end
 
    if owner:IsModelLoadFinish() == true and SceneManager.IsChangeSceneTaskDone() == true then
        owner:BeginWet()
    else
        stateSwimParam.m_InitAfterChangeScene = true
    end
end

function StateSwim3rd.CanEnterJumpDive(owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam
    local isCorrectState = false
    if owner:IsLastState(StateDefine.k_StateJump) == true then
        isCorrectState = true
    elseif owner:IsLastState(StateDefine.k_StateSkill) then
        isCorrectState = true
    end

    if isCorrectState and stateSwimParam.m_IsDiving == true then
        return true
    end

    return false
end

function StateSwim3rd.CheckAlreadyInWater(owner, stateSwimParam)    
    stateSwimParam.m_WaterHeight = Core_EntityUtility.GetObjWaterHeight(owner.m_Core)
    if StateSwim3rd.IsAlmostAboveWater(owner, 0.2) == true then
        --Logger.LogInfo("StateSwim3rd.CheckAlreadyInWater m_IsDiving false")
        stateSwimParam.m_IsDiving = false
    else
        --Logger.LogInfo("StateSwim3rd.CheckAlreadyInWater m_IsDiving true")
        stateSwimParam.m_IsDiving = true
    end
end

function StateSwim3rd.OnModelLoadComplete(owner, stateComponent)
    stateComponent.m_StateSwimParam.m_HasSwimPoint = owner:HasBodyPartTransform(StateConsts.k_SwimPoint)
end

function StateSwim3rd.InitAfterChangeScene(owner, stateComponent)
    --Logger.LogInfo("StateSwim3rd OnModelLoadComplete")
    local stateSwimParam = stateComponent.m_StateSwimParam
    StateSwim3rd.CheckAlreadyInWater(owner, stateSwimParam)
    owner:BeginWet()
    StateSwim3rd.PlayEffect(owner, stateSwimParam)
    if stateSwimParam.m_CachedSyncInfo ~= nil then
        --Logger.LogInfo("[StateSwim3rd] InitAfterChangeScene DoCache")
        StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        stateSwimParam.m_CachedSyncInfo = nil
    end
    stateSwimParam.m_InitAfterChangeScene = false
end

function StateSwim3rd.Destroy(owner, stateComponent)
    --Logger.LogInfo("StateSwim3rd Destroy")
    local stateSwimParam = stateComponent.m_StateSwimParam
    owner.m_Core:OnJoyStickRelease()
    stateSwimParam.m_ShouldCacheSyncInfo = false
    stateSwimParam.m_Dived = nil
    stateSwimParam.m_InitAfterChangeScene = false
    stateSwimParam.m_CurrentSyncInfo = nil
    stateSwimParam.m_IsInit = nil
    owner:EndWet()
    StateSwim3rd.StopEffect(owner, stateSwimParam, true)
    StateSwim3rd.__super.Destroy(owner, stateComponent)
end

function StateSwim3rd.Update(deltaTime, owner, stateComponent)
    --local color = UnityEngine.Color.blue
    --DebugDraw.CreateGo(owner:GetPosition(), color)
    StateSwim3rd.__super.Update(deltaTime, owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam

    if stateSwimParam.m_InitAfterChangeScene == true then
        if SceneManager.IsChangeSceneTaskDone() == true and owner:IsModelLoadFinish() == true then
            StateSwim3rd.InitAfterChangeScene(owner, stateComponent)
        end
    end
    
    if owner:IsModelLoadFinish() == true then
        --if  stateSwimParam.m_IsDiving == true and stateSwimParam.m_SwimType ~= SwimType.k_Diving and stateSwimParam.m_SwimType ~= SwimType.k_JumpDiving then   
        --    if StateSwim3rd.IsAlmostAboveWater(owner, 0.2) == true then
        --        Logger.LogInfo("StateSwim3rd Update IsAlmostAboveWater Current State: %s:",stateSwimParam.m_SwimType)
        --        StateSwim3rd.FixAboveWaterPosition(owner)
        --        stateSwimParam.m_IsDiving = false
        --    end
        --end
        StateSwim3rd.CheckCast(owner, stateSwimParam)
    end

    if stateSwimParam.m_SwimType == SwimType.k_JumpDiving then
        StateSwim3rd.MoveSpeedSlowDown(owner, deltaTime)
    end

    if StateSwim3rd.FastPredictIfSprintUpwardUnderWater(owner) then
        StateSwim3rd.FixForward(owner)
    end

    if StateSwim3rd.CheckPredict(owner) then
        StateSwim3rd.PredictMove(owner)
    end
end

function StateSwim3rd.MoveSpeedSlowDown(owner, deltaTime)
    local moveSpeed = owner:GetCurrentMoveSpeed()
    moveSpeed = moveSpeed - 1 * deltaTime
    if moveSpeed < 0 then
        moveSpeed = 0
    end
    owner:SetCurrentMoveSpeed(moveSpeed)
end

function StateSwim3rd.CheckCast(owner, stateSwimParam)
    if stateSwimParam.m_SwimType == SwimType.k_JumpDiving or 
    stateSwimParam.m_SwimType == SwimType.k_Diving or 
    stateSwimParam.m_SwimType == SwimType.k_Sprint then
        if stateSwimParam.m_IsDiving == true then        
            --Logger.LogInfo("StateSwim3rd.CheckCast")
            if StateSwim3rd.CanEnterCast(owner) then
                --Logger.LogInfo("StateSwim3rd.CheckCast CanEnterCast")
                StateSwim3rd.SwimDiveCast(owner, stateSwimParam)
            end
        end
    end
end

function StateSwim3rd.CanEnterCast(owner)
    local forward = owner:GetForward()
    local position = owner:GetPosition() - owner:GetForward() * 1     
    local distance = 1.5
    local radius = 0.5
    -- 障碍检测
    local bIsUpObstacle = Core_EntityUtility.SphereCastGroundMaskXYZ(position.x, position.y, position.z, forward.x, forward.y, forward.z, radius, distance)
    return bIsUpObstacle
end

function StateSwim3rd.PlayEffect(owner, stateSwimParam)
    --Logger.LogInfo("StateSwim3rd PlayEffect")
    local swimType = stateSwimParam.m_SwimType
    local config = owner.m_CharacterConfig
    if config == nil then
        --Logger.LogInfo("StateSwim3rd PlayEffect config nil")
        return
    end

    if owner:IsModelLoadFinish() == false then
        --Logger.LogInfo("StateSwim3rd PlayEffect Model Finish")
        return
    end
    
    if swimType == SwimType.k_Diving or swimType == SwimType.k_JumpDiving  or swimType == SwimType.k_DivingCast then
        --Logger.LogInfo("StateSwim3rd PlayEffect swimType k_Diving k_DivingCast ")
        return
    end

    StateSwim3rd.StopEffect(owner, stateSwimParam, true)
    if StateSwim3rd.IsAlmostAboveWater(owner, 0.5) == false then   --- 第三方 offset给大一点
        return
    end

    if swimType == SwimType.k_Idle then
        stateSwimParam.m_CurrentSwimEffectIndex = owner.m_EffectComponent:PlayNormalEffect(config.SwimIdleEffectId)
    elseif swimType == SwimType.k_Swim then
        stateSwimParam.m_CurrentSwimEffectIndex = owner.m_EffectComponent:PlayNormalEffect(config.SwimEffectId)
    elseif swimType == SwimType.k_Sprint or swimType == SwimType.k_SprintCast then
        stateSwimParam.m_CurrentSwimEffectIndex = owner.m_EffectComponent:PlayNormalEffect(config.SwimSprintEffectId)
    end
end

function StateSwim3rd.StopEffect(owner, stateSwimParam, immediateDestroy)
    --Logger.LogInfo("StateSwim3rd StopEffect")
    if stateSwimParam.m_CurrentSwimEffectIndex == nil then
        --Logger.LogInfo("StateSwim3rd StopEffect EffectIndex nil")
        return
    end
    immediateDestroy = immediateDestroy or false
    local fadeOutTime = 0
    if immediateDestroy == false then
        fadeOutTime = 1
        owner.m_EffectComponent:StartEffectFadeOut(stateSwimParam.m_CurrentSwimEffectIndex, fadeOutTime)
    end
    owner.m_EffectComponent:StopNormalEffect(stateSwimParam.m_CurrentSwimEffectIndex, fadeOutTime)
end

function StateSwim3rd.FixForward(owner)
    --Logger.LogInfo("StateSwim3rd FixForward")
    --Logger.LogInfo("StateSwim3rd.FixForward(owner)")
    --向上游会冲出水面，这里需要修正
    local towards = owner:GetForward()
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_WaterHeight = Core_EntityUtility.GetObjWaterHeight(owner.m_Core)
    stateSwimParam.m_GroundHeight = Core_EntityUtility.GetObjHeightOnFloor(owner.m_Core)
    if towards.y > 0 then
        if StateSwim3rd.IsAlmostAboveWater(owner) then
            towards.y = 0
            owner:SetForward(towards)
            StateSwim3rd.FixAboveWaterPosition(owner)
            stateSwimParam.m_IsDiving = false
        end
    end
end

function StateSwim3rd.FixAboveWaterPosition(owner)
    --Logger.LogInfo("StateSwim3rd FixAboveWaterPosition")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    local waterHeight = stateSwimParam.m_WaterHeight
    if waterHeight == nil then
        return
    end
    local groundHeight = stateSwimParam.m_GroundHeight
    if groundHeight == nil then
        return
    end
    local position = owner:GetPosition()
    local inWaterOffset = stateSwimParam.m_InWaterOffset

    if waterHeight - groundHeight > inWaterOffset then
        position.y = waterHeight - inWaterOffset - 0.1
        --Logger.LogInfo("StateSwim3rd.FixAboveWaterPosition , position: %s,%s,%s", position.x, position.y, position.z)        
        StateSwim3rd.ForceSetCorePosition(owner, position)
    end
end

function StateSwim3rd.IsAlmostAboveWater(owner, offset)
    --Logger.LogInfo("StateSwim3rd IsAlmostAboveWater")
    offset = offset or 0
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_WaterHeight = Core_EntityUtility.GetObjWaterHeight(owner.m_Core)
    local waterHeight = stateSwimParam.m_WaterHeight
    local hasSwimPoint = stateSwimParam.m_HasSwimPoint
    local positionY
    if not hasSwimPoint then
        positionY = owner:GetPositionY()
    else
        positionY = owner:GetBodyPartTransformPositionY(StateConsts.k_SwimPoint)
    end

    local inWaterOffset = stateSwimParam.m_InWaterOffset
    --Logger.LogInfo("positionY + inWaterOffset: %s, waterHeight:%s", positionY + inWaterOffset, waterHeight)

    if positionY + inWaterOffset >= waterHeight - offset then
        return true
    end
    return false
end

function StateSwim3rd.CheckPredict(owner)
    -- Logger.LogInfo("StateSwim3rd CheckPredict")
    local stateParam = owner.m_StateComponent.m_StateSwimParam
    if stateParam.m_CoreHasStopped == false then
        return false
    end
    
    if stateParam.m_CurrentSyncInfo == nil then
        return false
    end

    local syncType = stateParam.m_CurrentSyncInfo.m_SyncType
    if stateParam.m_PredictStep > SyncConsts.k_Max3rdPredictStep then
        --Logger.LogInfo("Return false  MaxPredictStep:{%d}, frameCount{%d}", stateParam.m_PredictStep, Time.frameCount)
        return false
    end

    if syncType == SwimSyncType.k_SwimMove  then
        return true
    end
    --Logger.LogInfo("Return false  All false:m_PredictStep:{%d},syncType:{%d}, frameCount{%d}", stateParam.m_PredictStep, syncType, Time.frameCount)
    return false
end

function StateSwim3rd.PredictMove(owner)
    local stateParam = owner.m_StateComponent.m_StateSwimParam
    stateParam.m_PredictStep = stateParam.m_PredictStep + 1
    local syncInfo = stateParam.m_CurrentSyncInfo
    local angle = syncInfo.m_Angle
    local moveSpeed = StateSwim3rd.GetMoveSpeed(owner, syncInfo.m_SyncType)
    if stateParam.m_IsDiving == true then
        --owner:PredictMoveByPhysicsWithCurrentForward(moveSpeed, 1)
    else
        owner:PredictMoveByPhysics(angle, moveSpeed, 1)
    end
end

function StateSwim3rd.OnStopMove(owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam
    --if stateSwimParam == nil then
    ---    return
    --end
    if stateSwimParam.m_CurrentSyncInfo == nil or owner:IsModelLoadFinish() == false then
        return
    end    
    stateSwimParam.m_CoreHasStopped = true
    local swimType = stateSwimParam.m_CurrentSyncInfo.m_SyncType
    --Logger.LogInfo("StateSwim3rd OnStopMove:"..tostring(swimType))
    if swimType == SwimSyncType.k_Idle then
        StateSwim3rd.SwimIdle(owner)
    elseif swimType == SwimSyncType.k_Sprint then
        StateSwim3rd.SwimSprint(owner)
    elseif swimType == SwimSyncType.k_Diving then
        StateSwim3rd.SwimDive(owner)
    elseif swimType == SwimSyncType.k_Stop then
        StateSwim3rd.SwimStop(owner)
    elseif swimType == SwimSyncType.k_DivingCast then
        StateSwim3rd.SwimDiveCast(owner, stateSwimParam)
    end
end

function StateSwim3rd.SwimJumpDive(owner)
    --Logger.LogInfo("[StateSwim3rd] (SwimJumpDive)")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if stateSwimParam.m_Dived == true then
        --Logger.LogInfo("[StateSwim3rd] (SwimJumpDive) Again! somethingWrong")
        return
    end
    stateSwimParam.m_SwimType = SwimType.k_JumpDiving     
    stateSwimParam.m_ShouldCacheSyncInfo = true
    stateSwimParam.m_Dived = true 

    local angleY = owner:GetAngle()
    local position = owner:GetPosition()
    --Logger.LogInfo("StateSwim3rd.SwimJumpDive Local AngleY: %f position:%s, %s, %s", angleY, position.x, position.y, position.z)
    if stateSwimParam.m_CachedSyncInfo ~= nil then
        local syncInfo = stateSwimParam.m_CachedSyncInfo        
        if syncInfo.m_SyncType == SwimSyncType.k_JumpDiving then
            --Logger.LogInfo("[StateSwim3rd](SwimJumpDive) Sync Position and Angle")
            local targetPosition = syncInfo.m_TargetPosition
            StateSwim3rd.ForceSetCorePosition(owner, targetPosition)
            angleY = stateSwimParam.m_CachedSyncInfo.m_Angle
            --Logger.LogInfo("StateSwim3rd.SwimJumpDive Sync AngleY: %f  targetPosition: %s, %s, %s,", angleY , targetPosition.x, targetPosition.y, targetPosition.z)
            StateSwim3rd.ForceSetCoreAngle(owner, angleY)
        end
    end
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    local moveSpeedY = stateJumpParam.m_LastSpeedY or 0
    local moveSpeed =  stateJumpParam.m_LastSpeed or 0
    local forward = owner:GetForward()  
    --Logger.LogInfo("StateSwim3rd.SwimJumpDive GetForward: %s, %s, %s,", forward.x, forward.y, forward.z)  
    moveSpeed = math.max(moveSpeed, 1)
    moveSpeedY = math.min(moveSpeedY, -1)
    forward.x = forward.x * moveSpeed
    forward.y = moveSpeedY * 0.8
    forward.z = forward.z * moveSpeed
    forward:SetNormalize()
    --Logger.LogInfo("StateSwim3rd.SwimJumpDive moveSpeedY: %s, moveSpeed %s ", moveSpeedY, moveSpeed)    
    owner:SetForward(forward)
    --Logger.LogInfo("StateSwim3rd.SwimJumpDive SetForward: %s, %s, %s,", forward.x, forward.y, forward.z)
    owner:SetCurrentMoveSpeed(math.abs(moveSpeedY) * 0.3)
    --owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSprintSpeed)
    owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimSprintRotateSpeed)
    StateSwim3rd.PlayAnimation(owner, StateConsts.k_SwimSprint, 0.1, function(eventName)
        StateSwim3rd.OnSwimJumpDive(owner, eventName)
    end)
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, angleY)
    StateSwim3rd.StopEffect(owner, stateSwimParam)
end

-- 跳水潜水
function StateSwim3rd.OnSwimJumpDive(owner, eventName)
    --Logger.LogInfo("StateSwim3rd OnSwimJumpDive")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if eventName == AnimationEventDefines.k_EventRearSwing then
        stateSwimParam.m_SwimType = SwimType.k_SprintCast
        stateSwimParam.m_ShouldCacheSyncInfo = false
        if stateSwimParam.m_CachedSyncInfo ~= nil then
            StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        end
    elseif eventName == AnimationEventDefines.k_EventEnd then
        if stateSwimParam.m_CachedSyncInfo ~= nil then
            StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        else
            StateSwim3rd.SwimDiveCast(owner, stateSwimParam)
        end
    end
end

function StateSwim3rd.SwimDiveCast(owner, stateSwimParam)
    --Logger.LogInfo("StateSwim3rd.SwimDiveCast")
    owner:UnRegAnimationCallBack(StateConsts.k_SwimSprint)
    if stateSwimParam.m_SwimType == SwimType.k_JumpDiving then
        stateSwimParam.m_ShouldCacheSyncInfo = false
    else
        stateSwimParam.m_ShouldCacheSyncInfo = false
    end   
    stateSwimParam.m_SwimType = SwimType.k_DivingCast   
    --owner:SetCurrentMoveSpeed(0)
    --owner:SetCurrentMoveSpeedY(0)
    StateSwim3rd.PlayAnimation(owner, StateConsts.k_DiveJumpCast, 0.5, function(eventName)
        StateSwim3rd.OnSwimDiveCast(owner, eventName)
    end, 0.5)    
    StateSwim3rd.ChangeCoreToLerpForward(owner, 0)
    StateSwim3rd.StopEffect(owner, stateSwimParam, true)
end

function StateSwim3rd.OnSwimDiveCast(owner, eventName)
    --Logger.LogInfo("StateSwim3rd OnSwimDiveCast")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if eventName == AnimationEventDefines.k_EventEnd then
        stateSwimParam.m_SwimType = SwimType.k_SprintCast
        stateSwimParam.m_ShouldCacheSyncInfo = false
        if stateSwimParam.m_CachedSyncInfo ~= nil then
            StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        else
            StateSwim3rd.SwimIdle(owner)
        end
    end
end

function StateSwim3rd.SwimDive(owner)
    --Logger.LogInfo("StateSwim3rd SwimDive")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_IsDiving = true
    stateSwimParam.m_ShouldCacheSyncInfo = true
    stateSwimParam.m_SwimType = SwimType.k_Diving
    local forward = owner:GetForward()
    local up = owner:GetTransform().up
    forward.x = forward.x - up.x
    forward.y = forward.y - up.y
    forward.z = forward.z - up.z
    forward:SetNormalize()
    owner:SetForward(forward)
    owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSprintSpeed)
    owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimSprintRotateSpeed)
    StateSwim3rd.PlayAnimation(owner, StateConsts.k_SwimSprint, 0.1, function(eventName)
        StateSwim3rd.OnSwimDive(owner, eventName)
    end)
    local angleY = stateSwimParam.m_CurrentSyncInfo.m_Angle
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, angleY)
    StateSwim3rd.StopEffect(owner, stateSwimParam)
end

function StateSwim3rd.OnSwimDive(owner, eventName)
    --Logger.LogInfo("StateSwim3rd OnSwimDive")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    --Logger.LogInfo("StateSwim3rd OnSwimDive eventName: %s ", eventName)
    if eventName == AnimationEventDefines.k_EventRearSwing then
        
        stateSwimParam.m_SwimType = SwimType.k_SprintCast
        stateSwimParam.m_ShouldCacheSyncInfo = false
        if stateSwimParam.m_CachedSyncInfo ~= nil then
            --Logger.LogInfo("StateSwim3rd OnSwimDive RS syncCache")
            StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        end
    elseif eventName == AnimationEventDefines.k_EventEnd then
        if stateSwimParam.m_CachedSyncInfo ~= nil then
            --Logger.LogInfo("StateSwim3rd OnSwimDive END syncCache")
            StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        end
    end
end

function StateSwim3rd.SwimIdle(owner)
    --Logger.LogInfo("StateSwim3rd SwimIdle")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_ShouldCacheSyncInfo = false
    if stateSwimParam.m_SwimType == SwimType.k_Idle then
        return
    end
    stateSwimParam.m_SwimType = SwimType.k_Idle
    owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
    owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
    StateSwim3rd.SetParamToCore(owner, true)
    StateSwim3rd.PlayAnimation(owner, StateConsts.k_SwimIdle)
    StateSwim3rd.StopEffect(owner, stateSwimParam)
end

function StateSwim3rd.SwimMove(owner)
    --Logger.LogInfo("StateSwim3rd SwimMove")   
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_ShouldCacheSyncInfo = false
    stateSwimParam.m_SwimType = SwimType.k_Swim
    if owner:IsPlayingAnimation(StateConsts.k_SwimMove) == false then        
        StateSwim3rd.SetParamToCore(owner, false, stateSwimParam.m_IsDiving)
        StateSwim3rd.PlayAnimation(owner, StateConsts.k_SwimMove)
        StateSwim3rd.PlayEffect(owner, stateSwimParam)
    end   
end

function StateSwim3rd.SwimSprint(owner)
    --Logger.LogInfo("StateSwim3rd SwimSprint")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_SwimType = SwimType.k_Sprint
    stateSwimParam.m_ShouldCacheSyncInfo = true
    local angleX, angleY, angleZ = owner:GetAngleXYZ()
    angleY = stateSwimParam.m_CurrentSyncInfo.m_Angle
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, angleY)
    owner:SetAngleXYZ(angleX, angleY, angleZ)
    owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSprintSpeed)
    owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimSprintRotateSpeed)
    StateSwim3rd.PlayAnimation(owner, StateConsts.k_SwimSprint, 0.1, function(eventName)
        StateSwim3rd.OnSwimSprint(owner, eventName)
    end)   
end

function StateSwim3rd.OnSwimSprint(owner, eventName)
    --Logger.LogInfo("StateSwim3rd OnSwimSprint")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if eventName == AnimationEventDefines.k_EventRearSwing then
        stateSwimParam.m_SwimType = SwimType.k_SprintCast
        stateSwimParam.m_ShouldCacheSyncInfo = false
        if stateSwimParam.m_CachedSyncInfo ~= nil then
            StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        end
    elseif eventName == AnimationEventDefines.k_EventEnd then
        StateSwim3rd.StopEffect(owner, stateSwimParam)
        if stateSwimParam.m_CachedSyncInfo ~= nil then
            StateSwim3rd.OnSyncStateSwim(owner, stateSwimParam.m_CachedSyncInfo)
        end
    end
end

function StateSwim3rd.ChangeCoreToLerpForward(owner, angleY)    
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, angleY, 0, 0)
end

function StateSwim3rd.SwimStop(owner)
    -- Logger.LogInfo("StateSwim3rd SwimStop")
    local angle = owner.m_StateComponent.m_StateSwimParam.m_CurrentSyncInfo.m_Angle
    -- owner:SetAngle(angle)
    StateSwim3rd.ForceSetCoreAngle(owner, angle)
    owner:DelState(StateDefine.k_StateSwim)
end

function StateSwim3rd.SetParamToCore(owner, needTargetAngle, needAdjustMoveSpeed)
    --Logger.LogInfo("StateSwim3rd SetParamToCore: %s , %s ", needTargetAngle, needAdjustMoveSpeed)
    needAdjustMoveSpeed = needAdjustMoveSpeed or false
    owner.m_Core:OnSyncState(StateDefine.k_StateSwim, needTargetAngle, needAdjustMoveSpeed)
end

function StateSwim3rd.CheckInSwim3rd(owner)
    local stateComponent = owner.m_StateComponent
    local stateSwimParam = stateComponent.m_StateSwimParam
    if stateSwimParam.m_CachedSyncInfo ~= nil then
        --Logger.LogInfo("StateSwim3rd CheckInSwim3rd Has CacheSyncInfo ChangeToSwim")
        owner:ChangeToSwim()
    end
end

function StateSwim3rd.OnSyncStateSwim(owner, syncInfo)
    if not syncInfo then
        return
    end
    --Logger.LogInfo("[StateSwim3rd](OnSyncStateSwim) m_SyncType:" .. syncInfo.m_SyncType) 
    local stateComponent = owner.m_StateComponent
    local stateSwimParam = stateComponent.m_StateSwimParam
    if owner:IsModelLoadFinish() == false then   
        stateSwimParam.m_CachedSyncInfo = syncInfo
        return
    end

    if owner:IsState(StateDefine.k_StateSwim) == false then
        StateSwim3rd.UnSwimState(owner, syncInfo, stateSwimParam, stateComponent)
    else
        StateSwim3rd.InSwimState(owner, syncInfo, stateSwimParam)
    end
end

function StateSwim3rd.UnSwimState(owner, syncInfo, stateSwimParam, stateComponent)
    stateSwimParam.m_CachedSyncInfo = syncInfo
    if owner:IsState(StateDefine.k_StateJump) == true or owner:IsUsingJumpSkill() then
        --Logger.LogInfo("StateSwim3rd UnSwimState k_StateJump m_CachedSyncInfo")
        --Logger.LogInfo("[StateSwim3rd](OnSyncStateSwim) UnSwimState k_StateJump m_CachedSyncInfo:{%f},{%f},{%f}, angle:%f, frameCount:%d,  type:%d",
        --        syncInfo.m_TargetPosition.x, syncInfo.m_TargetPosition.y, syncInfo.m_TargetPosition.z, syncInfo.m_Angle,
        --         Time.frameCount, syncInfo.m_SyncType)
        
        local stateComponent = owner.m_StateComponent
        local stateJumpParam = stateComponent.m_StateJumpParam 
        if stateJumpParam.m_SelfCheckInSwim == true then
            --Logger.LogInfo("StateSwim3rd UnSwimState k_StateJump SelfCheckInSwim ChangeToSwim")
            --Logger.LogInfo("StateSwim3rd.stateJumpParam m_SelfCheckInSwim true moveSpeedY: %s, moveSpeed %s ", stateJumpParam.m_LastSpeedY, stateJumpParam.m_LastSpeed)
            owner:ChangeToSwim()
        else            
            owner.m_StateCheckerComponent:SetSwimCheckActive(true)
        end
    else        
        --Logger.LogInfo("StateSwim3rd UnSwimState UnJump Force ChangeToSwim")        
        owner:ChangeToSwim()
    end
end

function StateSwim3rd.InSwimState(owner, syncInfo, stateSwimParam)      
    stateSwimParam.m_CoreHasStopped = false
    stateSwimParam.m_PredictStep = 0
    if stateSwimParam.m_IsFirstSync == true then
        StateSwim3rd.OnSyncStateFirstTime(owner, syncInfo, stateSwimParam)
    else
        StateSwim3rd.OnSyncStateDiveCastOrNormalMove(owner, syncInfo, stateSwimParam)
    end
    stateSwimParam.m_IsFirstSync = false
end

function StateSwim3rd.OnSyncStateFirstTime(owner, syncInfo, stateSwimParam)
    if syncInfo.m_SyncType == SwimSyncType.k_JumpDiving then
        --Logger.LogInfo("StateSwim3rd OnSyncStateSwim FirstTime To JumpDive")
        stateSwimParam.m_CachedSyncInfo = nil
        StateSwim3rd.SwimJumpDive(owner)
    else        
        -- Force Change To Sync Info
        --Logger.LogInfo("StateSwim3rd OnSyncStateSwim FirstTime To Sync Move")
        stateSwimParam.m_ShouldCacheSyncInfo = false
        StateSwim3rd.OnSyncStateDiveCastOrNormalMove(owner, syncInfo, stateSwimParam)
    end
end

function StateSwim3rd.OnSyncStateDiveCastOrNormalMove(owner, syncInfo, stateSwimParam)    
    if syncInfo.m_SyncType == SwimSyncType.k_DivingCast then    
        StateSwim3rd.OnSyncStateDiveCast(owner, syncInfo, stateSwimParam)
    elseif stateSwimParam.m_ShouldCacheSyncInfo == true 
        and syncInfo.m_SyncType ~= SwimSyncType.k_Stop
        and syncInfo.m_SyncType ~= SwimSyncType.k_Idle
        and StateSwim3rd.FastPredictIfSprintUpwardUnderWater(owner) == false then
            --Logger.LogInfo("[StateSwim3rd](OnSyncStateSwim) m_ShouldCacheSyncInfo return:{%f},{%f},{%f}, angle:%f, frameCount:%d,  type:%d",
            --syncInfo.m_TargetPosition.x, syncInfo.m_TargetPosition.y, syncInfo.m_TargetPosition.z, syncInfo.m_Angle,
            --Time.frameCount, syncInfo.m_SyncType)

            stateSwimParam.m_CachedSyncInfo = syncInfo
    else
        StateSwim3rd.OnSyncMoveToThePositionAndPlayState(owner, syncInfo, stateSwimParam)
    end
end

function StateSwim3rd.OnSyncStateDiveCast(owner, syncInfo, stateSwimParam)
    -- Force SetPosition and Angle
    --Logger.LogInfo("[StateSwim3rd](OnSyncStateSwim) ChangeToDivingCast OnSyncStateDiveCast:{%f},{%f},{%f}, angle:%f, frameCount:%d,  type:%d",
    --syncInfo.m_TargetPosition.x, syncInfo.m_TargetPosition.y, syncInfo.m_TargetPosition.z, syncInfo.m_Angle,
    --Time.frameCount, syncInfo.m_SyncType)
    stateSwimParam.m_CachedSyncInfo = nil
    --Logger.LogInfo("StateSwim3rd OnSyncStateDiveCast")
    local targetPosition = syncInfo.m_TargetPosition
    StateSwim3rd.SetCoreLerpToPosition(owner, targetPosition)        
    if stateSwimParam.m_SwimType ~= SwimType.k_DivingCast then
        --Logger.LogInfo("StateSwim3rd OnSyncStateDiveCast Play SwimDiveCast")
        StateSwim3rd.SwimDiveCast(owner, stateSwimParam)        
    end
end

function StateSwim3rd.OnSyncMoveToThePositionAndPlayState(owner, syncInfo, stateSwimParam)
    stateSwimParam.m_CurrentSyncInfo = syncInfo
    stateSwimParam.m_CachedSyncInfo = nil
    local type = syncInfo.m_SyncType
    if type == SwimSyncType.k_Sprint or type == SwimSyncType.k_Diving then
        stateSwimParam.m_ShouldCacheSyncInfo = true
    end

    local targetPosition = syncInfo.m_TargetPosition
    local targetAngle = syncInfo.m_Angle
    local position = owner:GetPosition()
    local positionDif = position:Sub(targetPosition)
    local moveSpeed = StateSwim3rd.GetMoveSpeed(owner, type)
    local time = Time.deltaTime

    StateSwim3rd.AdjustSyncMoveSpeed(owner, positionDif, type)
    if positionDif:SqrMagnitude() > moveSpeed * time * moveSpeed * time and stateSwimParam.m_IsFirstSync == false then
        --Logger.LogInfo("StateSwim3rd NormalMove")
        StateSwim3rd.SwimMove(owner)
        owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, targetPosition, targetAngle)
    else
        --Logger.LogInfo("Too close, direct set targetPosition %s , %s, %s ", targetPosition.x, targetPosition.y, targetPosition.z)      
        StateSwim3rd.ForceSetCorePosition(owner, targetPosition)
        owner:SetStateTargetAngle(StateDefine.k_StateSwim, targetAngle)
        if stateSwimParam.m_IsFirstSync == true then
            StateSwim3rd.OnStopMove(owner, owner.m_StateComponent)
        end
        owner.m_Core:OnJoyStickRelease()
    end 
end

function StateSwim3rd.FastPredictIfSprintUpwardUnderWater(owner)
    -- Logger.LogInfo("StateSwim3rd FastPredictIfSprintUpwardUnderWater")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    local swimType = stateSwimParam.m_SwimType
    if swimType ~= SwimType.k_Sprint then
        return false
    end
    local forward = owner:GetForward()
    if forward.y > 0 then
        return true
    end
    return false
end

function StateSwim3rd.AdjustSyncMoveSpeed(owner, positionDif, syncType)
    --Logger.LogInfo("StateSwim3rd AdjustSpeed")
    local moveSpeed = StateSwim3rd.GetMoveSpeed(owner, syncType)
    if positionDif:SqrMagnitude() > (SyncConsts.k_MaxPositionDifference * SyncConsts.k_MaxPositionDifference) then
        --Logger.LogInfo("SpeedUp")
        moveSpeed = moveSpeed * 1.2
        owner:SetCurrentMoveSpeed(moveSpeed)
    else
        owner:SetCurrentMoveSpeed(moveSpeed)
    end
end

function StateSwim3rd.GetMoveSpeed(owner, syncType)
    --Logger.LogInfo("StateSwim3rd GetMoveSpeed")
    if owner.m_CharacterConfig == nil then
        return 0
    end
    if syncType == SwimSyncType.k_Sprint or syncType == SwimSyncType.k_SprintMove then
        return owner.m_CharacterConfig.SwimSprintSpeed
    else
        return owner.m_CharacterConfig.SwimSpeed
    end
end

function StateSwim3rd.SetCoreLerpToPosition(owner, targetPosition)
    --Logger.LogInfo("StateSwim3rd GetMoveSpeed")
    --owner:SetPosition(targetPosition)
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, targetPosition, 0, 0, 0)      
end

function StateSwim3rd.ForceSetCorePosition(owner, targetPosition)
    --Logger.LogInfo("StateSwim3rd GetMoveSpeed")
    owner:SetPosition(targetPosition)
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, targetPosition, 0, 0, 0)      
end

function StateSwim3rd.ForceSetCoreAngle(owner, angleY)
    --Logger.LogInfo("StateSwim3rd ForceSetCoreAngle angleY:" .. angleY)
    owner:SetAngle(angleY)
    owner.m_Core:OnSyncStateMove(StateDefine.k_StateSwim, angleY, 0, 0, 0, 0)      
end

return StateSwim3rd