---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/12/27 17:52
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local FightResultBase = require("MainGame/Game/Logic/Skill/FightResult/FightResultBase")
local ObjectPool = require("MainGame/Game/Logic/Skill/ObjectPool")
local FightResultAddBuff = class("FightResultAddBuff", FightResultBase)
local FightResultType = ComponentDefine.FightResultType
FightResultAddBuff.m_FightResultType = FightResultType.k_AddBuff
if FightResultAddBuff.m_Pool == nil then
    FightResultAddBuff.m_Pool = ObjectPool.CreatePool(FightResultAddBuff)
end

function FightResultAddBuff.Ctor()
    FightResultAddBuff.__super.Ctor(self)
end

function FightResultAddBuff.Get()
    local pool = FightResultAddBuff.m_Pool
    if pool then
        return pool:Get()
    end
end

function FightResultAddBuff:Recycle()
    local pool = FightResultAddBuff.m_Pool
    if pool then
        pool:Recycle(self, true)
    end
end

function FightResultAddBuff:Init(attackObjectId)
    FightResultAddBuff.__super.Init(self)
    self.m_AttackObjectId = attackObjectId
end

function FightResultAddBuff:Deserialize(netBuffer)
    self.m_TargetID = netBuffer:ReadUInt()
    self.m_Sn = netBuffer:ReadUInt()
    self.m_BuffID = netBuffer:ReadUInt()
    self.m_Time = netBuffer:ReadUInt()
    self.m_HitPoint = netBuffer:ReadUByte()
    local effectNum = netBuffer:ReadInt()
    for i = 1, effectNum do
        local effectId = netBuffer:ReadInt()
        local paramNum = netBuffer:ReadInt()
        for i = 1, paramNum do
            local param = netBuffer:ReadInt()
        end
    end
    --Logger.LogInfo("[FightResultAddBuff]Deserialize FightResultAddBuff:m_TargetID:{%d},m_HitPoint:{%d},m_Sn:{%s},m_BuffID:{%s}, m_Time:{%s}, effectNum:{%s}",
    --        self.m_TargetID, self.m_HitPoint, self.m_Sn, self.m_BuffID, self.m_Time, effectNum)
end

function FightResultAddBuff:Execute()
    local object = ObjectManager.GetObject(self.m_TargetID)
    if not object then
        return
    end

    if object:IsValid() == false then
        return
    end
end

return FightResultAddBuff