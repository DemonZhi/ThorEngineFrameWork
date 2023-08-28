---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/3/25 15:17
---
local SGMissileStageStay = require("Engine/Systems/ObjectSystem/SGMissile/SGMissileStageStay")
local SGMissileStageCurve = require("Engine/Systems/ObjectSystem/SGMissile/SGMissileStageCurve")
local SGMissileStageTrack = require("Engine/Systems/ObjectSystem/SGMissile/SGMissileStageTrack")
local ComponentFightResult = require("Engine/Systems/ObjectSystem/Components/ComponentFightResult")

local SGMissile = class("SGMissile", SGCtrl)
local StageType = {
    Curve = 1,
    Trace = 2,
    Stay = 3,
}

function SGMissile:Ctor()
    SGMissile.__super.Ctor(self)
end

function SGMissile:Init()
    SGMissile.__super.Init(self)
    self.m_ServerLifeTime = 0
    self.m_ServerEndIndex = 0
    self.m_StartTime = 0
end

function SGMissile:RegisterCommonComponents()
    self.m_FightResultComponent = ComponentFightResult.New()
    self:AddComponent(self.m_FightResultComponent, false)
end

---deserialize
function SGMissile:Deserialize(netBuffer)
    SGMissile.__super.Deserialize(self, netBuffer)
    self.m_StageList = {}
    local configId = netBuffer:ReadInt()
    self.m_OwnerId = netBuffer:ReadInt()
    --Logger.LogInfo("[SGMissile]Deserialize:configId:{%d},m_OwnerId:{%d}", configId, self.m_OwnerId)
    self.m_Owner = ObjectManager.GetObject(self.m_OwnerId)
    if not configId then
        return
    end

    local config = MissileConfig[configId]
    if not config then
        return
    end

    local stageList = config.Stages
    self.m_StageList = {}
    for i, v in pairs(stageList) do
        local stageConfig = MissileStageConfig[v]
        if stageConfig then
            local stage = self:CreateStage(stageConfig, #self.m_StageList)
            if stage then
                table.insert(self.m_StageList, stage)
            end
        end
    end

    self.m_Config = config
end

function SGMissile:LoadModel(callBack)
    self:OnModelLoadComplete()
end

function SGMissile:OnModelLoadComplete()
end

function SGMissile:CreateStage(stageConfig, index)
    local type = stageConfig.Type

    if type == StageType.Curve then
        return SGMissileStageCurve.New(stageConfig, index)
    elseif type == StageType.Stay then
        return SGMissileStageStay.New(stageConfig, index)
    elseif type == StageType.Trace then
        return SGMissileStageTrack.New(stageConfig, index)
    end

    return nil
end

function SGMissile:OnAlmostFinish(stageIndex, endPosition, endAngle, fixedDuration)
    --Logger.LogInfo("OnAlmostFinish:id:%s, stageIndex:{%d}, fixedDuration:%s, frame:{%d}", self:GetObjectID(), stageIndex, fixedDuration, Time.frameCount)
    local currentIndex = self.m_CurrentStage:GetIndex()
    if currentIndex ~= stageIndex then
        --Logger.Error("OnAlmostFinish not current stage. CurrentStage:{%d}, IncomingStage:{%d}  Time.frameCount:{%d}", currentIndex, stageIndex, Time.frameCount)
        return
    end

    self.m_CurrentStage.m_IsPredictEnd = true
    self.m_CurrentStage.m_PredictEndPosition = endPosition
    self.m_CurrentStage.m_PredictEndAngle = endAngle
    self.m_CurrentStage.m_Duration = fixedDuration
end

function SGMissile:ChangeStage(stageIndex, startPosition, startAngle)
    --Logger.LogInfo("ChangeStage:id:%s, stageIndex:{%d}, frame:{%d}", self:GetObjectID(), stageIndex, Time.frameCount)
    if stageIndex < 0 or stageIndex >= #self.m_StageList then
        Logger.Error("[SGMissile]ChangeStage: Try to change invalid Stage,Index:" .. stageIndex)
        return
    end
    if self.m_CurrentStage then
        self.m_CurrentStage:Exit()
    end
    local newStage = self.m_StageList[stageIndex + 1]
    if newStage then
        self:SetPosition(startPosition)
        self:SetAngle(startAngle)
        newStage:Start(self, startPosition, startAngle)
    end

    self.m_CurrentStage = newStage
end

function SGMissile:SetTargetId(targetObjId)
    self.m_TargetObjId = targetObjId
    local currentStage = self.m_CurrentStage
    if currentStage then
        currentStage:OnSetTarget()
    end
end

function SGMissile:GetTargetId()
    return self.m_TargetObjId
end

function SGMissile:Start()
    --Logger.LogInfo("[SGMissile] Start,id:%s, time:%s", self:GetObjectID(), Time.time)
    if #self.m_StageList == 0 then
        Logger.Error("[SGMissile] Start : Current StageList is empty")
        return
    end
    self.m_StartTime = Time.time
    --self:ChangeStage(0, self.m_InitPosition, self.m_InitAngle)
    self:CreateEffect()
end

function SGMissile:CreateEffect()
    local effectIdList = self.m_Config.Effects
    self.m_EffectList = {}
    for i, v in pairs(effectIdList) do
        local effectIndex = EffectManager.CreateEffect(self, v, true)
        if effectIndex > -1 then
            table.insert(self.m_EffectList, effectIndex)
        end
    end
end

function SGMissile:DestroyEffect()
    if self.m_EffectList == nil then
        return
    end
    for i, v in pairs(self.m_EffectList) do
        EffectManager.DestroyEffect(v)
    end
end

function SGMissile:Update()
    SGMissile.__super.Update(self)
    local currentStage = self.m_CurrentStage
    if not currentStage then
        return
    end
    currentStage:Update()
    if currentStage:IsPredictEnd() and currentStage:IsFinish() then
        local nextIndex = currentStage:GetIndex() + 1
        if self:IsIndexValid(nextIndex) then
            --SGEngine.Core.DebugDraw.CreateGo(currentStage.m_PredictEndPosition, UnityEngine.Color.blue, 0, "P")
            self:ChangeStage(nextIndex, currentStage.m_PredictEndPosition, currentStage.m_PredictEndAngle)
        end
    end
end

function SGMissile:Destroy()
    self.m_CurrentStage = nil
    self:DestroyEffect()
    SGMissile.__super.Destroy(self)
end

function SGMissile:IsHero()
    if not self.m_OwnerId then
        return false
    end

    local object = ObjectManager.GetHero()
    if not object then
        return false
    end

    return object:GetObjectID() == self.m_OwnerId
end

function SGMissile:GetPlaySpeed()
    if not self.m_Owner then
        return 1
    end
    return self.m_Owner:GetCurrentPlaySpeed()
end

function SGMissile:IsIndexValid(stageIndex)
    return stageIndex >= 0 and stageIndex < #self.m_StageList
end

function SGMissile:SetDeleteInfo(lifeTimeMs, endIndex)
    --Logger.LogInfo("SetDeleteInfo:id:%s,lifeTimeMs:{%d},endIndex:{%d}", self:GetObjectID(), lifeTimeMs, endIndex)
    self.m_ServerLifeTime = lifeTimeMs / 1000
    self.m_ServerEndIndex = endIndex
end

function SGMissile:IsFinishDelayRemove()
    --Reach life time
    if Time.time - self.m_StartTime > self.m_ServerLifeTime then
        --Logger.LogInfo("SGMissile:IsFinishDelayRemove1:id:%s, duration:{%d}, serverLifeTime:{%d}", self:GetObjectID(), Time.time - self.m_StartTime, self.m_ServerLifeTime)
        return true
    end

    --ServerEndStage is finish
    if self.m_CurrentStage ~= nil then
        local currentIndex = self.m_CurrentStage:GetIndex()
        if currentIndex == self.m_ServerEndIndex then
            if self.m_CurrentStage:IsFinish() then
                --Logger.LogInfo("SGMissile:IsFinishDelayRemove2:id:%s", self:GetObjectID())
                return true
            end
        end
    end

    --current is last stage
    if self.m_CurrentStage ~= nil and self.m_CurrentStage:GetIndex() + 1 == #self.m_StageList and self.m_CurrentStage:IsFinish() then
        --Logger.LogInfo("SGMissile:IsFinishDelayRemove3:id:%s", self:GetObjectID())
        return true
    end
    return false
end

return SGMissile