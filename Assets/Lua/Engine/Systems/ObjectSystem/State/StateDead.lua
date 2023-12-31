---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/2/24 11:55
---
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local StateDead = class("StateDead", StateBase)
local StateDeadType = {
    Normal = 0,
    DeathFly = 1,
}

function StateDead.Ctor(owner, stateComponent)
    StateDead.__super.Ctor(owner, stateComponent)
    stateComponent.m_StateDeadParam = {}
end

function StateDead.Init(owner, stateComponent)
    --Logger.LogInfo("[StateDead](Init), frame:%s, obj:%s", Time.frameCount, owner:GetObjectID())
    StateDead.__super.Init(owner, stateComponent)
    local param = stateComponent.m_StateDeadParam
    if param.m_Type == StateDeadType.DeathFly then
        StateDead.PlayAnimation(owner, StateConsts.k_DeathFliesAnimationName)
        StateDead.DeathFlyByLine(owner, param.m_Duration, param.m_Destination)
    else
        StateDead.PlayAnimation(owner, StateConsts.k_DeadAnimationName)
    end

    if owner:IsHero() then
        local skillView = UIManager.GetUI("SkillView")
        if skillView then
            skillView:SetReviveBtnActive(true)
        end
    end

    if owner:IsMonster() then
        local deadDissolveType = owner:GetDeadDissolveType()
        if deadDissolveType then
            owner:PlayDeadDissolve(deadDissolveType)
        end
    end
end

function StateDead.Destroy(owner, stateComponent)
    stateComponent.m_StateDeadParam = {}
    local param = stateComponent.m_StateDeadParam
    if param.m_Type == StateDeadType.DeathFly then
        owner.m_Core:StopLinearMove()
    end
    if owner:IsHero() then
        local skillView = UIManager.GetUI("SkillView")
        if skillView then
            skillView:SetReviveBtnActive(false)
        end
    end

    StateDead.__super.Destroy(owner, stateComponent)
end

function StateDead.DeathFlyByLine(owner, duration, destination)
    owner.m_Core:BeginLinearMove(destination, duration, true, true, nil)
end

return StateDead