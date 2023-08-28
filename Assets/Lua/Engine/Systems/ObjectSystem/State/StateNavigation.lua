local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local EventDefine = require("Engine/UI/Event/EventDefine")
local BattleMessage = require("MainGame/Message/BattleMessage")
local StateNavigation = class("StateNavigation", StateBase)
local StateDefine = SGEngine.Core.StateDefine
local AnimationEventDefines = SGEngine.Core.AnimationEventDefines
function StateNavigation.Ctor(owner, stateComponent)
    StateNavigation.__super.Ctor(owner, stateComponent)

    if stateComponent.m_StateNavigationParam == nil then
        stateComponent.m_StateNavigationParam = {}
    end
end

function StateNavigation.Init(owner, stateComponent)
    StateNavigation.__super.Init(owner, stateComponent)

    if owner:IsHero() then
        StateNavigation.SyncStateNavigateToServer(owner)
    end

    -- 如果上一状态为寻路、就不播动画了、避免重复播移动动画
    if not owner:IsLastState(StateDefine.k_StateNavigate) then
        if owner:IsState(StateDefine.k_StateRide) then
            StateNavigation.RideRun(owner)
        else
            local runAnimName = StateNavigation.GetRunAnimationName(owner)
            StateNavigation.PlayAnimation(owner, runAnimName)
        end
    end

    stateComponent.m_StateNavigationParam.m_NavigateFinishCallback = function(isFinish)
        owner.m_Core:DelState(StateDefine.k_StateNavigate)
        -- 下面的是移动的后摇逻辑 感觉不好 先不用
        -- if owner:IsState(StateDefine.k_StateRide) then
        --     local stateRideData = stateComponent.m_StateRideParam
        --     local config = stateRideData.m_MountConfig
        --     local mount = stateRideData.m_Mount
        --     StateNavigation.PlayAnimation(owner, config.RunStopAnimation, 0.1, function(eventName)
        --         if eventName == AnimationEventDefines.k_EventEnd then
        --             owner.m_Core:DelState(StateDefine.k_StateNavigate)
        --         end
        --     end)

        --     if mount:IsModelLoadFinish() == true then
        --         mount:PlayAnimation(StateConsts.k_RunStopAnimationName, 0, 0.1)
        --     end
        -- else
        --     if owner:ContainAnimation(StateConsts.k_RunStopAnimationName) then
        --         StateNavigation.PlayAnimation(owner, StateConsts.k_RunStopAnimationName, 0.1, function(eventName)
        --             if eventName == AnimationEventDefines.k_EventEnd then
        --                 owner.m_Core:DelState(StateDefine.k_StateNavigate)
        --             end
        --         end)
        --     else
        --         owner.m_Core:DelState(StateDefine.k_StateNavigate)
        --     end
        -- end
    end
    owner:RegNavigateFinishCallback(stateComponent.m_StateNavigationParam.m_NavigateFinishCallback)
end

function StateNavigation.Destroy(owner, stateComponent)
    StateNavigation.__super.Destroy(owner, stateComponent)
    owner:UnRegNavigateFinishCallback(stateComponent.m_StateNavigationParam.m_NavigateFinishCallback)
end

function StateNavigation.OnBeginMove(owner, stateComponent)
    owner:ChangeToMove()
end

function StateNavigation.RideRun(owner)
    local stateRideData = owner.m_StateComponent.m_StateRideParam
    local config = stateRideData.m_MountConfig
    local mount = stateRideData.m_Mount
    StateNavigation.PlayAnimation(owner, config.RunAnimation, 0)
    if mount:IsModelLoadFinish() == true then
        mount:PlayAnimation(StateConsts.k_RunAnimationName, 0, 0.1)
    end
end

function StateNavigation.GetRunAnimationName(owner)
    if owner:IsOnBattle() then
        return StateConsts.k_BattleRunAnimationName
    elseif owner.m_IsEquipTorch then
        return StateConsts.k_TorchRunAnimationName
    else
        return StateConsts.k_RunAnimationName
    end
end

--------------------------------------------------------------------Sync----------------------------------------------------------------------------------
function StateNavigation.SyncStateNavigateToServer(owner)
    local componentState = owner.m_StateComponent
    local position = owner:GetPosition()
    local angle = owner:GetAngle()
    BattleMessage.SendStateNavigate(position, angle, 1, 1, componentState.m_StateNavigationParam.m_PathPoints)
end

return StateNavigation