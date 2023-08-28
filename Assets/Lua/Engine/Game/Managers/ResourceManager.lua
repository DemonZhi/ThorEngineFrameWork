local Core_SGResourceManager = SGEngine.ResourceManagement.SGResourceManager
local Core_DynamicInstancingManager = SGEngine.Rendering.DynamicInstancingManager
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local InstancingModelInfoConfig = require("MainGame/Configs/Model/InstancingModelInfo")
local Vector3Zero = Vector3.zero
local TypeofGameObject = typeof(UnityEngine.GameObject)
local TypeofSprite = typeof(UnityEngine.Sprite)
local TypeofTexture = typeof(UnityEngine.Texture)
local TypeofRawImage = typeof(UnityEngine.UI.RawImage)
local TypeofAudioClip = typeof(UnityEngine.AudioClip)
local TypeofScriptableObject = typeof(UnityEngine.ScriptableObject)
local tbRemove = table.remove
local tbInsert = table.insert

local k_DefaultLODDistance = {50, 100}
local k_DefaultLODFadeTime = 0.3
local k_ReleaseInstancingPrefabDelayTime = 10

ResourceManager = ResourceManager or 
{
    m_Key2IDMap = {},
    m_Key2InstanceTypeMap = {},
    m_CachedCreateInstancingObjectCallback = {},
    m_InstanceType2KeyAndGameObjectMap = {},
    m_CallbackInfoPool = {},
}
local m_Key2IDMap = ResourceManager.m_Key2IDMap
local m_Key2InstanceTypeMap = ResourceManager.m_Key2InstanceTypeMap
local m_CachedCreateInstancingObjectCallback = ResourceManager.m_CachedCreateInstancingObjectCallback
local m_InstanceType2KeyAndGameObjectMap = ResourceManager.m_InstanceType2KeyAndGameObjectMap
local m_CallbackInfoPool = ResourceManager.m_CallbackInfoPool

local function RequestCallbackInfoObject(callback, objectID)
    local callbackInfoObject = tbRemove(m_CallbackInfoPool)
    if callbackInfoObject == nil then
        callbackInfoObject = {}
    end
    callbackInfoObject[1] = callback
    if objectID then
        callbackInfoObject[2] = objectID
    end
    return callbackInfoObject
end

local function ReleaseCallbackInfoObject(callbackInfoObject)
    callbackInfoObject[1] = nil
    tbInsert(m_CallbackInfoPool, callbackInfoObject)
end


local function OnAllInstanceObjectDestroyCallback(instanceType)
    Core_DynamicInstancingManager.ReleaseInstanceRenderGroup(instanceType)
    local keyAndGameObject = m_InstanceType2KeyAndGameObjectMap[instanceType]
    m_InstanceType2KeyAndGameObjectMap[instanceType] = nil
    
    local key = keyAndGameObject[1]
    local gameObject = keyAndGameObject[2]
    m_Key2InstanceTypeMap[key] = nil
    
    Core_SGResourceManager.ReleasePrefab(gameObject, k_ReleaseInstancingPrefabDelayTime)
end

Core_DynamicInstancingManager.RegisterOnAllInstanceObjectDestroyCallback(OnAllInstanceObjectDestroyCallback)

local function GetResourceIDByKey(key, type)
    local key2IDMap = m_Key2IDMap
    local id = key2IDMap[key]
    if id == nil then
        id = Core_SGResourceManager.ResourceKeyToID(key, type)
        if id >= 0 then
            key2IDMap[key] = id
        end
    end
    return id
end

local function OnLoadInstancingModelCallback(prefab, key)
    if prefab == nil then
        Logger.LogErrorFormat("[ResourceManager](OnLoadInstancingModelCallback)LoadPrefab Failed:[{0}]", key)
        return
    end
    local instancingModelInfo = InstancingModelInfoConfig[key]
    if not instancingModelInfo then
        Logger.LogErrorFormat("[ResourceManager](OnLoadInstancingModelCallback)InstancingModelInfoConfig not found:[{0}]", key)
        ResourceManager.ReleasePrefab(prefab)
        return
    end
    local radius = instancingModelInfo.Radius
    if not radius then
        Logger.LogErrorFormat("[ResourceManager](OnLoadInstancingModelCallback)use default radius :[{0}]", key)
        radius = 1
    end
    local centerOffset = instancingModelInfo.CenterOffset
    if centerOffset then
        centerOffset = Vector3.New(centerOffset[1], centerOffset[2], centerOffset[3])
    else
        Logger.LogErrorFormat("[ResourceManager](OnLoadInstancingModelCallback)use default offset :[{0}]", key)
        centerOffset = Vector3.zero
    end
    local lodDistance = instancingModelInfo.LODDistance
    if not lodDistance then
        Logger.LogErrorFormat("[ResourceManager](OnLoadInstancingModelCallback)use default distance :[{0}]", key)
        lodDistance = k_DefaultLODDistance
    end
    
    local instanceType = Core_DynamicInstancingManager.AddInstanceRenderGroup(prefab, radius, centerOffset, lodDistance, k_DefaultLODFadeTime)
    m_Key2InstanceTypeMap[key] = instanceType
    m_InstanceType2KeyAndGameObjectMap[instanceType] = {key, prefab}
    
    local cachedCallbackList = m_CachedCreateInstancingObjectCallback[key]
    m_CachedCreateInstancingObjectCallback[key] = nil
    for i = 1, #cachedCallbackList do
        local callbackInfoObject = cachedCallbackList[i]
        local instanceID = Core_DynamicInstancingManager.CreateInstance(instanceType)
        callbackInfoObject[1](instanceID, callbackInfoObject[2])
        ReleaseCallbackInfoObject(callbackInfoObject)
    end
end

function ResourceManager.RegisterStaticInstantiateCallback(key, callback)
    return Core_SGResourceManager.RegisterStaticInstantiateCallback(key, callback)
end

function ResourceManager.InstantiateAsyncByStaticCallback(id, poolingStrategyType, customParam)
    if not poolingStrategyType then
        poolingStrategyType = PoolingStrategyTypeEnum.NoPooling
    end

    return Core_SGResourceManager.InstantiateAsyncByStaticCallback(id, poolingStrategyType, customParam)
end

function ResourceManager.InstantiateAsync(key, callback, poolingStrategyType, customParam)
    if not poolingStrategyType then
        poolingStrategyType = PoolingStrategyTypeEnum.NoPooling
    end

    local resourceID = GetResourceIDByKey(key, TypeofGameObject)
    if resourceID < 0 then
        return nil
    end

    return Core_SGResourceManager.InstantiateByIDAsync(resourceID, callback, poolingStrategyType, customParam)
end

--同步实例化接口
function ResourceManager.Instantiate(key, poolingStrategyType)
    if not poolingStrategyType then
        poolingStrategyType = PoolingStrategyTypeEnum.NoPooling
    end

    local resourceID = GetResourceIDByKey(key, TypeofGameObject)
    if resourceID < 0 then
        return nil
    end
    
    return Core_SGResourceManager.InstantiateByID(resourceID, poolingStrategyType)
end

function ResourceManager.ReleaseInstance(resourceObjectOrGameObject)
    Core_SGResourceManager.ReleaseInstance(resourceObjectOrGameObject)
end

function ResourceManager.CreateInstancePoolCache(key, poolingStrategyType, count, callback, customParam)
    local resourceID = GetResourceIDByKey(key, TypeofGameObject)
    if resourceID < 0 then
        return nil
    end

    if not poolingStrategyType then
        poolingStrategyType = PoolingStrategyTypeEnum.NoPooling
    end

    if not count then
        count = 1
    end

    return Core_SGResourceManager.CreateInstancePoolCacheByID(resourceID, poolingStrategyType, count, callback, customParam)
end

function ResourceManager.CreateInstancingObject(key, callback, objectID)
    local instanceType = m_Key2InstanceTypeMap[key]
    if instanceType ~= nil then
        local instanceID = Core_DynamicInstancingManager.CreateInstance(instanceType)
        if callback then
            callback(instanceID, objectID)
        end
    else
        --print("-----------------------------------------------------", key)
        local cachedCallbackList = m_CachedCreateInstancingObjectCallback[key]
        local callbackInfoObject = RequestCallbackInfoObject(callback, objectID)
        if cachedCallbackList == nil then
            cachedCallbackList = {}
            m_CachedCreateInstancingObjectCallback[key] = cachedCallbackList;
            tbInsert(cachedCallbackList, callbackInfoObject)
            ResourceManager.LoadPrefabAsync(key, OnLoadInstancingModelCallback, key)
        else
            tbInsert(cachedCallbackList, callbackInfoObject)
        end
    end
end

function ResourceManager.DestroyInstanceObject(instanceID)
    Core_DynamicInstancingManager.DestroyInstance(instanceID)
end

function ResourceManager.SetInstancePosition(instanceID, position)
    Core_DynamicInstancingManager.SetPosition(instanceID, position)
end

function ResourceManager.SetInstanceRotation(instanceID, position)
    Core_DynamicInstancingManager.SetRotation(instanceID, position)
end

function ResourceManager.SetInstanceScale(instanceID, scale)
    Core_DynamicInstancingManager.SetScale(instanceID, scale)
end
--------------------------------- Prefab Start -----------------------------------
---预载资源使用此接口
function ResourceManager.LoadPrefabAsync(key, callback, customParam)
    local resourceID = GetResourceIDByKey(key, TypeofGameObject)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadPrefabByIDAsync(resourceID, callback, customParam)
end

function ResourceManager.LoadPrefab(key)
    local resourceID = GetResourceIDByKey(key, TypeofGameObject)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadPrefabByID(resourceID)
end

function ResourceManager.ReleasePrefab(go)
    Core_SGResourceManager.ReleasePrefab(go)
end
--------------------------------- Prefab End -----------------------------------

--------------------------------- Sprite Start -----------------------------------
function ResourceManager.LoadSpriteAsync(key, callback, params)
    local resourceID = GetResourceIDByKey(key, TypeofSprite)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadSpriteByIDAsync(resourceID, callback, params)
end

function ResourceManager.LoadSprite(key)
    local resourceID = GetResourceIDByKey(key, TypeofSprite)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadSpriteByID(resourceID)
end

function ResourceManager.ReleaseSprite(sprite)
    Core_SGResourceManager.ReleaseSprite(sprite)
end
--------------------------------- Sprite End -----------------------------------

--------------------------------- RawImage Start -----------------------------------
function ResourceManager.LoadRawImageAsync(key, callback)
    local resourceID = GetResourceIDByKey(key, TypeofRawImage)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadRawImageByIDAsync(resourceID, callback)
end

function ResourceManager.LoadRawImage(key)
    local resourceID = GetResourceIDByKey(key, TypeofRawImage)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadRawImageByID(resourceID)
end

function ResourceManager.ReleaseRawImage(sprite)
    Core_SGResourceManager.ReleaseRawImage(sprite)
end
--------------------------------- RawImage End -----------------------------------

--------------------------------- TextAsset Start -----------------------------------
function ResourceManager.LoadTextAssetsToBytesAsync(key, callback)
    return Core_SGResourceManager.LoadTextAssetsToBytesAsync(key, callback)
end

function ResourceManager.ReleaseTextsAsset(key)
    Core_SGResourceManager.ReleaseTextsAsset(key)
end
--------------------------------- TextAsset End -----------------------------------

--------------------------------- ScriptableObject Start -----------------------------------
function ResourceManager.LoadScriptableObjectAsync(key, callback)
    local resourceID = GetResourceIDByKey(key, TypeofScriptableObject)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadScriptableObjectByIDAsync(resourceID, callback)
end

function ResourceManager.LoadScriptableObject(key)
    local resourceID = GetResourceIDByKey(key, TypeofScriptableObject)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadScriptableObjectByID(resourceID)
end

function ResourceManager.ReleaseScriptableObject(assetResourceObject)
    Core_SGResourceManager.ReleaseScriptableObject(assetResourceObject)
end
--------------------------------- ScriptableObject End -----------------------------------

--------------------------------- Texture Start -----------------------------------
function ResourceManager.LoadTextureAsync(key, callback, params)
    local resourceID = GetResourceIDByKey(key, TypeofTexture)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadTextureByIDAsync(resourceID, callback, params)
end

function ResourceManager.LoadTexture(key)
    local resourceID = GetResourceIDByKey(key, TypeofTexture)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadTextureByID(resourceID)
end

function ResourceManager.ReleaseTexture(assetResourceObject)
    Core_SGResourceManager.ReleaseTexture(assetResourceObject)
end
--------------------------------- Texture End -----------------------------------

--------------------------------- AudioClip Start -----------------------------------
function ResourceManager.LoadAudioClipAsync(key, callback)
    local resourceID = GetResourceIDByKey(key, TypeofAudioClip)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadAudioClipByIDAsync(resourceID, callback)
end

function ResourceManager.LoadAudioClip(key)
    local resourceID = GetResourceIDByKey(key, TypeofAudioClip)
    if resourceID < 0 then
        return nil
    end
    return Core_SGResourceManager.LoadAudioClipByID(resourceID)
end

function ResourceManager.ReleaseAudioClip(assetResourceObject)
    Core_SGResourceManager.ReleaseAudioClip(assetResourceObject)
end
--------------------------------- AudioClip End -----------------------------------

return ResourceManager