local PlayableDirector = UnityEngine.Playables.PlayableDirector
local TimeLineUtility = SGEngine.Core.TimeLineUtility
local MarkReceiver = SGEngine.Core.MarkReceiver
local TimeLineBindData = SGEngine.Core.TimeLineBindData
local BindType = SGEngine.Core.BindType
local DirectorObject = class("DirectorObject")


function DirectorObject:Init(position, rotation)
    self.m_Position = position
    self.m_Rotation = rotation

    self.m_Running = false
    self.m_Finished = nil
    self.m_TimeLineGo = nil
    self.m_Transform = nil
    self.m_PlayableDirector = nil
    self.m_MarkReceiver = nil
    self.m_PlayableBindingMap = {}

    self.m_PlayCallBack = function (...)
        self:OnPlay(...)
    end

    self.m_PauseCallBack = function (...)
        self:OnPause(...)
    end

    self.m_StopCallBack = function (...)
        self:OnStoped(...)
    end

    self.m_MarkCallBack = function (value)
        self:OnMark(value)
    end

    self.onBindCallBack = nil
    self.onStartCallBack = nil
    self.onPlayCallBack = nil
    self.onPauseCallBack = nil
    self.onStopCallBack = nil
    self.onMarkCallBack = nil
    self.onDestroyCallBack = nil

end

function DirectorObject:Destroy()
    self.m_Running = false
    self:SetFinished(true)

    if self.m_PlayableDirector ~= nil then
       self.m_PlayableDirector.stopped = self.m_PlayableDirector.stopped - self.m_StopCallBack
       self.m_PlayableDirector.played = self.m_PlayableDirector.played - self.m_PlayCallBack
       self.m_PlayableDirector.paused = self.m_PlayableDirector.paused - self.m_PauseCallBack
    end

    if self.m_MarkReceiver ~= nil then
       self.m_MarkReceiver:UnRegisterMarkCallback()
    end
    self.m_Position = nil
    self.m_Rotation = nil
    self.m_Transform = nil


    self.m_MarkReceiver = nil
    self.m_PlayableDirector = nil
    self.m_PlayableBindingMap = nil

    self.onBindCallBack = nil
    self.onStartCallBack = nil
    self.onPlayCallBack = nil
    self.onStopCallBack = nil
    self.onPauseCallBack = nil
    self.onMarkCallBack = nil

    self.m_PlayCallBack = nil
    self.m_StopCallBack = nil
    self.m_PauseCallBack = nil
    self.m_MarkCallBack = nil

    self:OnDestroy()
    self.onDestroyCallBack = nil

    ResourceManager.ReleaseInstance(self.m_TimeLineGo)
    self.m_TimeLineGo = nil
end

function DirectorObject:Start(timeLine)
    local sucess = self:InitTimeLineResource(timeLine)
    if not sucess then
        self:SetFinished(true)
        return
    end
    self:SetFinished(false)
    self.m_Transform.gameObject:SetActive(true)
    self:OnStart()
    self:Play()
end

function DirectorObject:Play()
    if self.m_PlayableDirector == nil or self.m_Running then
       return
    end
    self.m_PlayableDirector:Play()
end

function DirectorObject:Pause()
    if self.m_PlayableDirector == nil or not self.m_Running then
        return
    end
    self.m_PlayableDirector:Pause()
end

function DirectorObject:Stop()
    if self.m_PlayableDirector == nil then
        return
    end
    self.m_PlayableDirector:Stop()
end

function DirectorObject:InitTimeLineResource(timeLine)
    if timeLine == nil then
        return false
    end

    self.m_TimeLineGo = timeLine
    self.m_Transform = timeLine.transform

    self.m_PlayableDirector = nil
    self.m_MarkReceiver = nil
    self.m_PlayableDirector = self.m_Transform:GetComponent(typeof(PlayableDirector))
    self.m_MarkReceiver = self.m_Transform:GetComponent(typeof(MarkReceiver))
    self.m_TimeLineBindData = self.m_Transform:GetComponent(typeof(TimeLineBindData))

    if self.m_PlayableDirector ~= nil then
       self.m_PlayableDirector.played = self.m_PlayableDirector.played + self.m_PlayCallBack   
       self.m_PlayableDirector.paused = self.m_PlayableDirector.paused + self.m_PauseCallBack
       self.m_PlayableDirector.stopped = self.m_PlayableDirector.stopped + self.m_StopCallBack
    end

    if self.m_MarkReceiver ~= nil then
       self.m_MarkReceiver:RegisterMarkCallback(self.m_MarkCallBack)
    end

    self:CacheBinding()

    if self.m_TimeLineBindData ~= nil then
        self.m_TrackBindDataList = self.m_TimeLineBindData.trackBindDataList
        self:BindTrackDatas(self.m_TrackBindDataList)

        self.m_VirtualCameraBindDataList = self.m_TimeLineBindData.virtualCameraBindDataList
        self:BindVirtualCameraDatas(self.m_VirtualCameraBindDataList)
    end

    if self.m_Position then
        self.m_Transform.position = self.m_Position
    end

    if self.m_Rotation then
        self.m_Transform.rotation = self.m_Rotation
    end

    return true
end

function DirectorObject:BindTrackDatas(trackBindDataList)
    local bindTrackCount = trackBindDataList.Count
    for i=0, bindTrackCount - 1 do
        local trackBindData = trackBindDataList[i]
        local go = self:GetGameObjectByBindType(trackBindData.bindType, trackBindData.trackParams)
        if trackBindData.isChild then
            go.transform:SetParent(self.m_Transform)
        end
        self:SetGenericBinding(trackBindData.trackPosition, go)
    end
end

function DirectorObject:BindVirtualCameraDatas(virtualCameraBindDataList)
    local bindVirtualCameraCount = virtualCameraBindDataList.Count
    for i=0, bindVirtualCameraCount - 1 do
        local virtualCameraBindData = virtualCameraBindDataList[i]
        local go = self:GetGameObjectByBindType(virtualCameraBindData.bindType, virtualCameraBindData.cameraParams)
        local trans = go.transform
        if virtualCameraBindData.isFllow then
           virtualCameraBindData.virtualCamera.Follow = trans
        end

        if virtualCameraBindData.isLookAt then
           virtualCameraBindData.virtualCamera.LookAt = trans
        end
    end   
end

function DirectorObject:GetGameObjectByBindType(bindType, params)
    if  self.onBindCallBack ~= nil then
       return self.onBindCallBack(bindType, params)
    end
    return nil
end

function DirectorObject:SetFinished(value)
    if self.m_Finished == value then
        return
    end
    self.m_Finished = value
    if self.m_Finished then
       --清除绑定的角色
       self:ClearBinding()
    end
end

--播放时间
function DirectorObject:GetTime()
    if not self.m_PlayableDirector then
        return -1
    end
    return self.m_PlayableDirector.time
end

--总时间
function DirectorObject:GetDuration()
    if not self.m_PlayableDirector then
        return -1
    end
    return self.m_PlayableDirector.duration
end

function DirectorObject:CacheBinding()
    self.m_PlayableBindingMap = {}

    if self.m_PlayableDirector == nil or self.m_PlayableDirector.playableAsset == nil then
        return false
    else
        local outPutsIter =  TimeLineUtility.GetPlayableAssetsOutPuts(self.m_PlayableDirector)
        if outPutsIter == nil then
            return false
        end
        local index = 0
        while outPutsIter:MoveNext() do
            local v = outPutsIter.Current
            self.m_PlayableBindingMap[index] = v.sourceObject
            index = index + 1
        end
        return true
    end
end

function DirectorObject:FindBindingByIndex(index)
   if self.m_PlayableBindingMap == nil then
      return nil
   end

   local playableBinding = self.m_PlayableBindingMap[index]
   return playableBinding
end

function DirectorObject:SetGenericBinding(index, go)
    if self.m_PlayableDirector == nil or go == nil then
        return false
    end

    local binding = self:FindBindingByIndex(index)

    if binding == nil then
        return false
    end

    self.m_PlayableDirector:SetGenericBinding(binding, go)
    return true
end

function DirectorObject:ClearBinding()
    if self.m_PlayableBindingMap == nil then
       return
    end
    self:ClearTrackBinding(self.m_TrackBindDataList)
    self:ClearVirtualCameraBinding(self.m_VirtualCameraBindDataList)
    self.m_TrackBindDataList = nil
    self.m_VirtualCameraBindDataList = nil
    self.m_PlayableBindingMap = nil
end

function DirectorObject:ClearTrackBinding(trackBindDataList)
    local bindTrackCount = trackBindDataList.Count
    for i=0, bindTrackCount - 1 do
        local trackBindData = trackBindDataList[i]
        local trackPosition = trackBindData.trackPosition
        local binding = self:FindBindingByIndex(trackPosition)
        self.m_PlayableDirector:ClearGenericBinding(binding)
    end
end

function DirectorObject:ClearVirtualCameraBinding(virtualCameraBindDataList)
    local bindVirtualCameraCount = virtualCameraBindDataList.Count
    for i=0, bindVirtualCameraCount - 1 do
        local virtualCameraBindData = virtualCameraBindDataList[i]
        virtualCameraBindData.virtualCamera.Follow = nil
        virtualCameraBindData.virtualCamera.LookAt = nil
    end 
end

function DirectorObject:IsFinished()
    return self.m_Finished
end

function DirectorObject:OnPlay(...)
    self:SetFinished(false)
    self.m_Running = true
    if self.onPlayCallBack ~= nil then
        self.onPlayCallBack(self.m_TimeLineGo)
    end
end

function DirectorObject:OnPause(...)
    self.m_Running = false
    if self.onPauseCallBack ~= nil then
        self.onPauseCallBack()
    end
end

function DirectorObject:OnStoped(...)
    self.m_Running = false

    if self.onStopCallBack ~= nil then
        self.onStopCallBack()
    end

    self:SetFinished(true)
end

function DirectorObject:OnMark(value)
    if self.onMarkCallBack ~= nil then
       self.onMarkCallBack(value)
    end
end

function DirectorObject:OnStart()
    if self.onStartCallBack ~= nil then
       self:onStartCallBack()
    end
end

function  DirectorObject:OnDestroy()
    if self.onDestroyCallBack ~= nil then
       self.onDestroyCallBack()
    end 
end

return DirectorObject
