LoadingController = LoadingController or {}
local k_LoadingView = "LoadingView"
local k_LoadSceneTips = "正在加载场景.."
local k_LoadOtherDefaultTips = "正在加载其他.."
local StateDefine = SGEngine.Core.StateDefine

--子类重新写
function LoadingController.Init()
end

function LoadingController.RegisterCommand()
end

function LoadingController.OpenView(callBack)
	UIManager.OpenUI(k_LoadingView,nil,nil,callBack)
end

function LoadingController.CloseView()
	UIManager.CloseUI(k_LoadingView)
end

function LoadingController.GetAllViewsName()
    return {k_LoadingView}
end

function LoadingController.ShowLoadingProcess(process)
	local loadingView = UIManager.GetUI(k_LoadingView)
    if loadingView then
        loadingView:ShowProcess(process)
    end
end

function LoadingController.ShowLoadingTips(tips)
	local loadingView = UIManager.GetUI(k_LoadingView)
    if loadingView then
        loadingView:ShowLoadTips(tips)
    end
end

function LoadingController.LoadScene(sceneID, sceneType, loadingUICompleteCallback, loadingCallback, sceneCompleteCallback, allCompleteCallback)
    LoadingController.InitLoaders()
    LoadingController.m_LoadCompleteCallBack = allCompleteCallback
    LoadingController.m_LoadingCallBack = loadingCallback
    LoadingController.m_LoadSceneCompleteCallBack = sceneCompleteCallback
    LoadingController.OpenView(function()
        LoadingController.ShowLoadingProcess(0)
        LoadingController.ShowLoadingTips(k_LoadSceneTips)
        -- 让loadingUI先更新一帧 否则加载资源卡主线程可能造成loadingUI的UI元素未能排列正确
        --TimerManager:AddFrameTimer(nil, function()
            if loadingUICompleteCallback ~= nil then
                loadingUICompleteCallback()
            end

            LoadingController.LoadSceneInner(sceneID, sceneType)
        --end, 1)
    end)
end

function LoadingController.InitLoaders()
    local baseLoaderList = 
    {
        ObjectManager,
        EffectManager,
        UIManager,
        SceneManager,
    }
    LoadingController.m_BaseLoaderList = baseLoaderList
    local baseLoader2DefaultTips = 
    {
        [ObjectManager] = "正在加载模型..",
        [EffectManager] = "正在加载特效..",
        [UIManager] = "正在加载UI..",
        [SceneManager] = "正在预热Shader..",
    }
    LoadingController.m_BaseLoader2DefaultTips = baseLoader2DefaultTips
    LoadingController.m_OtherLoaderList = {}
    LoadingController.m_OtherLoader2LoadTips = {}
end

-- 增加其他加载器
-- 加载器接口 IsChangeSceneTaskDone()
function LoadingController.AddOtherLoader(loader, loadTips)
    if loader == nil then
        return
    end

    table.insert(LoadingController.m_OtherLoaderList, loader)
    LoadingController.m_OtherLoader2LoadTips[loader] = (loadTips or k_LoadOtherDefaultTips)
end

function LoadingController.LoadSceneInner(sceneID, sceneType)
    LoadingController.ShowLoadingTips(k_LoadSceneTips)
    SceneManager.ChangeScene(sceneID, sceneType, function(tempSceneID,loadSuccess)
        if loadSuccess then
            local hero = ObjectManager.GetHero()
            LoadingController.CheckAllLoaderDone(tempSceneID)
            if LoadingController.m_LoadSceneCompleteCallBack~= nil then
                LoadingController.m_LoadSceneCompleteCallBack(tempSceneID)
            end
        else
            if LoadingController.m_LoadCompleteCallBack then
                LoadingController.m_LoadCompleteCallBack(false)
                LoadingController.LoadFinish(tempSceneID)
            end
        end
    end, function (tempSceneID,process)
         LoadingController.ShowLoadingProcess(process * 0.6)
         if	LoadingController.m_LoadingCallBack ~= nil then 
            LoadingController.m_LoadingCallBack(tempSceneID,process)
         end
    end)
end

-- 检测其他加载器是否完成
function LoadingController.CheckAllLoaderDone(sceneID)
    local checkTimerID = 0
    local checkBaseIndex = 0
    local checkOtherIndex = 0
    local baseLoaderCount = #LoadingController.m_BaseLoaderList
    local otherLoaderCount = #LoadingController.m_OtherLoaderList

    checkTimerID = TimerManager:AddTimer(nil, function()
        checkBaseIndex = LoadingController.GetCheckLoaderIndex(LoadingController.m_BaseLoaderList, checkBaseIndex)
        local nextLoader = LoadingController.m_BaseLoaderList[checkBaseIndex]
        if nextLoader == nil then
            checkOtherIndex = LoadingController.GetCheckLoaderIndex(LoadingController.m_OtherLoaderList, checkOtherIndex)
            nextLoader = LoadingController.m_OtherLoaderList[checkOtherIndex]
        end

        if nextLoader ~= nil then
            LoadingController.ShowLoadingTips(LoadingController.m_BaseLoader2DefaultTips[nextLoader] or LoadingController.m_OtherLoader2LoadTips[nextLoader])
            local percent = (math.min(checkBaseIndex, baseLoaderCount) + math.min(checkOtherIndex, otherLoaderCount)) / (baseLoaderCount + otherLoaderCount)
            percent = percent * 0.4 + 0.6
            LoadingController.ShowLoadingProcess(percent)
        else
            TimerManager:RemoveTimer(checkTimerID)
            if LoadingController.m_LoadCompleteCallBack then
                LoadingController.m_LoadCompleteCallBack(true)
            end
    
            LoadingController.CloseView()
            LoadingController.LoadFinish(sceneID)
        end
    end, 0.1, 0)
end

-- 获取该检测的加载器索引
function LoadingController.GetCheckLoaderIndex(loaderList, currentIndex)
    repeat
        if not loaderList then
            break
        end

        if currentIndex == 0 then
            currentIndex = 1
            break
        end

        local loader = loaderList[currentIndex]
        if loader == nil then
            break
        end

        if loader.IsChangeSceneTaskDone then
            if loader.IsChangeSceneTaskDone() then
                currentIndex = currentIndex + 1
                break
            end
        else
            currentIndex = currentIndex + 1
            break
        end
    until(true)
    return currentIndex
end

function LoadingController.LoadFinish(sceneID)
    LoadingController.m_LoadCompleteCallBack = nil
    LoadingController.m_LoadingCallBack = nil
    LoadingController.m_BaseLoaderList = nil
    LoadingController.m_BaseLoader2DefaultTips = nil
    LoadingController.m_OtherLoaderList = nil
    LoadingController.m_OtherLoader2LoadTips = nil

    local currMapCfg = SceneConfig[tonumber(sceneID)]
    if currMapCfg ~= nil and currMapCfg.DefaultMusicID ~= nil then 
--        AudioManager:PlayMusic(currMapCfg.DefaultMusicID)
    end
end

return LoadingController