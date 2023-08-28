local Core_SceneManager = SGEngine.Core.SceneManager
local Core_ObjectManager = SGEngine.Core.ObjectManager
local LoadSceneMode = UnityEngine.SceneManagement.LoadSceneMode
local Core_RenderSetting = SGEngine.Rendering.RenderSetting
SceneManager = SceneManager or {}

function SceneManager.Init()
    SceneManager.m_CallBackMap = {}
    SceneManager.m_CurrentSceneID = -1
    SceneManager.m_CurrentSceneType = -1
    SceneManager.m_ShaderWarmUpStarted = false
end

function SceneManager.Destroy()
end

function SceneManager.ChangeScene(sceneID, sceneType, loadSceneCallback, percentageCallback)
    local sceneConfig = SceneConfig[sceneID]
    if sceneConfig == nil then
        Logger.LogErrorFormat("[SceneManager](ChangeScene)sceneID: {0} not found", sceneID)
        return
    end

    SceneManager.m_CallBackMap[sceneID] = loadSceneCallback
    Core_SceneManager.Instance:ChangeScene(sceneConfig.Id, sceneConfig.SceneAddress, sceneType, SceneManager.EndChangeScene, percentageCallback)
end

function SceneManager.EndChangeScene(sceneID, isSuccess)
    local sceneConfig = SceneConfig[sceneID]
    if sceneConfig == nil then
        return
    end

    local callBack = SceneManager.m_CallBackMap[sceneID]
    if callBack ~= nil then
        callBack(sceneConfig.Id, isSuccess)
        SceneManager.m_CallBackMap[sceneID] = nil
    end

    if isSuccess then
        SceneManager.m_CurrentSceneID = sceneID
        SceneManager.m_CurrentSceneType = sceneConfig.SceneType
    end
end

-- function SceneManager.ChangeSceneAddtive(sceneName, sceneType, loadSceneCallback, percentageCallback)
--     Core_SceneManager.Instance:ChangeScene(sceneName, sceneType, LoadSceneMode.Additive, loadSceneCallback, percentageCallback)
-- end

-- function SceneManager.GetCurrentSceneName()
--     return Core_SceneManager.Instance:GetCurrentSceneName()
-- end

---这里只会返回c#切场景判断
function SceneManager.IsChangingScene()
    return Core_SceneManager.Instance.IsChangingScene
end

function SceneManager.BeforeChangeScene(prevSceneType, nextSceneType)
    SceneManager.m_ShaderWarmUpStarted = false
end

function SceneManager.AfterChangeScene(prevSceneType, nextSceneType)
    SceneManager.m_ShaderWarmUpStarted = false
    
    --full gc
    local costTime = os.clock()
    collectgarbage("collect")
    System.GC.Collect();
    costTime = os.clock() - costTime
    Logger.LogInfoFormat("[SceneManager](AfterChangeScene)gc use time: {0:N2}s", costTime)
    DeviceUtil.AutoSetPostProcessQuality()
end

function SceneManager.IsChangeSceneTaskDone()
    if not ProcedureMain.IsChangeSceneTaskDone() then
        return false
    end

    local hero = ObjectManager.GetHero()
    if hero == nil then
        return false
    end

    if not SceneManager.m_ShaderWarmUpStarted then
        hero:WarmUpShaderKeywords()
        SceneManager.m_ShaderWarmUpStarted = true
    end

    return hero:IsWarmUpShaderKeywordsCompleted()
end

function SceneManager.GetCurrentSceneID()
    return SceneManager.m_CurrentSceneID
end

function SceneManager.GetCurrentSceneType()
    local sceneConfig = SceneConfig[SceneManager.GetCurrentSceneID()]
    if sceneConfig == nil then
        return SceneTypeEnum.None
    end
    return sceneConfig.SceneType
end

return SceneManager