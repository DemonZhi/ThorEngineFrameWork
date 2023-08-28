---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/12/27 17:52
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local FightResultBase = require("MainGame/Game/Logic/Skill/FightResult/FightResultBase")
local ObjectPool = require("MainGame/Game/Logic/Skill/ObjectPool")
local FightResultDaze = class("FightResultDaze", FightResultBase)
local FightResultType = ComponentDefine.FightResultType
FightResultDaze.m_FightResultType = FightResultType.k_Daze

if FightResultDaze.m_Pool == nil then
    FightResultDaze.m_Pool = ObjectPool.CreatePool(FightResultDaze)
end

function FightResultDaze.Ctor()
    FightResultDaze.__super.Ctor(self)
end

function FightResultDaze.Get()
    local pool = FightResultDaze.m_Pool
    if pool then
        return pool:Get()
    end
end

function FightResultDaze:Recycle()
    local pool = FightResultDaze.m_Pool
    if pool then
        pool:Recycle(self, true)
    end
end

function FightResultDaze:Init(attackObjectId)
    FightResultDaze.__super.Init(self)
    self.m_AttackObjectId = attackObjectId
end

function FightResultDaze:Deserialize(netBuffer)
    self.m_TargetID = netBuffer:ReadInt()
    self.m_PosX, self.m_PosY, self.m_PosZ, self.m_Angle = netBuffer:ReadPosAngle(nil, nil, nil, nil)
    self.m_HitPoint = netBuffer:ReadUByte()
    --Logger.LogInfo("[FightResultDaze]Deserialize FightResultDaze:m_TargetID:{%d},m_HitPoint:{%d}",
    --        self.m_TargetID, self.m_HitPoint)
end

function FightResultDaze:Execute()
    local object = ObjectManager.GetObject(self.m_TargetID)
    if not object then
        return
    end

    if object:IsValid() == false then
        return
    end

    ---进状态之前设位置是为了避免在退出跳跃状态时会向服务器发送Stop协议，这个位置并不是服务器结算时进Daze的位置
    ---服务器接到Stop后不会因为 当前是Daze而阻挡，会广播这个Stop，如果不设置位置，之后前端会收到不同位置的Stop而Set过去
    object:SetPositionXYZ(self.m_PosX, self.m_PosY, self.m_PosZ)
    object:ChangeToDaze()
end

return FightResultDaze