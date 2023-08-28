ReloadManager = ReloadManager or {}
local GetKeyUp = UnityEngine.Input.GetKeyDown
local GetKey = UnityEngine.Input.GetKey
local KeyCode = UnityEngine.KeyCode

    --重载对象系统
function ReloadManager.ReloadObjectSystem()
    for k,v in pairs(ObjectManager.m_ObjectMap) do
        local object = _G[v.__className]
        setmetatable(v, {__index = object})
        v.__class = object
    end  
end

--重载组件系统
function ReloadManager.ReloadComponentsSystem()
    for k,v in pairs(ObjectManager.m_ObjectMap) do
        for m,n in pairs(v.m_ComponentContainer.m_ComponentMap) do
            local component = _G[n.__className]
            setmetatable(n, {__index = component})
            n.__class = component
        end
    end
end

--重载状态系统
function ReloadManager.ReloadStatesSystem()
    for k,v in pairs(ObjectManager.m_ObjectMap) do
        if v.m_StateComponent ~= nil then
           for m,n in pairs(v.m_StateComponent.m_AllStates) do
               local state = _G[n.__className]
               v.m_StateComponent.m_AllStates[m] = state
           end         
        end
    end
end

--重载ui系统
function ReloadManager.ReloadUISystem()
    for k,v in pairs(UIManager.m_AllUIMap) do
        local view = require(v.m_Config.classPath)
        setmetatable(v, {__index = view})
        v.__class = view
    end
    --销毁所有ui，切换场景，打开该场景默认UI
    for assetKey, baseView in pairs(UIManager.m_AllUIMap) do
       UIManager.DestroyUI(assetKey)
    end
    UIManager.BeforeChangeScene(prevSceneType, SceneManager.m_CurrentSceneType)
end

--重载Controller & Model
function ReloadManager.ReloadControllersAndModelsSystem()
    for k,v in pairs(UIControllerConfig) do
        if v.modelPath ~= nil then
           local model = require(v.modelPath)
           local controller = require(v.ctrlPath)
           setmetatable(controller.model, {__index = model})
           controller.model.__class = model  
        end
    end  
end

--重载网络事件回调
function ReloadManager.ReloadNetSystem()
    MessageManager.Destroy()
    MessageManager.Init()
end

--重载Lua注册到C#的事件
function ReloadManager:ReloadLuaToCSharpCallBack()
    CoreCallbackManager.Destroy()
    CoreCallbackManager.Init()
end

function ReloadManager.ReloadStateEvent()
    --先清掉 
    for k,v in pairs(ObjectManager.m_ObjectMap) do
        if v.m_EventDispatcherComponent ~= nil then
           v.m_EventDispatcherComponent:Destroy()
        end
    end

    --再把当前状态事件注册上
    for k,v in pairs(ObjectManager.m_ObjectMap) do
        if v.m_StateComponent ~= nil then
            for m,n in pairs(v.m_StateComponent.m_AllStates) do
                if v:IsState(m) then
                   n:RegisterDispatchEvent(v)
                end
            end
        end
    end
end

--重载以上所有
function ReloadManager.ReloadAll()
    if not UNITY_EDITOR then
       return
    end

    for k,v in pairs(package.loaded) do
        package.loaded[k] = nil
    end

    --注册第三方库
    SGEngine.Core.LuaManager.Instance:OpenLibs()

    require("Main")

    ReloadManager.ReloadStatesSystem()

    --重载之后，把所有角色，当前状态的 RegisterEvent调用一下

    ReloadManager.ReloadStateEvent()

    ReloadManager.ReloadComponentsSystem()
    ReloadManager.ReloadObjectSystem()
    ReloadManager.ReloadControllersAndModelsSystem()
    ReloadManager.ReloadUISystem()
    ReloadManager.ReloadNetSystem()
    ReloadManager.ReloadLuaToCSharpCallBack()

    Logger.LogInfo("[ReloadManager](ReloadAll)Reload all lua files Completed!")
end

function ReloadManager.Update()
    if GetKeyUp(KeyCode.R) and GetKey(KeyCode.LeftAlt) then
        ReloadManager.ReloadAll()
    end
end

return ReloadManager
