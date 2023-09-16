local UICanvasTypeEnum = require("MainGame/UI/Configs/UICanvasTypeEnum")

local Core_UIManager = SGEngine.UI.UIManager
local GameObject = UnityEngine.GameObject
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local UILayerTypeEnum = require("MainGame/UI/Common/Const/UILayerTypeEnum")
local RectTransformUtility = UnityEngine.RectTransformUtility
local Rect = UnityEngine.Rect

local k_AssetKeyIndex = 1
local k_ViewIndex = 2
local k_SubViewIndex = 3
local k_CallBackIndex = 4
local k_LayerDepthUnit = 1000
local k_ViewDepthUnit = 50
local k_LayerNames = {
    [UILayerTypeEnum.JoyStickLayer] = "JoyStickLayer",
    [UILayerTypeEnum.MainLayer] = "MainLayer",
    [UILayerTypeEnum.FunctionLayer] = "FunctionLayer",
    [UILayerTypeEnum.LoadingLayer] = "LoadingLayer",
    [UILayerTypeEnum.TipLayer] = "TipLayer",
}

UIManager = UIManager or 
{
    m_AllUIMap = {},-- 引用打开和关闭的UI，切场景的时候按照配置清理
    m_LoadingUIMap = {},-- 正在加载UI回调
    m_LoadingUICallbackList = {},
    m_DelayDestroyMap = {},-- 延迟销毁列表
    m_LayerRootObj = {},
    m_UILayerObjList = {},-- 记录Layer GameObject
    m_AllActiveMap = {},-- 正在打开的UI列表
    m_StencilPlanePool = {},
    m_UICamera = nil,
    m_3DCamera = nil,
}

local function SetBackViewActive(maxFullScreenCamera, maxFullScreenOrder)
    -- 放到远处/还原
    for cameraType, cameraActiveUIMap in pairs(UIManager.m_AllActiveMap) do
        for layerType, activeUIList in pairs(cameraActiveUIMap) do
            for i,baseView in ipairs(activeUIList) do
                if maxFullScreenCamera == Core_CameraType.UICamera2 and baseView:GetSortingOrder() < maxFullScreenOrder then 
                    baseView:MoveToDistance()
                elseif maxFullScreenCamera == cameraType and baseView:GetSortingOrder() < maxFullScreenOrder then
                    baseView:MoveToDistance()
                else
                    baseView:RevertToOrigin()
                end
            end
        end
    end
end

local function GetMaxFullScreenOrder(cameraType)
    local maxFullScreenOrder = -1
    local cameraActiveUIMap = UIManager.m_AllActiveMap[cameraType]
    for layerType, layerActiveUIList in pairs(cameraActiveUIMap) do
        for i,baseView in ipairs(layerActiveUIList) do
            local sortingOrder = baseView:GetSortingOrder()
            if baseView:IsFullScreen() and sortingOrder > maxFullScreenOrder then 
                maxFullScreenOrder = sortingOrder
            end
        end
    end
    return maxFullScreenOrder
end

local function ProcessBackView()
    -- 找到显示在最上面的View
    local maxFullScreenCamera = Core_CameraType.UICamera
    local maxFullScreenOrder = GetMaxFullScreenOrder(Core_CameraType.UICamera2)
    if maxFullScreenOrder == -1 then 
        maxFullScreenOrder = GetMaxFullScreenOrder(Core_CameraType.UICamera)
    else
        maxFullScreenCamera = Core_CameraType.UICamera2
    end

    SetBackViewActive(maxFullScreenCamera, maxFullScreenOrder)
end

local function SetGroupParent(gameObject, parent)
    local transform = gameObject.transform
    transform:SetParent(parent.transform)
    transform.localScale = Vector3.one
    transform.localPosition = Vector3.zero
    transform.localRotation = Quaternion.identity
end

local function OpenUIInner(assetKey, baseView, index, subIndex, callback, params)
    baseView:Open(index, subIndex, params)
    if callback then
        callback(assetKey)
    end
end

local function SetUIParent(go, cameraType, layerType)
   if UIManager.m_UILayerObjList[cameraType][layerType] == nil then
        local layerGo = GameObject.New()
        if k_LayerNames[layerType] then 
            layerGo.name = k_LayerNames[layerType]
        end
        local transform = Core_ForLuaUtility.GetOrAddComponent(layerGo, typeof("UnityEngine.RectTransform"))
        SetGroupParent(layerGo, UIManager.m_LayerRootObj[cameraType])
        transform.anchorMin = Vector2.New(0, 0)
        transform.anchorMax = Vector2.New(1, 1)
        transform.offsetMin = Vector2.New(0, 0)
        transform.offsetMax = Vector2.New(0, 0)
        transform.localScale = Vector3.one
        transform.localPosition = Vector3.zero
        transform.anchoredPosition = Vector2.zero
        UIManager.m_UILayerObjList[cameraType][layerType] = layerGo
   end 

    SetGroupParent(go, UIManager.m_UILayerObjList[cameraType][layerType])
end

-- Core_CameraType.UICamera
local function CreateLayerRoot(cameraType)
    local layerRoot = GameObject.New("Layers")
    local canvas = Core_UIManager.Instance:AddCanvas(layerRoot, cameraType)
    local canvasScaler = Core_UIManager.AddCanvasScaler(layerRoot)

    UIManager.m_LayerRootObj[cameraType] = layerRoot
    local camera = UIManager.GetCameraByType(cameraType)
    SetGroupParent(layerRoot, camera.gameObject)  
end

--初始化
function UIManager.Init()
    Dispatcher.Init()
    for i, moduleData in pairs(UIControllerConfig) do
        local controller = require(moduleData.ctrlPath)
        if moduleData.modelPath then 
            local modelClass = require(moduleData.modelPath)
            controller.model = modelClass.New()
            controller.model:Init()
        end
        controller.Init()
        controller.RegisterCommand()
        --_G[moduleData.ctrlName] = controller
    end
    UIManager.m_UICamera = UIManager.GetCameraByType(Core_CameraType.UICamera)
    UIManager.m_3DCamera = UIManager.GetCameraByType(Core_CameraType.UICamera3D)
    UIManager.m_AllActiveMap[Core_CameraType.UICamera] = {}
    UIManager.m_AllActiveMap[Core_CameraType.UICamera2] = {}
    UIManager.m_UILayerObjList[Core_CameraType.UICamera] = {}
    UIManager.m_UILayerObjList[Core_CameraType.UICamera2] = {}
    CreateLayerRoot(Core_CameraType.UICamera)
    --CreateLayerRoot(Core_CameraType.UICamera2)
end

function UIManager.CreateUI(assetKey, callback)
    local config = UIViewConfig[assetKey]
    if config == nil then
        Logger.LogErrorFormat('{0}没有配置', assetKey)
        return
    end

    if UIManager.m_AllUIMap[assetKey] ~= nil then
        local baseView = UIManager.m_AllUIMap[assetKey]
        if callback then
            callback(UIManager.m_AllUIMap[assetKey])
        end
    else
        local classPath = config.classPath
        UIManager.AddCreateUICallback(assetKey, callback)

        if UIManager.m_LoadingUIMap[assetKey] then 
            return
        end

        UIManager.m_LoadingUIMap[assetKey] = true
        ResourceManager.InstantiateAsync(
                assetKey,
                function(go)
                    local class = require(classPath)
                    local ui = class.New()
                    UIManager.m_AllUIMap[assetKey] = ui

                    SetUIParent(go, config.camera, config.layer)
                    Core_UIManager.Instance:AddCanvas(go, config.camera)
                    --Logger.Table(config)
                    ui:SetUIConfig(config)
                    ui:LoadUICallback(go)
                    
                    UIManager.ExecuteCreateUICallback(assetKey)

                    UIManager.m_LoadingUIMap[assetKey] = false
                end,
                PoolingStrategyTypeEnum.Default
        )
    end
end

--获取UI
function UIManager.GetUI(assetKey)
    return UIManager.m_AllUIMap[assetKey]
end

--判断是否可见
function UIManager.IsActive(assetKey)
    if UIManager.m_AllUIMap[assetKey] then
        return UIManager.m_AllUIMap[assetKey].m_GameObject.activeSelf
    else
        return false
    end
end

function UIManager.SetBGUIParent(go)
    Core_UIManager.Instance:SetUIParent(go, Core_CameraType.UICamera)
end

--关闭UI
function UIManager.CloseUI(assetKey, delayDestroyTime)
    if UIManager.m_AllUIMap[assetKey] == nil then 
        return
    end

    local baseView = UIManager.m_AllUIMap[assetKey]
    if UIManager.IsActive(assetKey) then
        baseView:Close()
    end

    if delayDestroyTime then 
        if delayDestroyTime <= 0 then 
            UIManager.DestroyUI(assetKey)
        else
            local destroyData = {assetKey = assetKey, delayDestroyTime = delayDestroyTime, startTime = os.time()}
            UIManager.m_DelayDestroyMap[assetKey] = destroyData
        end
    end
end

-- 清空延迟销毁表
function UIManager.CleanDalayDestroyMap()
    UIManager.m_DelayDestroyMap = {}
end

-- 缓存UI创建回调
function UIManager.AddCreateUICallback(assetKey, callback)
    if callback then 
        if UIManager.m_LoadingUICallbackList[assetKey] == nil then 
            UIManager.m_LoadingUICallbackList[assetKey] = {}
        end
        table.insert(UIManager.m_LoadingUICallbackList[assetKey], callback)
    end
end

-- 执行创建回调
function UIManager.ExecuteCreateUICallback(assetKey)
    local callbackList = UIManager.m_LoadingUICallbackList[assetKey]
    if callbackList then  
        for i,callback in ipairs(callbackList) do
            callback(UIManager.m_AllUIMap[assetKey])
        end
        UIManager.m_LoadingUICallbackList[assetKey] = nil
    end
end

--打开
function UIManager.OpenUI(assetKey, index, subIndex, callback, params)
    --子界面下标
    if UIManager.m_AllUIMap[assetKey] then
        OpenUIInner(assetKey, UIManager.m_AllUIMap[assetKey], index, subIndex, callback, params)
    else
        UIManager.CreateUI(
            assetKey,
            function(baseView)
                OpenUIInner(assetKey, baseView, index, subIndex, callback, params)
            end
        )
    end

    --打开的时候从延迟销毁列表里面删除
    UIManager.m_DelayDestroyMap[assetKey] = nil
end

-- 加载UI，但是不打开
function UIManager.LoadUI(assetKey)
    if UIManager.m_AllUIMap[assetKey] then
        return
    end
    UIManager.CreateUI(assetKey, function (baseView)
        baseView:SetActive(false)
    end)
end

-- 判断UI是否已经加载
function UIManager.IsLoadFinish()
    if UIManager.m_AllUIMap[assetKey] then 
        return true
    else
        return false
    end
end

function UIManager.OpenTabPanel()
    
end

--关闭所有UI
function UIManager.CloseAllUI()
    for k, baseView in pairs(UIManager.m_AllUIMap) do
        if k ~= "LoadingView" then 
            baseView:Close()
        end
    end
end

function UIManager.Update(deltaTime)
    -- destroyData = {assetKey = assetKey, delayDestroyTime = delayDestroyTime, startTime = os.time()}
    for assetKey, destroyData in pairs(UIManager.m_DelayDestroyMap) do
        local baseView = UIManager.m_AllUIMap[assetKey] 
        if baseView then 
            local destroyData = UIManager.m_DelayDestroyMap[assetKey]
            local spendTime = os.time() - destroyData.startTime
            if spendTime >= destroyData.delayDestroyTime then 
                UIManager.DestroyUI(assetKey)
            end
        else --已经销毁
            UIManager.m_DelayDestroyMap[assetKey] = nil
        end
    end
end

-- 检查UI相机可见性
function UIManager.CheckAllCameraVisible()
    Core_UIManager.Instance:CheckAllCameraVisible()
end

function UIManager.BeforeChangeScene(prevSceneType, nextSceneType)
    UIManager.m_IsChangeSceneTaskDone = false
    UIManager.CleanDalayDestroyMap()
    UIManager.OnScenesChange(prevSceneType, nextSceneType)
end

function UIManager.AfterChangeScene(prevSceneType, nextSceneType)

end

function UIManager.IsChangeSceneTaskDone()
    return UIManager.m_IsChangeSceneTaskDone or false
end

--场景切换调用
function UIManager.OnScenesChange(prevSceneType, nextSceneType)
    local recordDestroyView = {}
    local allUIMap = UIManager.m_AllUIMap
    --记录销毁View
    for assetKey, baseView in pairs(allUIMap) do
        if baseView:GetUIConfig() then
            local isDestroy = true
            for _, sceneType in ipairs(baseView:GetUIConfig().activeSceneType) do
                if sceneType == nextSceneType then
                    isDestroy = false
                    break
                end
            end
            if isDestroy then
                recordDestroyView[assetKey] = baseView:GetUIConfig()
                baseView:Destroy()
            end
        end
    end

    for assetKey, uiConfig in pairs(recordDestroyView) do
        allUIMap[assetKey] = nil
    end

    for k, baseView in pairs(UIManager.m_AllUIMap) do
        if k ~= "LoadingView" then 
            baseView:Close()
        end
    end

    -- 销毁 StencilPlane
    for i,stencilPlane in ipairs(UIManager.m_StencilPlanePool) do
        GameObject.Destroy(stencilPlane)
    end
    UIManager.m_StencilPlanePool = {}

    local needOpenUIs = {}
    local onOpenCallback = function(assetKey)
        needOpenUIs[assetKey] = nil
        if not next(needOpenUIs) then
            UIManager.m_IsChangeSceneTaskDone = true
        end
    end

    for assetKey, config in pairs(UIViewConfig) do
        for _, sceneType in ipairs(config.defaultShowSceneType) do
            if sceneType == nextSceneType then
                needOpenUIs[assetKey] = 1
                UIManager.OpenUI(assetKey, nil, nil, onOpenCallback)
            end
        end
    end

    -- 该场景没有默认UI
    if not next(needOpenUIs) then
        UIManager.m_IsChangeSceneTaskDone = true
    end
end

function UIManager.Destroy()
    for assetKey, baseView in pairs(UIManager.m_AllUIMap) do
        baseView:Destroy()
    end
    UIManager.m_AllUIMap = {}
    UIManager.m_LoadingUIMap = {} 
    UIManager.m_LoadingUICallbackList = {} -- 正在加载UI回调
    UIManager.m_DelayDestroyMap = {} -- 延迟销毁列表

    UIManager.m_LayerRootObj = {}
    UIManager.m_UILayerObjList = {} -- 记录Layer GameObject
    UIManager.m_AllActiveMap ={} -- 正在打开的UI列表
    UIManager.m_StencilPlanePool = {}
    UIManager.m_UICamera = nil
    UIManager.m_3DCamera = nil
end

function UIManager.DestroyUI(assetKey)
    local baseView = UIManager.m_AllUIMap[assetKey]
    if baseView then 
        if UIManager.IsActive(assetKey) then
            baseView:Close()
        end

        baseView:Destroy()
        UIManager.m_AllUIMap[assetKey] = nil
        UIManager.m_DelayDestroyMap[assetKey] = nil
    end
end

function UIManager.Set3DParent(go, scale, pos)
   Core_UIManager.Instance:Set3DParent(go, scale, pos)
end

-- 注册打开UI
function UIManager.RegisterActiveView(baseView)
    local config = baseView:GetUIConfig()
    if config == nil then 
        return
    end

    local layerType = config.layer
    local cameraType = config.camera
    if baseView:IsActive() then 
        UIManager.UnRegisterActiveView(baseView)
    end
    
    local sortingOrder = UIManager.AllocSortingOrder(cameraType, layerType)
    baseView:SetSortingOrder(sortingOrder)
    table.insert(UIManager.m_AllActiveMap[cameraType][layerType], baseView)
    ProcessBackView()
end

-- 注销打开UI
function UIManager.UnRegisterActiveView(baseView)
    local config = baseView:GetUIConfig()
    if config == nil then 
        return
    end

    local layerType = config.layer
    local cameraType = config.camera
    local activeUIList = UIManager.m_AllActiveMap[cameraType][layerType]
    if activeUIList == nil then 
        return;
    end

    local length = #activeUIList
    for i=length, 1, -1 do
        if activeUIList[i] == baseView then 
            table.remove(activeUIList, i)
            break
        end
    end

    ProcessBackView()
end

-- 分配SortingOrder
function UIManager.AllocSortingOrder(cameraType, layerType)
    local sortingOrder = layerType * k_LayerDepthUnit
    local maxSortingOrder = sortingOrder + k_LayerDepthUnit
    if UIManager.m_AllActiveMap[cameraType][layerType] == nil then 
        UIManager.m_AllActiveMap[cameraType][layerType] = {}
        return sortingOrder
    end

    local activeUIList = UIManager.m_AllActiveMap[cameraType][layerType]
    local length = #activeUIList
    if length == 0 then 
        return sortingOrder
    end

    local baseView = activeUIList[length]
    sortingOrder = baseView:GetSortingOrder() + k_ViewDepthUnit

    -- 超出最大oder，全部重新分配
    if sortingOrder >= maxSortingOrder then 
        UIManager.ReallocateSortingOrder(cameraType, layerType)
        baseView = activeUIList[length]
        sortingOrder = baseView:GetSortingOrder() + k_ViewDepthUnit
    end


    if sortingOrder >= maxSortingOrder then 
        Logger.LogErrorFormat('[UIManager][AllocSortingOrder]Layer{0}，SortingOrder超出上限', layerType)
        return sortingOrder - k_ViewDepthUnit
    end 

    return sortingOrder
end

function UIManager.ReallocateSortingOrder(cameraType, layerType)
    local activeUIList = UIManager.m_AllActiveMap[cameraType][layerType]
    local sortingOrder = layerType * k_LayerDepthUnit
    for i,baseView in ipairs(activeUIList) do
        baseView:SetSortingOrder(sortingOrder)
        sortingOrder = sortingOrder + k_ViewDepthUnit
    end
end

function UIManager.GetCameraByType(cameraType)
    return Core_UIManager.Instance:GetCameraByType(cameraType)
end

function UIManager.GetPositionIn3DCamera(position)
    local screenPos = RectTransformUtility.WorldToScreenPoint(UIManager.m_UICamera, position)
    local worldPos = UIManager.m_3DCamera:ScreenToWorldPoint(screenPos)
    return worldPos
end

function UIManager.Set3DCameraProjection(isOrthographic)
    if UIManager.m_3DCamera then 
        UIManager.m_3DCamera.orthographic = isOrthographic
    end
end

function UIManager.GetRectIn3DCamera(rectTransform)
    local corners = rectTransform:GetWorldCorners()
    local leftBottom = UIManager.GetPositionIn3DCamera(corners[0])
    local rightTop = UIManager.GetPositionIn3DCamera(corners[2])
    return Vector4.New(leftBottom.x, leftBottom.y, rightTop.x, rightTop.y)
end

local function PopStencilPlane()
    local stencilPlane = nil
    local length = #UIManager.m_StencilPlanePool
    if length == 0 then 
        stencilPlane = Core_UIManager.CreateStencilPlane()
        UIManager.Set3DParent(stencilPlane, Vector3.one, Vector3.one)
    else
        stencilPlane = UIManager.m_StencilPlanePool[length]
        table.remove(UIManager.m_StencilPlanePool, length)
    end

    return stencilPlane
end

local function PushStencilPlane(stencilPlane)
    stencilPlane:SetActive(false)
    table.insert(UIManager.m_StencilPlanePool, stencilPlane)
end

function UIManager.AddStencilPlane(rect)
    local stencilPlane = PopStencilPlane()
    stencilPlane:SetActive(true)
    local position = Vector3.New(0, 0, 10)
    local width = rect.z - rect.x
    local height = rect.w - rect.y
    position.x = rect.x
    position.y = rect.y

    local transform = stencilPlane.transform
    transform.localScale = Vector3.New(width, height, 1)
    transform.position = position
    return stencilPlane
end

function UIManager.RemoveStencilPlane(stencilPlane)
    if stencilPlane == nil then 
        return
    end
    PushStencilPlane(stencilPlane)
end

return UIManager
