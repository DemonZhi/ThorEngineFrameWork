---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/10/28 15:30
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentMoveMonster = class("ComponentMoveMonster", ComponentBase)
local MoveSyncType = ComponentDefine.MoveSyncType
local StateDefine = SGEngine.Core.StateDefine

ComponentMoveMonster.m_ComponentId = ComponentDefine.ComponentType.k_ComponentMove

function ComponentMoveMonster:Init(object)
    ComponentMoveMonster.__super.Init(self, object)
    self.m_IsMoving = false
end

function ComponentMoveMonster:Destroy()
    ComponentMoveMonster.__super.Destroy(self)
end

function ComponentMoveMonster:Move(targetPos, angle)
    if not self.m_IsMoving or self.m_Owner:IsState(StateDefine.k_StateMove) == false then
        self.m_Owner.m_Core:ChangeToMove(targetPos, angle)
    else
        self.m_Owner.m_Core:OnSyncStateMove(StateDefine.k_StateMove, targetPos, angle)
    end
    self.m_IsMoving = true
end

function ComponentMoveMonster:StopMove()
    self.m_IsMoving = false
    self.m_Owner.m_Core:OnSyncStateStopMove(StateDefine.k_StateMove)
end

return ComponentMoveMonster