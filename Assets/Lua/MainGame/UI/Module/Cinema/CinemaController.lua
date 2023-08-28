CinemaController = CinemaController or {}
local AvatarMessage = require('MainGame/Message/AvatarMessage')
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local CinemaDefine = require("MainGame/UI/Module/Cinema/Define/CinemaDefine")
local EventDefine = require("Engine/UI/Event/EventDefine")
local k_CinemaView = "CinemaView"

function CinemaController.Init()
    CinemaController.m_StepHandleMap = 
    {
        [CinemaDefine.StepType.NormalTalk] = CinemaController.NormalTalkStepHandle,
        [CinemaDefine.StepType.TimeLine]   = CinemaController.TimeLineStepHandle,
        [CinemaDefine.StepType.SelectTalk] = CinemaController.SelectTalkHandle,
    }
end

function CinemaController.OpenView()
    UIManager.OpenUI(k_CinemaView)
end

function CinemaController.CloseView()
    UIManager.CloseUI(k_CinemaView)
end

function CinemaController.NextStep(stepType, params)
    local handle = CinemaController.m_StepHandleMap[stepType]
    if handle ~= nil then
       handle(params)
    end
end
----------------------------------------Handle--------------------------------------------
function CinemaController.NormalTalkStepHandle()
    CinemaController.CommonStepHandle()
end

function CinemaController.TimeLineStepHandle()
    CinemaController.CommonStepHandle()
end

function CinemaController.SelectTalkHandle(selectIndex)
    local curCinemaConfig = CinemaController.GetCurrentCinemaConfig()
    if curCinemaConfig == nil then
       return
    end
    local jumpStepID = curCinemaConfig.SelectJumpStepList[selectIndex]
    CinemaController.SetNextStepID(jumpStepID)
end

function CinemaController.CommonStepHandle()
    local cinemaConfig = CinemaController.GetCurrentCinemaConfig()
    local nextStepID = CinemaController.GetNextStepID(cinemaConfig)
    if nextStepID > 0 then
       CinemaController.SetNextStepID(nextStepID)
    else
       CinemaController.CinemaEnd()
       --CinemaManager.SendRequestStopCinema()
    end
end
------------------------------------------对外接口-------------------------------------------------
function CinemaController.CinemaStart(cid, stepID)
    CinemaController.EnterCinemaState()
    local model = CinemaController.model
    model:InitCinemaData(cid, stepID)
    CinemaController.OpenView()
end

function CinemaController.CinemaStartByConfigs(startConfig, allConfigs)
    Logger.Table(allConfigs,"cinemaConfigs:",5)
    CinemaController.EnterCinemaState()
    local model = CinemaController.model
    model:InitCinemaDataByConfigs(startConfig, allConfigs)
    CinemaController.OpenView()
end

function CinemaController.CinemaEnd()
    CinemaController.ExitCinemaState()
    local model = CinemaController.model
    model:UnInitCinemaData()
    CinemaController.CloseView()
end

function CinemaController.EnterCinemaState()
    local hero = ObjectManager.GetHero()
    if hero ~= nil then
       hero:ChangeToCinema()
    end
end

function CinemaController.ExitCinemaState()
    local hero = ObjectManager.GetHero()
    if hero ~= nil and hero.m_Core ~= nil then
       hero:ChangeToIdle()
    end
end

-----------------------------------------------接口封装--------------------------------------------
function CinemaController.GetCurrentCinemaConfig()
    return CinemaController.model:GetCurrentCinemaConfig()
end

function CinemaController.SetNextStepID(stepID)
    CinemaController.model:SetCurrentStepID(stepID)
end

function CinemaController.GetNextStepID(cinemaConfig)
    return CinemaController.model:GetNextStepID(cinemaConfig)
end

function CinemaController.RegisterCommand()

end
return CinemaController
