--网络数据发送
local StateDefine = SGEngine.Core.StateDefine
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local StateSwimHero = class("StateSwimHero", StateBase)
local BattleMessage = require("MainGame/Message/BattleMessage")
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local SyncConsts = ComponentDefine.SyncConsts
local SwimType = ComponentDefine.SwimType
local SwimSyncType = ComponentDefine.SwimSyncType
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
local DebugDraw = SGEngine.Core.DebugDraw
local Core_EntityUtility = SGEngine.Core.EntityUtility
local SkillType = SGEngine.Core.SkillDefines

local k_NormalToOnWaterMotorIndex = 3
local k_OnWaterToNormalMotorIndex = 4
local k_OnToUnderWaterIndex = 12
local k_UnderToOnWaterIndex = 13
function StateSwimHero.Ctor(owner, stateComponent)
    StateSwimHero.__super.Ctor(owner, stateComponent)
    if stateComponent.m_StateSwimParam == nil then
        stateComponent.m_StateSwimParam = {}
    end
end

function StateSwimHero.Init(owner, stateComponent)
    StateSwimHero.__super.Init(owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam
    stateSwimParam.m_SwimType = SwimType.k_None
    if owner:IsModelLoadFinish() == true then
        StateSwimHero.CheckAlreadyInWater(owner)
    end
    stateSwimParam.m_FrameCount = 0
        
    if StateSwimHero.CanEnterJumpDive(owner, stateComponent) then
        --Logger.LogInfo("[StateSwimHero](Init) SwimJumpDive")
        StateSwimHero.SwimJumpDive(owner)
    else
        --Logger.LogInfo("[StateSwimHero](Init) SwimIdle")
        StateSwimHero.SwimIdle(owner)
    end

    if stateSwimParam.m_IsDiving == false then
        if owner:IsOpenSwimCamera() > 0 then
           owner:ActivateMotorWithIndex(k_NormalToOnWaterMotorIndex)
        end
        StateSwimHero.InitUI()
    end
    owner:BeginWet()
end

function StateSwimHero.CanEnterJumpDive(owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam
    local isCorrectState = false
    if owner:IsLastState(StateDefine.k_StateJump) == true then
        isCorrectState = true
    elseif owner:IsLastState(StateDefine.k_StateSkill) then
        isCorrectState = true
        --local gravity = owner:GetCurrentGravity()
        --Logger.LogInfo("g:" .. tostring(gravity))
    end

    if isCorrectState and stateSwimParam.m_IsDiving == true then
        return true
    end

    return false
end

function StateSwimHero.CanEnterCast(owner)        
    local forward = owner:GetForward()
    local position = owner:GetPosition() - owner:GetForward() * 1     
    local distance = 1.5
    local radius = 0.5
    -- 障碍检测
    local bIsUpObstacle = Core_EntityUtility.SphereCastGroundMaskXYZ(position.x, position.y, position.z, forward.x, forward.y, forward.z, radius, distance)
    return bIsUpObstacle
end

function StateSwimHero.CheckAlreadyInWater(owner)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_WaterHeight = Core_EntityUtility.GetObjWaterHeight(owner.m_Core)
    if StateSwimHero.IsAlmostAboveWater(owner, 0.2) == true then
        --Logger.LogInfo("StateSwimHero.CheckAlreadyInWater1")
        stateSwimParam.m_IsDiving = false
    else
        --Logger.LogInfo("StateSwimHero.CheckAlreadyInWater2")
        stateSwimParam.m_IsDiving = true
        StateSwimHero.SwimDiveInit(owner, true)
        StateSwimHero.ChangeCoreToDiveSwim(owner)
    end
end

function StateSwimHero.Update(deltaTime, owner, stateComponent)
    
    --local color = UnityEngine.Color.blue
    --DebugDraw.CreateGo(owner:GetPosition(), color)

    local stateSwimParam = stateComponent.m_StateSwimParam
    stateSwimParam.m_FrameCount = stateSwimParam.m_FrameCount + 1
    stateSwimParam.m_WaterHeight = Core_EntityUtility.GetObjWaterHeight(owner.m_Core)
    stateSwimParam.m_GroundHeight = Core_EntityUtility.GetObjHeightOnFloor(owner.m_Core)
    if stateSwimParam.m_SwimType ~= SwimType.k_Diving and stateSwimParam.m_SwimType ~= SwimType.k_JumpDiving and stateSwimParam.m_IsDiving == true then
        if StateSwimHero.IsAlmostAboveWater(owner) == true then
            StateSwimHero.FixAboveWaterPosition(owner)
            StateSwimHero.SwimDive(owner, false)
        end
    end

    StateSwimHero.CheckCast(owner, stateSwimParam)

    if stateSwimParam.m_SwimType == SwimType.k_JumpDiving then
        StateSwimHero.MoveSpeedSlowDown(owner, deltaTime)
    end

    if stateSwimParam.m_IsDiving == false then
        StateSwimHero.FixAboveWaterPosition(owner)
    end

    StateSwimHero.CheckExit(owner)
    StateSwimHero.CheckSync(owner)
    
end

function StateSwimHero.LateUpdate(owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam
    if stateSwimParam.m_IsDiving == true then
        return
    end
end

function StateSwimHero.Destroy(owner, stateComponent)
    --Logger.LogInfo("StateSwimHero.Destroy")
    local stateSwimParam = stateComponent.m_StateSwimParam
    StateSwimHero.CloseUI()
    owner:EndWet()
    if owner:IsOpenSwimCamera() > 0 then
       owner:ActivateMotorWithIndex(k_OnWaterToNormalMotorIndex)
    end
    StateSwimHero.StopEffect(owner, stateSwimParam, true)
    StateSwimHero.__super.Destroy(owner, stateComponent)
end

function StateSwimHero.OnModelLoadComplete(owner, stateComponent)
    StateSwimHero.CheckAlreadyInWater(owner)
end

function StateSwimHero.SwimJumpDive(owner)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    stateSwimParam.m_SwimType = SwimType.k_JumpDiving
    local moveSpeedY = owner:GetCurrentMoveSpeedY()
    local moveSpeed = owner:GetCurrentMoveSpeed()
    local forward = owner:GetForward()  
    --Logger.LogInfo("StateSwimHero.SwimJumpDive GetForward: %s, %s, %s,", forward.x, forward.y, forward.z)  
    moveSpeed = math.max(moveSpeed, 1)
    moveSpeedY = math.min(moveSpeedY, -1)
    forward.x = forward.x * moveSpeed
    forward.y = moveSpeedY * 0.8
    forward.z = forward.z * moveSpeed
    forward:SetNormalize()
    --Logger.LogInfo("StateSwimHero.SwimJumpDive moveSpeedY: %s, moveSpeed %s ", moveSpeedY, moveSpeed)
    --Logger.LogInfo("StateSwimHero.SwimJumpDive setForward: %s, %s, %s,", forward.x, forward.y, forward.z)  
    owner:SetForward(forward)    
    owner:SetCurrentMoveSpeed(math.abs(moveSpeedY) * 0.3)
    --owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSprintSpeed)
    owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimSprintRotateSpeed)
    StateSwimHero.PlayAnimation(owner, StateConsts.k_SwimSprint, 0.1, function(eventName)
        StateSwimHero.OnSwimJumpDive(owner, eventName)
    end)    
    -- Send Sync
    local position = owner:GetPosition()
    local angle = owner:GetAngle()
    angle = math.floor(angle)
    --Logger.LogInfo("[StateSwimHero](SwimJumpDive) angle:"..angle)
    StateSwimHero.SyncStateSwim(owner, position, SwimSyncType.k_JumpDiving, angle)
    StateSwimHero.ChangeCoreToDivingSwim(owner, forward.x, forward.y, forward.z)
    StateSwimHero.StopEffect(owner, stateSwimParam)    

    ---Set UI Button
    StateSwimHero.SetSprintBtnActive(false)
    StateSwimHero.SetDiveBtnActive(false)
end

function StateSwimHero.MoveSpeedSlowDown(owner, deltaTime)
    local moveSpeed = owner:GetCurrentMoveSpeed()
    moveSpeed = moveSpeed - 1 * deltaTime
    if moveSpeed < 0 then
        moveSpeed = 0
    end
    owner:SetCurrentMoveSpeed(moveSpeed)
end

function StateSwimHero.OnSwimJumpDive(owner, eventName)
    -- 前摇开始 方向开始回正
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if eventName == AnimationEventDefines.k_EventRearSwing then
        --Logger.LogInfo("StateSwimHero.OnSwimDive k_EventRearSwing")             
        stateSwimParam.m_SwimType = SwimType.k_Cast
        -- 跳水入水减速效果 这里就不给速度了
        -- owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
        -- owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
        ---camera_input_source.RePressAction(SGameInputSource.ACTION_CAMERA_SWIM_SPRINT_END)
    elseif eventName == AnimationEventDefines.k_EventEnd then
        --Logger.LogInfo("StateSwimHero.OnSwimDive k_EventEnd")
        StateSwimHero.SwimDiveCast(owner, stateSwimParam)
    end
end

function StateSwimHero.CheckCast(owner, stateSwimParam)  
    if stateSwimParam.m_SwimType == SwimType.k_JumpDiving or 
    stateSwimParam.m_SwimType == SwimType.k_Diving or 
    stateSwimParam.m_SwimType == SwimType.k_Sprint then
        if stateSwimParam.m_IsDiving == true then        
            --Logger.LogInfo("StateSwimHero.CheckCast")
            if StateSwimHero.CanEnterCast(owner) then
                --Logger.LogInfo("StateSwimHero.CheckCast CanEnterCast")
                StateSwimHero.SwimDiveCast(owner, stateSwimParam)
            end
        end
    end
end

function StateSwimHero.SwimDiveCast(owner, stateSwimParam)
    --Logger.LogInfo("StateSwimHero.SwimDiveCast")    
    owner:UnRegAnimationCallBack(StateConsts.k_SwimSprint)
    stateSwimParam.m_SwimType = SwimType.k_DivingCast
    owner:SetCurrentMoveSpeed(0)
    owner:SetCurrentMoveSpeedY(0)
    StateSwimHero.PlayAnimation(owner, StateConsts.k_DiveJumpCast, 0.5, function(eventName)
        StateSwimHero.OnSwimDiveCast(owner, eventName)
    end, 0.5)
    -- Sync Position angleY
    local position = owner:GetPosition()
    local angleY = owner:GetAngle()
    angleY = math.floor(angleY)
    StateSwimHero.SyncStateSwim(owner, position, SwimSyncType.k_DivingCast, angleY)
    StateSwimHero.ChangeCoreToLerpForward(owner)

    StateSwimHero.SetSprintBtnActive(false)
    StateSwimHero.SetDiveBtnActive(false)
end

function StateSwimHero.OnSwimDiveCast(owner, eventName)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    --Logger.LogInfo("StateSwimHero.OnSwimDiveCast eventName:" .. eventName)
    if eventName == AnimationEventDefines.k_EventStart then
        owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)        
        owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
    elseif eventName == AnimationEventDefines.k_EventEnd then
        if stateSwimParam.m_IsDiving == true then
            StateSwimHero.ChangeCoreToDiveSwim(owner)
        end        
        StateSwimHero.SwimIdle(owner)
       --Logger.LogInfo("StateSwimHero.OnSwimDiveCast SwimIdle GetForward: %s, %s, %s,", forward.x, forward.y, forward.z)  
    end
end

function StateSwimHero.SwimDive(owner, isDiving)
    --Logger.LogInfo("StateSwimHero.SwimDive")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if isDiving == stateSwimParam.m_IsDiving then
        return
    end
    stateSwimParam.m_IsDiving = isDiving
    StateSwimHero.SwimDiveInit(owner, isDiving)

    if isDiving then
        --Logger.LogInfo("StateSwimHero.SwimDive k_Diving")
        local forward = owner:GetForward()
        local up = owner:GetTransform().up
        forward.x = forward.x - up.x
        forward.y = forward.y - up.y
        forward.z = forward.z - up.z
        forward:SetNormalize()
        owner:SetForward(forward)
        owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
        owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimSprintRotateSpeed)
        StateSwimHero.PlayAnimation(owner, StateConsts.k_SwimSprint, 0.1, function(eventName)
            StateSwimHero.OnSwimDive(owner, eventName)
        end)
        stateSwimParam.m_SwimType = SwimType.k_Diving
        local position = owner:GetPosition()
        local angle = owner:GetAngle()
        angle = math.floor(angle)
        StateSwimHero.SyncStateSwim(owner, position, SwimSyncType.k_Diving, angle)
        StateSwimHero.ChangeCoreToDivingSwim(owner, forward.x, forward.y, forward.z)
        StateSwimHero.StopEffect(owner, stateSwimParam)    ---这里停掉当前特效
        --Logger.LogInfo("StateSwimHero.SwimDive GetForward: %s, %s, %s,", forward.x, forward.y, forward.z)    
        StateSwimHero.SetSprintBtnActive(false)
        StateSwimHero.SetDiveBtnActive(false)  
    else
        StateSwimHero.ChangeCoreToAboveWaterSwim(owner)
        if stateSwimParam.m_SwimType == SwimType.k_Sprint then
            if SGEngine.Core.InputManager.Instance.JoystickAngle == 0 then
                StateSwimHero.SwimIdle(owner)
            else
                owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
                owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
                StateSwimHero.SwimMove(owner)
            end
        else
            StateSwimHero.PlayEffect(owner, stateSwimParam)
        end
    end
end

function StateSwimHero.SwimDiveInit(owner, isDiving)
    StateSwimHero.AdjustUI(isDiving)    
    local motorIndex
    if isDiving then
        motorIndex = k_OnToUnderWaterIndex
    else
        motorIndex = k_UnderToOnWaterIndex
    end
    owner:ActivateMotorWithIndex(motorIndex)
end

function StateSwimHero.OnSwimDive(owner, eventName)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if eventName == AnimationEventDefines.k_EventRearSwing then
        --Logger.LogInfo("StateSwimHero.OnSwimDive k_EventRearSwing")
        stateSwimParam.m_SwimType = SwimType.k_Cast
        owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
        owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
        -- StateSwimHero.SetCoreMovableAndIgnoreJoystick(owner, true, false)
        -- StateSwimHero.ChangeCoreToDiveSwim(owner)
        ---camera_input_source.RePressAction(SGameInputSource.ACTION_CAMERA_SWIM_SPRINT_END)
    elseif eventName == AnimationEventDefines.k_EventEnd then
        -- 直接进入游泳闲置 动作切换不够柔和
        --Logger.LogInfo("StateSwimHero.OnSwimDive k_EventEnd")
        --StateSwimHero.ChangeCoreToDiveSwim(owner)
        --StateSwimHero.SwimIdle(owner)
        local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
        StateSwimHero.SwimDiveCast(owner, stateSwimParam)
    end
end

function StateSwimHero.SwimSprint(owner)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if stateSwimParam.m_SwimType == SwimType.k_Sprint or stateSwimParam.m_SwimType == SwimType.k_Diving then
        return
    end
    StateSwimHero.SetSprintBtnActive(false)
    StateSwimHero.SetDiveBtnActive(false)
    local position = owner:GetPosition()
    local angle = owner:GetAngle()
    angle = math.floor(angle)
    owner:SetAngle(angle)
    owner:SetStateTargetAngle(StateDefine.k_StateSwim, angle)
    owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSprintSpeed)
    owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimSprintRotateSpeed)
    StateSwimHero.PlayAnimation(owner, StateConsts.k_SwimSprint, 0.1, function(eventName)
        StateSwimHero.OnSwimSprint(owner, eventName)
    end)
    stateSwimParam.m_SwimType = SwimType.k_Sprint
    StateSwimHero.SetCoreMovableAndIgnoreJoystick(owner, true, true)
    StateSwimHero.SyncStateSwim(owner, position, SwimSyncType.k_Sprint, angle)
    StateSwimHero.PlayEffect(owner, stateSwimParam)
end

function StateSwimHero.OnSwimSprint(owner, eventName)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if eventName == AnimationEventDefines.k_EventRearSwing then
        stateSwimParam.m_SwimType = SwimType.k_SprintCast
        owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
        owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
        ---camera_input_source.RePressAction(SGameInputSource.ACTION_CAMERA_SWIM_SPRINT_END)
    elseif eventName == AnimationEventDefines.k_EventEnd then
        StateSwimHero.SwimIdle(owner)
    end
end

function StateSwimHero.SwimIdle(owner)
    --Logger.LogInfo("StateSwimHero.SwimIdle ")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if stateSwimParam.m_SwimType == SwimType.k_Idle then
        return
    end
    local angle = owner:GetAngle()
    if SGEngine.Core.InputManager.Instance.JoystickAngle == 0 then
        angle = math.floor(angle)
        owner:SetAngle(angle)
        owner:SetStateTargetAngle(StateDefine.k_StateSwim, angle)
    end

    owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
    owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
    StateSwimHero.PlayAnimation(owner, StateConsts.k_SwimIdle)
    stateSwimParam.m_SwimType = SwimType.k_Idle
    StateSwimHero.SetCoreMovableAndIgnoreJoystick(owner, false, false)
    StateSwimHero.SyncSwimIdle(owner, angle)
    StateSwimHero.SetSprintBtnActive(true)
    StateSwimHero.SetDiveBtnActive(not stateSwimParam.m_IsDiving)
    StateSwimHero.PlayEffect(owner, stateSwimParam)
end

function StateSwimHero.SwimMove(owner)
    --Logger.LogInfo("StateSwimHero.SwimMove ")
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    if stateSwimParam.m_SwimType ~= SwimType.k_Swim then
        stateSwimParam.m_SwimType = SwimType.k_Swim
        StateSwimHero.PlayAnimation(owner, StateConsts.k_SwimMove)
        StateSwimHero.PlayEffect(owner, stateSwimParam)
    end
    StateSwimHero.SetCoreMovableAndIgnoreJoystick(owner, true, false)
    StateSwimHero.SetSprintBtnActive(true)
    StateSwimHero.SetDiveBtnActive(not stateSwimParam.m_IsDiving)
end

function StateSwimHero.InitUI()
    local skillView = UIManager.GetUI("SkillView")
    if skillView then
        skillView:SetSwimBtnActive(true)
        skillView:SetLoadModelActive(true)
        skillView:SetOnRideBtnActive(false)
    end
end

function StateSwimHero.CloseUI()
    local skillView = UIManager.GetUI("SkillView")
    if skillView then
        skillView:SetSwimBtnActive(false)
        skillView:SetLoadModelActive(true)
        skillView:SetOnRideBtnActive(true)
    end
end

function StateSwimHero.AdjustUI(isDiving)
    local skillView = UIManager.GetUI("SkillView")
    if skillView then
        skillView:SetSwimBtnActive(not isDiving)
        skillView:SetLoadModelActive(not isDiving)
        skillView:SetOnRideBtnActive(false)
    end
end

function StateSwimHero.PlayEffect(owner, stateSwimParam)
    local swimType = stateSwimParam.m_SwimType
    local config = owner.m_CharacterConfig
    if swimType == SwimType.k_Diving then
         return
    end

    StateSwimHero.StopEffect(owner, stateSwimParam)
    if stateSwimParam.m_IsDiving == true then
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

function StateSwimHero.StopEffect(owner, stateSwimParam, immediateDestroy)
    if stateSwimParam.m_CurrentSwimEffectIndex == nil then
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

function StateSwimHero.ChangeCoreToJumpDiving(owner)
    StateSwimHero.SetParamToCore(owner, true)
end

function StateSwimHero.ChangeCoreToDiveSwim(owner)
    StateSwimHero.SetParamToCore(owner, 0, 0, 0, true)
end

function StateSwimHero.ChangeCoreToLerpForward(owner)
    StateSwimHero.SetParamToCore(owner, true)
end

function StateSwimHero.ChangeCoreToAboveWaterSwim(owner)
    StateSwimHero.SetParamToCore(owner, 0, 0, 0, false)
end

function StateSwimHero.ChangeCoreToDivingSwim(owner, divingDirectionX, divingDirectionY, divingDirectionZ)
    StateSwimHero.SetParamToCore(owner, divingDirectionX, divingDirectionY, divingDirectionZ, true)
end

function StateSwimHero.SetCoreMovableAndIgnoreJoystick(owner, isMovable, isIgnoreJoystick)
    StateSwimHero.SetParamToCore(owner, isMovable, isIgnoreJoystick)
end

function StateSwimHero.SetParamToCore(owner, ...)
    owner.m_Core:OnSyncState(StateDefine.k_StateSwim, ...)
end

function StateSwimHero.OnBeginMove(owner, stateComponent)    
    local stateSwimParam = stateComponent.m_StateSwimParam
    local swimType = stateSwimParam.m_SwimType
    --Logger.LogInfo("StateSwimHero.OnBeginMove  swimType:"..swimType)
    if 
    swimType ~= SwimType.k_Sprint
    and swimType ~= SwimType.k_Diving
    and swimType ~= SwimType.k_JumpDiving
    --and swimType ~= SwimType.k_DivingCast
    then
        if stateSwimParam.m_IsDiving == true then
            StateSwimHero.ChangeCoreToDiveSwim(owner)
        end
        owner:SetCurrentMoveSpeed(owner.m_CharacterConfig.SwimSpeed)
        owner:SetCurrentRotateSpeed(owner.m_CharacterConfig.SwimRotateSpeed)
        StateSwimHero.SwimMove(owner)
    end
end

function StateSwimHero.OnStopMove(owner, stateComponent)
    local stateSwimParam = stateComponent.m_StateSwimParam
    local swimType = stateSwimParam.m_SwimType
    if 
    swimType ~= SwimType.k_Sprint and 
    swimType ~= SwimType.k_JumpDiving and
    swimType ~= SwimType.k_DivingCast and
    swimType ~= SwimType.k_Diving 
    then
        if stateSwimParam.m_IsDiving == true then
            StateSwimHero.ChangeCoreToDiveSwim(owner)
        end
        StateSwimHero.SwimIdle(owner)
    end
end

function StateSwimHero.IsAlmostAboveWater(owner, offset)
    offset = offset or 0
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    local waterHeight = stateSwimParam.m_WaterHeight
    local swimHangPoint = owner:GetBodyPartTransform(StateConsts.k_SwimPoint)
    local currentPosition

    if not swimHangPoint then
        currentPosition = owner:GetPosition()
    else
        currentPosition = swimHangPoint.position
    end

    local positionY = owner:GetPositionY()
    local inWaterOffset = stateSwimParam.m_InWaterOffset

    if positionY + inWaterOffset >= waterHeight - offset then
        return true
    end

    return false
end

function StateSwimHero.FixAboveWaterPosition(owner)
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
        --Logger.LogInfo("StateSwimHero.FixAboveWaterPosition , position: %s,%s,%s", position.x, position.y, position.z)
        owner:SetPosition(position)
    end
end

function StateSwimHero.CheckExit(owner)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    local waterHeight = stateSwimParam.m_WaterHeight
    if waterHeight == nil then
        return
    end
    local groundHeight = stateSwimParam.m_GroundHeight
    if groundHeight == nil then
        return
    end

    local config = owner.m_CharacterConfig
    local positionY = owner:GetPositionY()
    local waterDiff = waterHeight - positionY
    local waterDepth = waterHeight - groundHeight
    if waterDiff <= config.ExitWaterDepth and waterDepth < config.ExitWaterDepth then
        owner:SetAngleXYZ(0, owner:GetAngle(), 0)
        --local position = owner:GetPosition()
        --Logger.LogInfo("StateSwimHero.CheckExit , position: %s,%s,%s", position.x, position.y, position.z)
        StateSwimHero.SyncSwimStop(owner)
        owner:DelState(StateDefine.k_StateSwim, nil)
    end
end

function StateSwimHero.SetSprintBtnActive(active)
    local skillView = UIManager.GetUI("SkillView")
    if skillView then
        skillView:SetSprintBtnActive(active)
    end
end

function StateSwimHero.SetDiveBtnActive(active)
    local skillView = UIManager.GetUI("SkillView")
    if skillView then
        skillView:SetSwimDiveBtnActive(active)
    end
end

--------------------------------------------------------------------Sync----------------------------------------------------------------------------------
function StateSwimHero.SyncStateSwim(owner, position, swimSyncType, angle)
    if angle == nil then
        angle = owner:GetAngle()
    end
    BattleMessage.SendSyncSwim(position, angle, swimSyncType)
end

function StateSwimHero.SyncSwimStop(owner)
    local angle = owner:GetAngle()
    local position = owner:GetPosition()
    BattleMessage.SendSyncSwim(position, angle, SwimSyncType.k_Stop)
end

function StateSwimHero.SyncSwimIdle(owner, angle)
    local position = owner:GetPosition()
    --local color = UnityEngine.Color.blue
    --local DebugDraw = SGEngine.Core.DebugDraw
    --DebugDraw.CreateGo(position, color, 0, "S", angle)
    BattleMessage.SendSyncSwim(position, angle, SwimSyncType.k_Idle)
end

function StateSwimHero.SyncMove(owner, targetAngle)
    if not targetAngle then
        targetAngle = owner:GetStateTargetAngle(StateDefine.k_StateSwim)
    end

    local position = owner:GetPosition()
    local syncType
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    local swimType = stateSwimParam.m_SwimType
    if swimType == SwimType.k_Swim then
        syncType = SwimSyncType.k_SwimMove
    elseif swimType == SwimType.k_Sprint or swimType == SwimType.k_SprintCast or swimType == SwimType.k_Diving then
        syncType = SwimSyncType.k_SprintMove
    elseif swimType == SwimType.k_JumpDiving then
        --syncType = SwimSyncType.k_JumpDivingMove
    end
    if syncType == nil then
        return
    end

    local pos
    local predictStepCount = SyncConsts.k_SyncPosPredictCount
    if predictStepCount > 0 then
        local isDiving = stateSwimParam.m_IsDiving
        if isDiving then
            pos = owner:PredictPosByControllerWithCurrentForward(owner:GetCurrentMoveSpeed(), predictStepCount)
        else
            pos = owner:PredictPosByController(targetAngle, owner:GetCurrentMoveSpeed(), predictStepCount)
        end
    else
        pos = position
    end
    --Logger.LogInfo("StateSwimHero.SyncMove SendSyncSwim")
    BattleMessage.SendSyncSwim(pos, targetAngle, syncType)
end

function StateSwimHero.CheckSync(owner)
    local targetAngle = owner:GetStateTargetAngle(StateDefine.k_StateSwim)
    if StateSwimHero.NeedSync(owner, targetAngle) then
        --Logger.LogInfo("StateSwimHero.CheckSync NeedSync")
        StateSwimHero.SyncMove(owner, targetAngle)
    end
end

function StateSwimHero.NeedSync(owner, targetAngle)
    local stateSwimParam = owner.m_StateComponent.m_StateSwimParam
    local swimType = stateSwimParam.m_SwimType

    if swimType == SwimType.k_Idle then
        return false
    end

    if stateSwimParam.m_FrameCount % SyncConsts.k_SyncPosFrameCount == 0 then
        return true
    end
    local currentAngle = owner:GetAngle()
    if math.abs(targetAngle - currentAngle) >= SyncConsts.k_SyncPosDifAngle then
        return true
    end
    return false
end

return StateSwimHero