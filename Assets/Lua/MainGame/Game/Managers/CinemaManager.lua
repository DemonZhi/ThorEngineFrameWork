CinemaManager = CinemaManager or {}
local AvatarMessage = require('MainGame/Message/AvatarMessage')
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local BindType = SGEngine.Core.BindType
local CinemachineBrain = Cinemachine.CinemachineBrain
---------------------------------------------------------生命周期------------------------------------------------------------------------
--子类重新写
function CinemaManager.Init()

    ClientNetManager.Register(Message.ST_PLAY_CINEMA_START, CinemaManager.OnReqPlayCinemaCallBack)
    ClientNetManager.Register(Message.ST_PLAY_CINEMA_STOP, CinemaManager.OnReqStopCinemaCallBack)

    CinemaManager.m_CurrentCinemaServerID = nil
    CinemaManager.m_CurrentCinemaConfigID = nil
end

function CinemaManager.Destroy()
    ClientNetManager.UnRegister(Message.ST_PLAY_CINEMA_START, CinemaManager.OnReqPlayCinemaCallBack)
    ClientNetManager.UnRegister(Message.ST_PLAY_CINEMA_STOP, CinemaManager.OnReqStopCinemaCallBack)

    CinemaManager.m_CurrentCinemaServerID = nil
    CinemaManager.m_CurrentCinemaConfigID = nil

end

function CinemaManager.BeforeChangeScene(prevSceneType, nextSceneType)

end

function CinemaManager.AfterChangeScene(prevSceneType, nextSceneType)

end

function CinemaManager.Restart()
    CinemaManager.SendRequestStopCinema()

    CinemaManager.m_CurrentCinemaServerID = nil
    CinemaManager.m_CurrentCinemaConfigID = nil
end
---------------------------------------------------网络-----------------------------------------------------------------------------------
function CinemaManager.SendRequestPlayCinema(cinemaConfigID)
    local buffer = ClientNetManager.GetSendBuffer(Message.PT_REQ_PLAY_CINEMA)
    buffer:WriteInt(cinemaConfigID)
    ClientNetManager.Send(buffer)
end

function CinemaManager.SendRequestStopCinema()
    local cinemaServerID = CinemaManager.m_CurrentCinemaServerID
    if cinemaServerID == nil then
       return
    end

    local buffer = ClientNetManager.GetSendBuffer(Message.PT_REQ_STOP_CINEMA)
    buffer:WriteInt(cinemaServerID)
    ClientNetManager.Send(buffer)
end

function CinemaManager.OnReqPlayCinemaCallBack(buffer)
    local cinemaServerID = buffer:ReadInt()
    local cinemaConfigID = buffer:ReadInt()
    if cinemaServerID == -1 then
       return
    end
    CinemaManager.m_CurrentCinemaServerID = cinemaServerID
    CinemaManager.m_CurrentCinemaConfigID = cinemaConfigID
    Logger.Print("[CinemaManager](OnReqPlayCinemaStartCallBack) play cinema!")
    CinemaController.CinemaStart(cinemaConfigID, 1)

end

function CinemaManager.OnReqStopCinemaCallBack(buffer)
    local cinemaServerID = buffer:ReadInt()
    local cinemaConfigID = buffer:ReadInt()
    if cinemaServerID ~= CinemaManager.m_CurrentCinemaServerID then
        return
    end
    Logger.Print("[CinemaManager](OnReqPlayCinemaStopCallBack) stop cinema!")
    CinemaController.CinemaEnd()
end

function CinemaManager.GetCurrentCinemaServerID()
    return CinemaManager.m_CurrentCinemaServerID
end

function CinemaManager.GetCurrentCinemaConfigID()
    return CinemaManager.m_CurrentCinemaConfigID
end

return CinemaManager
