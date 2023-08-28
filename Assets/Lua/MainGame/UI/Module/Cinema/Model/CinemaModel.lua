local EventDefine = require("Engine/UI/Event/EventDefine")
local CinemaModel = class("CinemaModel")

--子类重新写
function CinemaModel:Init()
	self.m_CurrentCID = nil
	self.m_CurrentStepID = nil
	self.m_CurrentCinemaConfig = nil
	self.m_AllCinemaConfig = nil
end

function CinemaModel:InitCinemaData(cid, stepID)
	self.m_AllCinemaConfig = CinemaConfigs
	self:SetCurrentCID(cid)
	self:SetCurrentStepID(stepID)
end
--------------------------------------------------------编辑器用------------------------------------------
function CinemaModel:InitCinemaDataByConfigs(startConfig, configs)
	self.m_AllCinemaConfig = configs
	self:SetCurrentCIDByConfig(startConfig)
	self:SetCurrentStepIDByConfig(startConfig)
end

function CinemaModel:SetCurrentCIDByConfig(config)
	self.m_CurrentCID = config.CID
	self.m_CurrentStepID = 1
	self.m_CurrentCinemaConfig = config
	Dispatcher.Dispatch(EventDefine.k_CIDChange, self.m_CurrentCinemaConfig)	
end

function CinemaModel:SetCurrentStepIDByConfig(config)
	self.m_CurrentStepID = config.StepID
	self.m_CurrentCinemaConfig = config
	Dispatcher.Dispatch(EventDefine.k_StepIDChange, self.m_CurrentCinemaConfig)
end
-----------------------------------------------------------------------------------------------------------
function CinemaModel:UnInitCinemaData()
	self.m_CurrentCID = nil
	self.m_CurrentStepID = nil
	self.m_CurrentCinemaConfig = nil
end

function CinemaModel:SetCurrentCID(cid)
	self.m_CurrentCID = cid
	self.m_CurrentStepID = 1
	self.m_CurrentCinemaConfig = self:GetCinemaConfig(self.m_CurrentCID, self.m_CurrentStepID)
	Dispatcher.Dispatch(EventDefine.k_CIDChange, self.m_CurrentCinemaConfig)
end

function CinemaModel:SetCurrentStepID(stepID)
	self.m_CurrentStepID = stepID
	self.m_CurrentCinemaConfig = self:GetCinemaConfig(self.m_CurrentCID, self.m_CurrentStepID)
	Dispatcher.Dispatch(EventDefine.k_StepIDChange, self.m_CurrentCinemaConfig)
end

function CinemaModel:GetCurrentID(cid, stepID)
	return cid * 1000 + stepID
end

function CinemaModel:GetCurrentCID()
	return self.m_CurrentCID
end

function CinemaModel:GetCurrentStepID()
	return self.m_CurrentStepID
end

function CinemaModel:GetCurrentCinemaConfig()
	return self.m_CurrentCinemaConfig
end

function CinemaModel:GetCinemaConfig(cid, stepID)
	local id = self:GetCurrentID(cid, stepID)
	return self.m_AllCinemaConfig[id]
end

function CinemaModel:GetNextStepID(cinemaConfig)
    if cinemaConfig == nil then
       return -1
    end

    -- if cinemaConfig.IsEnd > 0 then
    --    return -1
    -- end

    if cinemaConfig.StepJump > 0 then
    	return cinemaConfig.StepJump
	end
    
    return -1	
end

return CinemaModel