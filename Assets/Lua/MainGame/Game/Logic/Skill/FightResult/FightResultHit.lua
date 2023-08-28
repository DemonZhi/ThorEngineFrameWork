---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/9/17 10:31
---
---
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local FightResultBase = require("MainGame/Game/Logic/Skill/FightResult/FightResultBase")
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local ObjectPool = require("MainGame/Game/Logic/Skill/ObjectPool")
local FightResultHit = class("FightResultHit", FightResultBase)
local Core_EntityUtility = SGEngine.Core.EntityUtility
local FightResultType = ComponentDefine.FightResultType
local HitTypeEnum = StateConsts.HitTypeEnum

FightResultHit.m_FightResultType = FightResultType.k_Hit
if FightResultHit.m_Pool == nil then
    FightResultHit.m_Pool = ObjectPool.CreatePool(FightResultHit)
end

function FightResultHit.Ctor()
    FightResultHit.__super.Ctor(self)
end

function FightResultHit.Get()
    local pool = FightResultHit.m_Pool
    if pool then
        return pool:Get()
    end
end

function FightResultHit:Recycle()
    local pool = FightResultHit.m_Pool
    if pool then
        pool:Recycle(self, true)
    end
end

function FightResultHit:Init(actionId, hitPoint, damageKey)
    FightResultHit.__super.Init(self, actionId, hitPoint, damageKey)
end

function FightResultHit:DeserializeNormal(netBuffer)
    if self.m_Destination == nil then
        self.m_Destination = Vector3.New()
    end
    self.m_TargetID = netBuffer:ReadInt()
    self.m_HitType = netBuffer:ReadUByte()
    self.m_ActionId = netBuffer:ReadInt()
    self.m_Duration = netBuffer:ReadFloat()
    self.m_Destination.x = netBuffer:ReadFloat()
    self.m_Destination.y = netBuffer:ReadFloat()
    self.m_Destination.z = netBuffer:ReadFloat()
    self.m_Speed = netBuffer:ReadFloat()
    self.m_Angle = Core_EntityUtility.ServerAngleToClientAngle(netBuffer:ReadFloat())
    self.m_HitPoint = netBuffer:ReadUByte()
    --Logger.LogInfo("[FightResultHit]Deserialize FightResultHit:self.m_TargetID:{%d}, self.m_Duration:{%s}, m_HitType:{%s}, m_ActionId:{%s}, m_HitPoint:{%d}, m_Speed:{%s}, m_Angle:{%s}, frame:{%s}",
    --        self.m_TargetID, self.m_Duration, self.m_HitType, self.m_ActionId, self.m_HitPoint, self.m_Speed, self.m_Angle, Time.frameCount)
end

function FightResultHit:DeserializeHitFloat(netBuffer)
    if self.m_Destination == nil then
        self.m_Destination = Vector3.New()
    end
    self.m_TargetID = netBuffer:ReadInt()
    self.m_HitType = netBuffer:ReadUByte()
    self.m_ActionId = netBuffer:ReadInt()
    self.m_Duration = netBuffer:ReadFloat()
    self.m_Destination.x = netBuffer:ReadFloat()
    self.m_Destination.y = netBuffer:ReadFloat()
    self.m_Destination.z = netBuffer:ReadFloat()
    self.m_Speed = netBuffer:ReadFloat()
    self.m_Angle = Core_EntityUtility.ServerAngleToClientAngle(netBuffer:ReadFloat())
    self.m_HitPoint = netBuffer:ReadUByte()
    --Logger.LogInfo("[FightResultHit]DeserializeHitFloat FightResultHit:self.m_TargetID:{%d}, self.m_Duration:{%s}, m_HitType:{%s}, m_ActionId:{%s}, m_HitPoint:{%d}, m_Speed:{%s}, m_Angle:{%s}, frame:{%s}",
    --        self.m_TargetID, self.m_Duration, self.m_HitType, self.m_ActionId, self.m_HitPoint, self.m_Speed, self.m_Angle, Time.frameCount)
end

function FightResultHit:Execute()
    local object = ObjectManager.GetObject(self.m_TargetID)
    if not object then
        return
    end

    if object:IsValid() == false then
        return
    end
    if self.m_HitType == HitTypeEnum.HitFloat then
        object:ChangeToHitFloat(self.m_HitType, self.m_Duration, self.m_Destination, self.m_Speed, self.m_Angle)
    else
        object:ChangeToHit(self.m_HitType, self.m_Duration, self.m_Destination, self.m_Speed, self.m_Angle)
    end
end

return FightResultHit