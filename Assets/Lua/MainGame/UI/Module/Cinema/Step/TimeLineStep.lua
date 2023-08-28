local BaseStep = require("MainGame/UI/Module/Cinema/Step/BaseStep")
local AvatarMessage = require('MainGame/Message/AvatarMessage')
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local BindType = SGEngine.Core.BindType
local CinemachineBrain = Cinemachine.CinemachineBrain
local TimeLineStep = class("TimeLineStep", BaseStep)

function TimeLineStep:OnInit()
    self.m_NpcLoadedCount = 0

    self.m_OnBindCallBack = function (bindType, trackParams)
    	return self:OnBindCallBack(bindType, trackParams)
    end

    self.m_OnMarkCallBack = function (value)
    	self:OnMarkCallBack(value)
    end

    self.m_OnPlayCallBack = function (timeLineGo)
    	self:OnPlayCallBack(timeLineGo)
    end

    self.m_OnDestroyCallBack = function ()
    	self:OnDestroyCallBack()
    end
end

function TimeLineStep:OnShow(cinemaConfig)
	self.skipBtn.onClick:RemoveAllListeners()
	self.skipBtn.onClick:AddListener(function ()
		self:OnCinemaStopCallBack()
    	self:Finish()   
    end)
 	self.m_IsAutoDestoryNpc = cinemaConfig.AutoDestoryNPC
 	self.m_CID = cinemaConfig.CID
    self.m_NpcList = cinemaConfig.NpcList

    self:OnCinemaStartCallBack()
end

function TimeLineStep:OnHide()
   
end

function TimeLineStep:OnDestroy()
    self.m_NpcLoadedCount = 0
    self:DestoryCinemaNPC()
end


function TimeLineStep:OnCinemaStartCallBack()
    local cinemaConfig = self.m_CinemaConfig
    local timeLinePath = cinemaConfig.TimeLinePath

    local timeLineOriginPosition = nil
    if cinemaConfig.CustomTimeLinePosition > 0 then
       timeLineOriginPosition = self:OnCustionTimeLineOriginPosition()
    else
       local timeLinePosition = cinemaConfig.TimeLinePosition
       timeLineOriginPosition = Vector3.New(timeLinePosition[1], timeLinePosition[2], timeLinePosition[3])
    end

    self:CreatAllCinemaNPC(function ()
        TimeLineManager.Start(timeLinePath, timeLineOriginPosition, self.m_OnBindCallBack, self.m_OnMarkCallBack, 
                                    self.m_OnPlayCallBack, nil, nil, self.m_OnDestroyCallBack)       
    end)
end

function TimeLineStep:OnCinemaStopCallBack()
    TimeLineManager.Stop()
end

function TimeLineStep:CreatAllCinemaNPC(callback)
    local npcList = self.m_NpcList
    if npcList == nil or next(npcList) == nil then
       callback()
       return
    end
    local npcCount = #npcList
    for k, npcID in pairs(npcList) do
        ObjectManager.CreateClientNpc(npcID, Vector3.zero, 0, 1, function (object)
            self:OnLoadNpcCompleted(object, callback)
        end)        
    end
end

function TimeLineStep:DestoryCinemaNPC()
    local npcList = self.m_NpcList
    if npcList == nil or next(npcList) == nil then
      return
    end
    for k, v in pairs(npcList) do
       local npc = ObjectManager.GetClientNpc(v)
       local objectID = npc:GetObjectID()
       ObjectManager.RemoveObjectImmediately(objectID)
    end 
    self.m_NpcList = {}
end

function TimeLineStep:OnLoadNpcCompleted(object, callback)
    local model = object:GetModel()
    model:SetActive(false)

    local cinemaConfig = self.m_CinemaConfig
    local customNpcPositionRotation = cinemaConfig.CustomNpcPositionRotation
    if customNpcPositionRotation > 0 then
        self:OnCustomNPCOriginPositionRotation(model)
    end

    local npcCount = #self.m_NpcList
    self.m_NpcLoadedCount = self.m_NpcLoadedCount + 1
    if self.m_NpcLoadedCount == npcCount then
       self.m_NpcLoadedCount = 0
       callback()
    end
end

function TimeLineStep:OnBindCallBack(bindType, trackParams)
    if bindType == BindType.Npc then
        local npcID = tonumber(trackParams)
        local npc = ObjectManager.GetClientNpc(npcID)
        if npc ~= nil then
           return npc:GetModel()
        end
        return nil
    elseif bindType == BindType.Hero then
        local hero = ObjectManager.GetHero()
        if hero ~= nil then
           return hero:GetModel()
        end
        return nil
    elseif bindType == BindType.MainCamera then
        return Camera.main.transform:GetComponent(typeof(CinemachineBrain))
    end
    return nil
end

function TimeLineStep:OnMarkCallBack(value)
    self:OnCustomMark(value)
end

function TimeLineStep:OnPlayCallBack(timeLineGo)
   local npcList = self.m_NpcList
   if npcList == nil then
      return
   end
   for k,v in pairs(npcList) do
       local npc = ObjectManager.GetClientNpc(v)
       if npc ~= nil then
          local model = npc:GetModel()
          model:SetActive(true)
       end
   end
end

function TimeLineStep:OnDestroyCallBack()
    if self.m_IsAutoDestoryNpc <= 0 then
       return
    end
    self:DestoryCinemaNPC()
end
------------------------------------自定义-----------------------------------------------------------------------------
function TimeLineStep:OnCustionTimeLineOriginPosition()
    return self:GetCustomPosition()
end

function TimeLineStep:OnCustomNPCOriginPositionRotation(go)
   local hero = ObjectManager.GetHero()
   if hero == nil then return end
   local model = hero:GetModel()
   go.transform.position = self:GetCustomPosition()
   go.transform:LookAt(model.transform, Vector3.up)
end

function TimeLineStep:GetCustomPosition()
    local hero = ObjectManager.GetHero()
    if hero == nil then return end
    local model = hero:GetModel()
    local x,y,z = hero:GetPositionXYZ()
    local targetPosition = Vector3.New(x, y + 1, z) + model.transform.forward * 5
    return targetPosition
end

function TimeLineStep:OnCustomMark(value)
   local hero = ObjectManager.GetHero()
   if hero == nil then
      return
   end
   hero:PlayAnimation(value)
end


return TimeLineStep
