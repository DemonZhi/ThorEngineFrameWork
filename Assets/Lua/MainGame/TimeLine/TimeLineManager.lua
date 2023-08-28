TimeLineManager = TimeLineManager or {}
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local DirectorObject = require("MainGame/TimeLine/DirectorObject")

function TimeLineManager.Init()
   TimeLineManager.m_CurrentDirector = nil
end

function TimeLineManager.Update()
    if TimeLineManager.m_CurrentDirector == nil then
        return
    end
    if TimeLineManager.m_CurrentDirector:IsFinished() then
        TimeLineManager.DestoryDirector()    
    end
end

function TimeLineManager.BeforeChangeScene(prevSceneType, nextSceneType)
    TimeLineManager.DestoryDirector()
end

function TimeLineManager.AfterChangeScene(prevSceneType, nextSceneType)

end

function TimeLineManager.Destroy()
    TimeLineManager.DestoryDirector()
end

function TimeLineManager.CreatDirector(position, rotation)
    local director = DirectorObject.New()
    director:Init(position, rotation)
    return director
end

function TimeLineManager.StartByDirector(director, timeLine)
    TimeLineManager.DestoryDirector()
    TimeLineManager.m_CurrentDirector = director
    if TimeLineManager.m_CurrentDirector then
       TimeLineManager.m_CurrentDirector:Start(timeLine)
    end
    return director
end

function TimeLineManager.DestoryDirector()
    if TimeLineManager.m_CurrentDirector == nil then
        return
    end
    TimeLineManager.m_CurrentDirector:Stop()
    TimeLineManager.m_CurrentDirector:Destroy()
    TimeLineManager.m_CurrentDirector = nil
end

function TimeLineManager.Start(timeLinePath, timeLineOriginPosition, onBindCallBack, onMarkCallBack, 
                                       onPlayCallBack, onPauseCallBack, onStopCallBack, onDestroyCallBack)
    ResourceManager.InstantiateAsync(timeLinePath, function(timeLineGo)
        local director = TimeLineManager.CreatDirector(timeLineOriginPosition) 
        director.onBindCallBack = onBindCallBack
        director.onMarkCallBack = onMarkCallBack
        director.onPlayCallBack = onPlayCallBack
        director.onPauseCallBack = onPauseCallBack
        director.onStopCallBack = onStopCallBack
        director.onDestroyCallBack = onDestroyCallBack
        TimeLineManager.StartByDirector(director, timeLineGo)
    end, PoolingStrategyTypeEnum.Default)
end

function TimeLineManager.IsFinished()
    if TimeLineManager.m_CurrentDirector == nil then
        return true
    end 
    return TimeLineManager.m_CurrentDirector:IsFinished()
end

function TimeLineManager.GetTime()
    if TimeLineManager.m_CurrentDirector == nil then
        return -1
    end
    return TimeLineManager.m_CurrentDirector:GetTime()
end

function TimeLineManager.GetDuration()
    if TimeLineManager.m_CurrentDirector == nil then
        return -1
    end
    return TimeLineManager.m_CurrentDirector:GetDuration()    
end

function TimeLineManager.Play()
    if TimeLineManager.m_CurrentDirector == nil then
        return
    end
    return TimeLineManager.m_CurrentDirector:Play()       
end

function TimeLineManager.Pause()
    if TimeLineManager.m_CurrentDirector == nil then
        return
    end
    return TimeLineManager.m_CurrentDirector:Pause()       
end

function TimeLineManager.Stop()
    if TimeLineManager.m_CurrentDirector == nil then
        return
    end
    return TimeLineManager.m_CurrentDirector:Stop()       
end

return TimeLineManager
