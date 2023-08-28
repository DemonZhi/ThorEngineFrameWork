--网络数据发送
local StateDefine = SGEngine.Core.StateDefine
local Core_EntityUtility = SGEngine.Core.EntityUtility
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local StateJump = class("StateJump", StateBase)
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local BattleMessage = require("MainGame/Message/BattleMessage")
local JumpStage = ComponentDefine.JumpStage
local JumpType = ComponentDefine.JumpType
local SyncConsts = ComponentDefine.SyncConsts
local AttributeDefine = ComponentDefine.AttributeDefine
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
local DebugDraw = SGEngine.Core.DebugDraw
local Vector3Zero = Vector3.zero
StateJump.k_DefaultPeakTime = 0.2
StateJump.k_CheckWaveOffset = 10

function StateJump.Ctor(owner, stateComponent)
    StateJump.__super.Ctor(owner, stateComponent)
    if stateComponent.m_StateJumpParam == nil then
        stateComponent.m_StateJumpParam = {}
    end
end

function StateJump.Init(owner, stateComponent)
    --Logger.LogInfo("[StateJump](Init), frame:%s", Time.frameCount)
    local stateJumpParam = stateComponent.m_StateJumpParam
    local isHero = owner:IsHero()
    StateJump.__super.Init(owner, stateComponent)
    stateJumpParam.m_FrameCount = 0
    stateJumpParam.m_IsMoveEnd = false
    stateJumpParam.m_IsHero = isHero
    stateJumpParam.m_StopPosition = nil
    stateJumpParam.m_StopAngle = nil
    stateJumpParam.m_HasChangedGravity = false
    StateJump.ClearCheckInSwim3rd(stateJumpParam)
    local speedXZ = stateJumpParam.m_SpeedXZ
    local jumpType = StateJump.InitJumpType(owner, speedXZ)
    StateJump.InitJumpAnimation(owner, jumpType)
    local gravity, jumpHeight, peakTime = StateJump.InitParams(owner, isHero)
    owner:SetCurrentGravity(gravity)
    owner:SetCurrentMoveSpeed(speedXZ)
    if jumpHeight == 0 then
        StateJump.JumpIdle(owner)
    else
        StateJump.JumpPre(owner)
    end
    --Logger.LogInfo("StateJump.Init: speedXZ: %s, jumpHeight: %s, peakTime: %s, gravity: %s, frame: %d", tostring(speedXZ), tostring(jumpHeight), tostring(peakTime), tostring(gravity), Time.frameCount)
    if isHero then
        StateJump.SyncStateJump(owner, speedXZ, jumpHeight, peakTime, jumpType)
    else
        owner.m_StateCheckerComponent:SetSwimCheckActive(true)
    end
end

function StateJump.Destroy(owner, stateComponent)    
    --Logger.LogInfo("[StateJump](Destroy)")
    local stateJumpParam = stateComponent.m_StateJumpParam
    local isHero = stateJumpParam.m_IsHero
    stateJumpParam.m_HasReachTop = false
    stateJumpParam.m_Gravity = 0

    local isSwim = owner:IsNextState(StateDefine.k_StateSwim)
    if isSwim == false and stateJumpParam.jumpToSwim == nil then
        owner:SetCurrentGravity(0)
        owner:SetCurrentMoveSpeedY(0)
    end
    
    if isHero then
        if stateJumpParam.m_JumpType == JumpType.k_RideJump then
            StateJump.SyncJumpStop(owner)
        elseif stateJumpParam.m_JumpType == JumpType.k_SprintJump then
            ActionController.SetSprintAttackBtnActive(false)
        end       
    else
        -- 3rd 
        owner.m_StateCheckerComponent:SetSwimCheckActive(false)
    end
    --owner:FixPositionY()
    stateJumpParam.m_JumpType = nil
    owner:UnRegAnimationCallBack(stateJumpParam.m_CurrentJumpPre)
    owner:UnRegAnimationCallBack(stateJumpParam.m_CurrentJumpCast)
    StateJump.__super.Destroy(owner, stateComponent)
end

function StateJump.InitJumpType(owner, speedXZ)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam 

    if stateJumpParam.m_IsHero == true then
        return StateJump.InitJumpTypeHero(owner, stateJumpParam, speedXZ)
    else
        return stateJumpParam.m_JumpType
    end    
end

function StateJump.InitJumpTypeHero(owner, stateJumpParam, speedXZ)
    local jumpType
    if owner:IsState(StateDefine.k_StateRide) then
        jumpType = JumpType.k_RideJump
    else
        local runJumpSpeed = owner.m_CharacterConfig.CheckRunJumpSpeed
        local sprintJumpSpeed = owner.m_CharacterConfig.CheckSprintJumpSpeed
        if speedXZ < runJumpSpeed then
            jumpType = JumpType.k_StandJump
        else
            if StateJump.IsCanDiveJump(owner, speedXZ, stateJumpParam) then
                jumpType = JumpType.k_DiveJump
            elseif speedXZ < sprintJumpSpeed then
                jumpType = JumpType.k_RunJump
            else
                ActionController.SetSprintAttackBtnActive(true)
                jumpType = JumpType.k_SprintJump
            end
        end
    end
    stateJumpParam.m_JumpType = jumpType
    --Logger.LogInfo("[StateJump](InitJumpType) jumpType: %d", jumpType)
    return jumpType
end

function StateJump.IsCanDiveJump(owner, speedXZ, stateJumpParam)
    local peakTime = owner:GetTimeBetweenAnimationEvent(StateConsts.k_DiveJumpPre, AnimationEventDefines.k_EventFrontSwing, AnimationEventDefines.k_EventRearSwing)
    --Logger.LogInfo("[StateJump](IsCanDiveJump) peakTime :"..peakTime)
    local jumpHeight = stateJumpParam.m_JumpHeight   
    local diveJumpSpeed = speedXZ
    local curPosition = owner:GetPosition() -- XYZ
    --Logger.LogInfo("[StateJump](IsCanDiveJump) diveJumpSpeed :"..diveJumpSpeed)
    -- 估算水面高度
    local firstPredictPosition = curPosition + owner:GetForward() * diveJumpSpeed * peakTime * 2 
    --Logger.LogInfo("[StateJump](IsCanDiveJump) firstPredictPosition: %s", tostring(firstPredictPosition))
    local waterHeight = Core_EntityUtility.GetWaterHeightByPositionXYZ(firstPredictPosition.x, firstPredictPosition.y, firstPredictPosition.z)
    local divingPlatformHeight = curPosition.y - waterHeight
    --Logger.LogInfo("[StateJump](IsCanDiveJump) divingPlatformHeight: %s", tostring(divingPlatformHeight))
    local minJumpDepth = 2.5 -- TO DO 状态机配置  GetForward 一次
    -- 当前跳台高度小于跳水高度 无法跳水
    if divingPlatformHeight < minJumpDepth then
        return false
    end

    -- 估算跳跃最高点位置
    local jumpHightPosition = Vector3Zero
    jumpHightPosition.x = curPosition.x
    jumpHightPosition.y = curPosition.y + jumpHeight
    jumpHightPosition.z = curPosition.z    
    local gravity = -(2 * jumpHeight) / (peakTime * peakTime)
    local gravityFactor = owner.m_CharacterConfig.SpringJumpGravityFactor
    gravity = gravity * gravityFactor
    --Logger.LogInfo("[StateJump](IsCanDiveJump) gravity :"..gravity)
    --Logger.LogInfo("[StateJump](IsCanDiveJump) gravityFactor :"..gravityFactor)
    -- 估算跳水高度与下落时间 
    --Logger.LogInfo("[StateJump](IsCanDiveJump) waterHeight: %s", tostring(waterHeight))
    local maxJumpDepth = jumpHightPosition.y - waterHeight
    --Logger.LogInfo("[StateJump](IsCanDiveJump) maxJumpDepth: %s", tostring(maxJumpDepth))
    local fallTime = math.sqrt( 2 * maxJumpDepth / math.abs(gravity))

    -- 估算落水点位置 diveJumpSpeedXZ   改成XYZ计算
    local predictPosition = curPosition + owner:GetForward() * diveJumpSpeed * (peakTime + fallTime) 
    predictPosition.y = waterHeight
    jumpHightPosition = jumpHightPosition + owner:GetForward() * diveJumpSpeed * peakTime * 2
    -- Logger.LogInfo("[StateJump](IsCanDiveJump) speedXZ :"..speedXZ)
    -- Logger.LogInfo("[StateJump](IsCanDiveJump) peakTime :"..peakTime)
    -- Logger.LogInfo("[StateJump](IsCanDiveJump) curPosition x:"..curPosition.x.." y:"..curPosition.y.." z:"..curPosition.z)
    -- Logger.LogInfo("[StateJump](IsCanDiveJump) predictPosition x:"..predictPosition.x.." y:"..predictPosition.y.." z:"..predictPosition.z)
    
    -- 关键位置 DebugDraw
    -- local color = UnityEngine.Color.blue
    -- DebugDraw.CreateGo(curPosition, color, 0, "curPosition")
    -- local color2 = UnityEngine.Color.yellow
    -- DebugDraw.CreateGo(jumpHightPosition, color2, 0, "jumpHightPosition")
    -- local color3 = UnityEngine.Color.white
    -- DebugDraw.CreateGo(predictPosition, color3, 0, "predictPosition")

    -- 估算水深
    local groundHeight = Core_EntityUtility.GetGroundHeightXYZ(predictPosition.x, predictPosition.y, predictPosition.z)
    local waterDepth = math.abs(waterHeight) - math.abs(groundHeight)
    --Logger.LogInfo("[StateJump](IsCanDiveJump) waterDepth :" .. waterDepth )
    -- 跳水水深限制
    local minDiveWaterDepth = 2 -- TO DO 状态机配置
    if waterDepth < minDiveWaterDepth then
        return false
    end

    -- 估算起跳路线  
    local direction = jumpHightPosition - curPosition
    local distance = diveJumpSpeed * peakTime + jumpHeight + 2
    local radius = 1 -- 获取Object 半径 Offset
    local rayCastStartPoint = curPosition - owner:GetForward() * 1
    -- 起跳路线障碍检测
    local bIsUpObstacle = Core_EntityUtility.SphereCastGroundMaskXYZ(rayCastStartPoint.x, rayCastStartPoint.y + 1, rayCastStartPoint.z, direction.x, direction.y, direction.z, radius, distance)
    -- Logger.LogInfo("[StateJump](IsCanDiveJump) bIsUpObstacle :" .. 1 )    
    if bIsUpObstacle == true then
        return false
    end

    -- 估算落水路线
    direction =  predictPosition - jumpHightPosition
    local distance = Vector3.Distance(jumpHightPosition, predictPosition)    
    -- 落水路线障碍检测
    local bIsDownObstacle = Core_EntityUtility.SphereCastGroundMaskXYZ(jumpHightPosition.x, jumpHightPosition.y, jumpHightPosition.z, direction.x, direction.y, direction.z, radius, distance)
    --Logger.LogInfo("[StateJump](IsCanDiveJump) bIsDownObstacle :" .. 2 )
    if bIsDownObstacle == true then
        return false
    end
    return true
end

function StateJump.InitJumpAnimation(owner, jumpType)
    --Logger.LogInfo("[StateJump](InitJumpAnimation) jumpType: %s", tostring(jumpType))
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam

    if jumpType == JumpType.k_RunJump then
        stateJumpParam.m_CurrentJumpPre = StateConsts.k_RunJumpPre
        stateJumpParam.m_CurrentJumpIdle = StateConsts.k_RunJumpIdle
        stateJumpParam.m_CurrentJumpCast = StateConsts.k_RunJumpCast
    elseif jumpType == JumpType.k_StandJump then
        stateJumpParam.m_CurrentJumpPre = StateConsts.k_StandJumpPre
        stateJumpParam.m_CurrentJumpIdle = StateConsts.k_StandJumpIdle
        stateJumpParam.m_CurrentJumpCast = StateConsts.k_StandJumpCast
    elseif jumpType == JumpType.k_SprintJump then
        stateJumpParam.m_CurrentJumpPre = StateConsts.k_SprintJumpPre
        stateJumpParam.m_CurrentJumpIdle = StateConsts.k_SprintJumpIdle
        stateJumpParam.m_CurrentJumpCast = StateConsts.k_SprintJumpCast
    elseif jumpType == JumpType.k_RideJump then
        stateJumpParam.m_CurrentJumpPre = StateConsts.k_RideJumpPre
        stateJumpParam.m_CurrentJumpIdle = StateConsts.k_RideJumpIdle
        stateJumpParam.m_CurrentJumpCast = StateConsts.k_RideJumpCast
    elseif jumpType == JumpType.k_DiveJump then
        stateJumpParam.m_CurrentJumpPre = StateConsts.k_DiveJumpPre
        stateJumpParam.m_CurrentJumpIdle = StateConsts.k_DiveJumpIdle
        stateJumpParam.m_CurrentJumpCast = StateConsts.k_DiveJumpCast
    else
        Logger.Error("[StateJump](InitJumpAnimation) Invalid jumpType: %s", tostring(jumpType))
    end
end

function StateJump.InitParams(owner, isHero)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    --gravity
    local gravity
    --jumpHeight
    local jumpHeight = stateJumpParam.m_JumpHeight
    --peakTime
    if isHero then
        StateJump.InitPeakTime(owner)
    end
    local peakTime = stateJumpParam.m_PeakTime
    
    if jumpHeight == 0 then
        gravity = -owner.m_AttrComponent:GetAttribute(AttributeDefine.k_FallGravity)
    else
        gravity = -(2 * jumpHeight) / (peakTime * peakTime)
    end

      if stateJumpParam.m_JumpType == JumpType.k_DiveJump then
        gravity = gravity / 1
    end

    stateJumpParam.m_Gravity = gravity
    StateJump.InitLandTime(owner)
    --Logger.LogInfo("[StateJump](IsCanDiveJump) InitParams  gravity:" .. gravity .. " jumpHeight:"..jumpHeight .. " peakTime:"..peakTime)
    return gravity, jumpHeight, peakTime
end

function StateJump.InitPeakTime(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    local peakTime
    if stateJumpParam.m_JumpType == JumpType.k_RideJump then
        local mount = stateComponent.m_StateRideParam.m_Mount
        peakTime = mount:GetTimeBetweenAnimationEvent(StateConsts.k_RideJumpPre, AnimationEventDefines.k_EventFrontSwing, AnimationEventDefines.k_EventRearSwing)
    else
        peakTime = owner:GetTimeBetweenAnimationEvent(stateJumpParam.m_CurrentJumpPre, AnimationEventDefines.k_EventFrontSwing, AnimationEventDefines.k_EventRearSwing)
    end
    if peakTime < 0 then
        peakTime = StateJump.k_DefaultPeakTime
    end
    stateJumpParam.m_PeakTime = peakTime
   -- Logger.LogInfo("[StateJump](InitPeakTime) peakTime :"..peakTime)
end

function StateJump.InitLandTime(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    local stateRideData = stateComponent.m_StateRideParam
    local jumpType = stateJumpParam.m_JumpType
    local landTime
    if jumpType == JumpType.k_RideJump then
        local mount = stateRideData.m_Mount
        if mount ~= nil and mount:IsModelLoadFinish() == true then
            landTime = mount:GetTimeBetweenAnimationEvent(StateConsts.k_RideJumpCast, AnimationEventDefines.k_EventStart, AnimationEventDefines.k_EventFrontSwing)
        else
            landTime = 0.1
        end
    else
        landTime = owner:GetTimeBetweenAnimationEvent(stateJumpParam.m_CurrentJumpCast, AnimationEventDefines.k_EventStart, AnimationEventDefines.k_EventFrontSwing)
    end
    stateJumpParam.m_LandTime = landTime
end

function StateJump.SetParamToCore(owner, ...)
    owner.m_Core:OnSyncState(StateDefine.k_StateJump, ...)
end

function StateJump.JumpIdle(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    if stateJumpParam.m_LandTime < 0 then
        StateJump.InitLandTime(owner)
    end

    stateJumpParam.m_JumpStage = JumpStage.k_Idle
    StateJump.PlayAnimation(owner, stateJumpParam.m_CurrentJumpIdle)
    if stateJumpParam.m_JumpType == JumpType.k_RideJump then
        StateJump.PlayMountAnimation(owner, StateConsts.k_RideJumpIdle)
    end

    --Logger.LogInfo("JumpIdle: %d", Time.frameCount)
    --t2 = Time.time
    --if t1 then
    --    Logger.LogInfo("JumpPre totalTime:"..t2-t1)
    --end
end

function StateJump.JumpPre(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    stateJumpParam.m_JumpStage = JumpStage.k_Pre
    if stateJumpParam.m_JumpType == JumpType.k_RideJump then
        StateJump.PlayAnimation(owner, stateJumpParam.m_CurrentJumpPre)
        StateJump.PlayMountAnimation(owner, StateConsts.k_RideJumpPre, function(eventName)
            StateJump.OnJumpPre(owner, eventName)
        end)
    else
        StateJump.PlayAnimation(owner, stateJumpParam.m_CurrentJumpPre, 0.1, function(eventName)
            StateJump.OnJumpPre(owner, eventName)
        end)
    end
    --Logger.LogInfo("JumpPre: %d", Time.frameCount)
    --t1 = Time.time
end

function StateJump.OnJumpPre(owner, eventName)
    if eventName == AnimationEventDefines.k_EventFrontSwing then
        local stateComponent = owner.m_StateComponent
        local stateJumpParam = stateComponent.m_StateJumpParam
        local speedY = math.abs(stateJumpParam.m_Gravity * stateJumpParam.m_PeakTime)
        owner:SetCurrentMoveSpeedY(speedY)
    elseif eventName == AnimationEventDefines.k_EventEnd then
        StateJump.JumpIdle(owner)
    end
end

function StateJump.JumpCast(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    stateJumpParam.m_JumpStage = JumpStage.k_Cast
    if stateJumpParam.m_JumpType == JumpType.k_RideJump then
        StateJump.PlayAnimation(owner, stateJumpParam.m_CurrentJumpIdle)
        StateJump.PlayMountAnimation(owner, StateConsts.k_RideJumpCast, function(eventName)
            StateJump.OnJumpCast(owner, eventName)
        end)
    else
        if stateJumpParam.m_JumpType == JumpType.k_SprintJump then
            if owner:IsHero() == false then
                stateJumpParam.m_CurrentJumpCast = StateConsts.k_SprintJumpCastMove
            elseif SGEngine.Core.InputManager.Instance.JoystickAngle ~= 0 then
                stateJumpParam.m_CurrentJumpCast = StateConsts.k_SprintJumpCastMove
            end
        end
        StateJump.PlayAnimation(owner, stateJumpParam.m_CurrentJumpCast, 0.1, function(eventName)
            StateJump.OnJumpCast(owner, eventName)
        end)
    end
    --Logger.LogInfo("JumpCast: %d", Time.frameCount)
    --t3 = Time.time
    --if t2 then
    --    Logger.LogInfo("JumpIdle totalTime:"..t3-t2)
    --end
end

function StateJump.OnJumpCast(owner, eventName)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    if eventName == AnimationEventDefines.k_EventFrontSwing then
        --Logger.LogInfo("JumpCastFS: %d", Time.frameCount)
        --t4 = Time.time
        --if t3 then
        --    Logger.LogInfo("JumpCast totalTime:"..t4-t3)
        --end
        stateJumpParam.m_JumpStage = JumpStage.k_Landing
        if owner:IsHero() and stateJumpParam.m_JumpType ~= JumpType.k_RideJump then
            StateJump.SyncJumpStop(owner)
        end
        if stateJumpParam.m_JumpType ~= JumpType.k_RideJump then
            --stateJumpParam.m_EndPosition = owner:GetPosition()
            --Logger.LogInfo("Jump Has moved %s", stateJumpParam.m_StartPosition:Sub(stateJumpParam.m_EndPosition):SqrMagnitude())
            stateJumpParam.m_IsMoveEnd = true
            StateJump.SetParamToCore(owner, true)
        end
    elseif eventName == AnimationEventDefines.k_EventLand then
        local x, y, z = owner:GetPositionXYZ()
        Core_EntityUtility.CheckAndAddWave(x, y, z, StateJump.k_CheckWaveOffset, owner.m_CharacterConfig.JumpWaveStrength)
    elseif eventName == AnimationEventDefines.k_EventRearSwing then
        stateJumpParam.m_JumpStage = JumpStage.k_Landed
    elseif eventName == AnimationEventDefines.k_EventEnd then
        if stateJumpParam.m_StopPosition ~= nil then
            owner:SetPosition(stateJumpParam.m_StopPosition)
            owner:SetAngle(stateJumpParam.m_StopAngle)
        end
        owner:DelState(StateDefine.k_StateJump, nil)
    end

end

function StateJump.CanEnterCast(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    local speedY = owner:GetCurrentMoveSpeedY()
    if stateJumpParam.m_JumpStage == JumpStage.k_Idle and speedY <= 0 then
        local landTime = stateJumpParam.m_LandTime
        local gravity = stateJumpParam.m_Gravity
        local distance = math.abs(speedY * landTime + 0.5 * gravity * landTime * landTime)

        if owner:IsAlmostOnGround(distance) and StateJump.IsAboveWater(owner) then
            --Logger.LogInfo("IsAlmostOnGround, distance: %s, gravity: %s, landTime: %s", tostring(distance), tostring(gravity), tostring(landTime))
            return true
        end
    end
    return false
end

function StateJump.IsAboveWater(owner)
    local curPosition = owner:GetPosition()
    local waterHeight = Core_EntityUtility.GetWaterHeightByPositionXYZ(curPosition.x, curPosition.y, curPosition.z)
    if waterHeight > curPosition.y + 1 then
        return false
    end
    return true
end

function StateJump.PlayMountAnimation(owner, aniName, callBack)
    local stateRideData = owner.m_StateComponent.m_StateRideParam
    if not stateRideData then
        return
    end

    local mount = stateRideData.m_Mount
    if not mount then
        return
    end

    mount:PlayAnimation(aniName, nil, nil, nil, callBack)
end

function StateJump.Update(deltaTime, owner, stateComponent)
    if owner == nil then
        return
    end
    local stateJumpParam = stateComponent.m_StateJumpParam
    local isHero = stateJumpParam.m_IsHero
    stateJumpParam.m_FrameCount = stateJumpParam.m_FrameCount + 1

    StateJump.UpdateVerticalSpeed(deltaTime, owner)
    --StateJump.UpdateStage(owner)
    if StateJump.CanEnterCast(owner) then
        --Logger.LogInfo("StateJump.Update CanEnterCast: CanEnterCast")
        StateJump.JumpCast(owner)
    end

    if isHero == true and StateJump.NeedSync(owner) == true then
        StateJump.SyncJumpPos(owner)
    end
    --local color = UnityEngine.Color.red
    --DebugDraw.CreateGo(owner:GetPosition(), color)
end

function StateJump.UpdateVerticalSpeed(deltaTime, owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    local speedY = owner:GetCurrentMoveSpeedY()
    speedY = speedY + stateJumpParam.m_Gravity * deltaTime
    --Logger.LogInfo("StateJump.UpdateVerticalSpeed: speedY: %d", speedY)
    owner:SetCurrentMoveSpeedY(speedY)
    if speedY <= 0 and stateJumpParam.m_HasChangedGravity == false and stateJumpParam.m_JumpStage == JumpStage.k_Idle then
        StateJump.ApplyGravityFactor(owner)
    end
end

function StateJump.ApplyGravityFactor(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    if stateJumpParam.m_HasChangedGravity == true then
        return
    end
    local gravity = stateJumpParam.m_Gravity
    local jumpType = stateJumpParam.m_JumpType
    local gravityFactor
    if jumpType == JumpType.k_SprintJump then
        gravityFactor = owner.m_CharacterConfig.SpringJumpGravityFactor
        gravity = gravity * gravityFactor
        stateJumpParam.m_Gravity = gravity
        owner:SetCurrentGravity(gravity)
        stateJumpParam.m_HasChangedGravity = true
    elseif jumpType == JumpType.k_RideJump then
        gravityFactor = owner.m_CharacterConfig.RideAddGravityFactor
        gravity = gravity * gravityFactor
        stateJumpParam.m_Gravity = gravity
        owner:SetCurrentGravity(gravity)
        stateJumpParam.m_HasChangedGravity = true
    elseif jumpType == JumpType.k_DiveJump then
        gravityFactor = owner.m_CharacterConfig.SpringJumpGravityFactor
        gravity = gravity * gravityFactor
        stateJumpParam.m_Gravity = gravity
        owner:SetCurrentGravity(gravity)
        stateJumpParam.m_HasChangedGravity = true
    end
end

function StateJump.UpdateStage(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam
    if stateJumpParam.m_IsMoveEnd == true then
        return
    end
    local isMoveEnd
    local jumpStage = stateJumpParam.m_JumpStage
    local jumpType = stateJumpParam.m_JumpType
    if jumpType == JumpType.k_RideJump or jumpStage < JumpStage.k_Landing then
        isMoveEnd = false
    else
        isMoveEnd = true
    end

    if isMoveEnd ~= stateJumpParam.m_IsMoveEnd then
        stateJumpParam.m_IsMoveEnd = isMoveEnd
        StateJump.SetParamToCore(owner, isMoveEnd)
    end
end

function StateJump.OnBeginMove(owner, stateComponent)
    if owner:IsHero() == false then
        return
    end
    local stateJumpParam = stateComponent.m_StateJumpParam
    if stateJumpParam.m_JumpStage == JumpStage.k_Landed then
        if stateJumpParam.m_JumpType == JumpType.k_RideJump and owner:IsState(StateDefine.k_StateRide) then
            owner:DelState(StateDefine.k_StateJump, nil)
            local stateRide = owner:GetState(StateDefine.k_StateRide)
            stateRide.OnBeginMove(owner, stateComponent)
        else
            owner:ChangeToMove(nil, stateJumpParam.m_JumpType == JumpType.k_SprintJump)
        end
    end
end

function StateJump.CheckInSwim3rd(owner)
    local stateComponent = owner.m_StateComponent
    local stateJumpParam = stateComponent.m_StateJumpParam 
    stateJumpParam.m_SelfCheckInSwim = true
    stateJumpParam.m_LastSpeedY = owner:GetCurrentMoveSpeedY()
    stateJumpParam.m_LastSpeed = owner:GetCurrentMoveSpeed()
    --Logger.LogInfo("StateJump.CheckInSwim3rd   moveSpeedY: %s, moveSpeed %s ", stateJumpParam.m_LastSpeedY, stateJumpParam.m_LastSpeed)
end

function StateJump.ClearCheckInSwim3rd(stateJumpParam)
    stateJumpParam.m_SelfCheckInSwim = nil
    stateJumpParam.m_LastSpeedY = nil
    stateJumpParam.m_LastSpeed = nil
end
--------------------------------------------------------------------Sync----------------------------------------------------------------------------------
function StateJump.NeedSync(owner)
    local componentState = owner.m_StateComponent
    if componentState.m_StateJumpParam.m_FrameCount % SyncConsts.k_SyncPosFrameCount == 0 then
        return true
    end
    return false
end

function StateJump.SyncStateJump(owner, moveSpeed, jumpHeight, peakTime, jumpType)
    local position = owner:GetPosition()
    local angle = owner:GetAngle()
    BattleMessage.SendStateJump(position, angle, moveSpeed, jumpHeight, peakTime, jumpType)
end

function StateJump.SyncJumpPos(owner)
    local position = owner:GetPosition()
    BattleMessage.SendJumpPos(position)
end

function StateJump.SyncJumpStop(owner)
    local position = owner:GetPosition()
    local angle = owner:GetAngle()
    BattleMessage.SendJumpStop(position, angle)
end

function StateJump.OnSyncStateJump(owner, jumpType, moveSpeed, peakTime, jumpHeight)
    if owner == nil then
        Logger.LogInfo("[StateJump](OnSyncStateJump) owner nil")
        return
    end
   
    local componentState = owner.m_StateComponent
    local stateJumpParam = componentState.m_StateJumpParam
    stateJumpParam.m_JumpHeight = jumpHeight
    stateJumpParam.m_PeakTime = peakTime
    stateJumpParam.m_JumpType = jumpType
    stateJumpParam.m_SpeedXZ = moveSpeed
    --Logger.LogInfo("[StateJump](OnSyncStateJump) jumpType:%d ", jumpType)
    owner.m_Core:ChangeToJump()
end

function StateJump.OnSyncStateJumpStop(owner, stopPosition, stopAngle)
    local componentState = owner.m_StateComponent
    local stateJumpParam = componentState.m_StateJumpParam
    stateJumpParam.m_StopPosition = stopPosition
    stateJumpParam.m_StopAngle = stopAngle
    StateJump.SetParamToCore(owner, stopPosition, stopAngle)
end

return StateJump