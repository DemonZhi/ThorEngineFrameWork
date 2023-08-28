local NormalTalkStep = require("MainGame/UI/Module/Cinema/Step/NormalTalkStep")
local TimeLineStep = require("MainGame/UI/Module/Cinema/Step/TimeLineStep")
local SelectTalkStep = require("MainGame/UI/Module/Cinema/Step/SelectTalkStep")
local CinemaDefine = require("MainGame/UI/Module/Cinema/Define/CinemaDefine")
local EventDefine = require("Engine/UI/Event/EventDefine")
local CinemaView = class('CinemaView', BaseView)

--子类重写
function CinemaView:InitUI()
    self.m_OnCIDChange = function ( cinemaConfig )
    end

    self.m_OnStepIDChange = function ( cinemaConfig )
    	self:ExcuteStep(cinemaConfig)
    end

	self.m_CurrentStepObject = nil
	self.m_StepObjectMap = {}
end

function CinemaView:OnOpen()
	self:Clear()
	Dispatcher.AddEventListener(EventDefine.k_CIDChange, self.m_OnCIDChange)
   Dispatcher.AddEventListener(EventDefine.k_StepIDChange, self.m_OnStepIDChange)
	self:ExcuteStep(CinemaController.GetCurrentCinemaConfig())
end

function CinemaView:OnClose()
	self:Clear()
end

function CinemaView:Clear()
	self.m_CurrentStepObject = nil
	self.m_StepObjectMap = {}
	Dispatcher.RemoveEventListener(EventDefine.k_CIDChange)
   Dispatcher.RemoveEventListener(EventDefine.k_StepIDChange)
end

function CinemaView:ExcuteStep(cinemaConfig)
	self:HideAllPanel()
	if cinemaConfig == nil then
		CinemaController.CinemaEnd()
		return
	end
   self.m_CurrentStepObject = self:GetOrCreatStepObject(cinemaConfig.StepType)
   if self.m_CurrentStepObject ~= nil then
   	  self.m_CurrentStepObject:Show(cinemaConfig)
   end
end

function CinemaView:GetOrCreatStepObject(stepType)
	local instance = self.m_StepObjectMap[stepType]
	if instance == nil then
	   local cls, transformUI = self:GetStepObjectClass(stepType)
	   instance = cls.Create()
	   self.m_StepObjectMap[stepType] = instance
	   instance:Init(self, transformUI, stepType)
	end
	return instance
end

function CinemaView:GetStepObjectClass(stepType)
	if stepType == CinemaDefine.StepType.NormalTalk then
	   return NormalTalkStep, self.normalDialogue
	elseif stepType == CinemaDefine.StepType.TimeLine then
	   return TimeLineStep, self.timeLineUI
	elseif stepType == CinemaDefine.StepType.SelectTalk then
	   return SelectTalkStep, self.operationDialogue
	end
end

function CinemaView:StepFinished(stepObject, params)
	if stepObject == nil then
	   return
	end
	local stepType = stepObject.m_StepType
	local cinemaConfig = stepObject.m_CinemaConfig
	stepObject:Hide()
	self.m_CurrentStepObject = nil
	Logger.LogInfo("(CinemaView)[StepFinished]完成步骤:"..cinemaConfig.ID)
	CinemaController.NextStep(stepType, params)
end

function CinemaView:HideAllPanel()
	self.normalDialogue.gameObject:SetActive(false)
	self.operationDialogue.gameObject:SetActive(false)
	self.timeLineUI.gameObject:SetActive(false)
end

return CinemaView
