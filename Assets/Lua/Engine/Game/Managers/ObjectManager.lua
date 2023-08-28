local Core_ObjectManager = SGEngine.Core.ObjectManager
local ModelConfig = ModelConfig
local ObjectTypeEnum = ObjectTypeEnum
local MonsterConfig = MonsterConfig

local Core_SGMonster = SGEngine.Core.SGMonster
local Core_SGPlayer = SGEngine.Core.SGPlayer
local Core_SGUIObject = SGEngine.Core.SGUIObject
local Core_SGMount = SGEngine.Core.SGMount
local Core_SGMissile = SGEngine.Core.SGMissile
local Core_Ctrl = SGEngine.Core.SGCtrl
local Core_SGMagicArea = SGEngine.Core.SGMagicArea
local Core_SGTrigger = SGEngine.Core.SGTrigger
local Core_ObjectVisibleManager = SGEngine.Core.ObjectVisibleManager

local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local tinsert, tremove = table.insert, table.remove

ObjectManager = ObjectManager or {
    m_ObjectMap = {},
    m_ObjectCacheMap = {},
    m_DelayRemoveObjectMap = {},
    m_TempRemoveObjectKeyList = {},
    m_Hero = nil,
    m_ClientObjectID = -1,
    m_LineRenderGos = nil,
}

function ObjectManager.GenerateClientObjectID()
    local objID = ObjectManager.m_ClientObjectID
    ObjectManager.m_ClientObjectID = objID - 1
    return objID
end

function ObjectManager.TransferServerTypeToClient(serverType)

end

function ObjectManager.CreateObject(objectType)
    if ObjectManager.m_ObjectCacheMap == nil then
        ObjectManager.m_ObjectCacheMap = {}
    end
    --Logger.LogInfo("[ObjectManager](CreateObject), objectType: %02X", objectType)
    -- 从缓存获取
    local object = ObjectManager.GetObjectFromCache(objectType)
    if object ~= nil then
        return object
    end
    -- 重新创建
    if (objectType & ObjectTypeEnum.Player) > 0 then
        object = SGPlayer.New()
        object.m_Core = Core_SGPlayer.New()
    elseif (objectType & ObjectTypeEnum.Monster) > 0 then
        object = SGMonster.New()
        object.m_Core = Core_SGMonster.New()
    elseif (objectType & ObjectTypeEnum.MagicArea) > 0 then
        object = SGMagicArea.New()
        object.m_Core = Core_SGMagicArea.New()
    elseif (objectType & ObjectTypeEnum.OutLook) > 0 then
        object = SGUIObject.New()
        object.m_Core = Core_SGUIObject.New()
    elseif (objectType & ObjectTypeEnum.Mount) > 0 then
        object = SGMount.New()
        object.m_Core = Core_SGMount.New()
    elseif (objectType & ObjectTypeEnum.Missile) > 0 then
        object = SGMissile.New()
        object.m_Core = Core_SGMissile.New()
    elseif (objectType & ObjectTypeEnum.Trigger) > 0 then
        object = SGTrigger.New()
        object.m_Core = Core_SGTrigger.New()
    else
        Logger.LogErrorFormat("[ObjectManager](CreateObject)Create Object failed, objType not found, objType: {0}", objectType)
        return nil
    end

    return object
end

function ObjectManager.RemoveObjectImmediately(objId)
    --Logger.LogInfoFormat("[ObjectManager](RemoveObjectImmediately)RemoveObjectImmediately, id: {0}", objId)
    local removedObject = ObjectManager.m_ObjectMap[objId]

    if removedObject == nil then
        removedObject = ObjectManager.m_DelayRemoveObjectMap[objId]
        if removedObject == nil then
            return false
        else
            removedObject:Destroy()
            ObjectManager.m_DelayRemoveObjectMap[objId] = nil
        end
    else
        removedObject:Destroy()
        ObjectManager.m_ObjectMap[objId] = nil
    end

    --回收C#对象
    Core_ObjectManager.Instance:RemoveObjectImmediately(objId)

    --缓存Lua对象
    ObjectManager.AddObjectToCache(removedObject)

    return true
end

function ObjectManager.RemoveObject(objId)
    --Logger.LogInfoFormat("[ObjectManager](RemoveObject)RemoveObject, id: {0}", objId)
    local removedObject = ObjectManager.m_ObjectMap[objId]

    if not removedObject then
        return false
    end

    Core_ObjectManager.Instance:RemoveObject(objId)

    return true
end

function ObjectManager.RemoveObjectWithSelfDelay(objId)
    local removedObject = ObjectManager.m_ObjectMap[objId]

    if not removedObject then
        return false
    end
    ObjectManager.m_ObjectMap[objId] = nil
    ObjectManager.m_DelayRemoveObjectMap[objId] = removedObject
    return true
end

function ObjectManager.RemoveAllObjectsExceptHero()
    local removeList = {}

    for objId, object in pairs(ObjectManager.m_ObjectMap) do
        if object ~= ObjectManager.m_Hero and object.m_ObjectType ~= ObjectTypeEnum.OutLook then
            tinsert(removeList, objId)
        end
    end

    for _, objId in ipairs(removeList) do
        ObjectManager.RemoveObjectImmediately(objId)
    end
end

function ObjectManager.AddObjectToCache(object)
    if ObjectManager.m_ObjectCacheMap == nil then
        ObjectManager.m_ObjectCacheMap = {}
    end

    local objectCacheMap = ObjectManager.m_ObjectCacheMap

    local cacheObjList = objectCacheMap[object.m_ObjectType]

    if cacheObjList == nil then
        cacheObjList = {}
        objectCacheMap[object.m_ObjectType] = cacheObjList
    end

    tinsert(cacheObjList, object)

    ObjectManager.m_CacheObjctCount = ObjectManager.m_CacheObjctCount + 1
end

function ObjectManager.GetObjectFromCache(objectType)
    local cacheObjList = ObjectManager.m_ObjectCacheMap[objectType]

    if cacheObjList == nil then
        return nil
    end

    local cacheCount = #cacheObjList
    if cacheCount <= 0 then
        return nil
    end

    local object = tremove(cacheObjList, cacheCount)
    object.m_Core = Core_ObjectManager.Instance:GetCacheObject(objectType)
    if object.m_Core == nil or object.m_Core:Equals(nil) then
        Logger.Error("(ObjectManager)[GetObjectFromCache] Get a null cache core for objectType: {0}", tostring(objectType))
    end
    ObjectManager.m_CacheObjctCount = ObjectManager.m_CacheObjctCount - 1
    Logger.LogInfo("[ObjectManager](GetObjectFromCache), objectType: %02X", objectType)
    return object
end

function ObjectManager.CreateClientMonster(monsterId, position, angle, scale, callBack)
    local monsterCfg = MonsterConfig[monsterId]

    if not monsterCfg then
        Logger.LogErrorFormat("[[ObjectManager](CreateClientMonster)Monster config not found, objId: {0}", monsterId)
        return nil
    end
    local monster = ObjectManager.CreateClientObject(ObjectTypeEnum.Monster, monsterCfg.ModelID, position, angle, scale, false, function(object)
        if callBack then
            callBack(object)
        end
    end)
    monster.m_MonsterID = monsterId

    return monster
end

function ObjectManager.CreateClientObject(objType, modelId, position, angle, scale, isHero, callBack)
    local config = ModelConfig[modelId]

    if not config then
        Logger.LogErrorFormat("[ObjectManager](CreateClientObject)Create Object failed, model config not found, model id: {0}", modelId)
        return nil
    end

    local objId = ObjectManager.GenerateClientObjectID()

    if ObjectManager.m_ObjectMap[objId] then
        Logger.LogErrorFormat("[[ObjectManager](CreateClientObject)Repeat add object, objId: {0}, modelId: {1}", objId, modelId)
        return nil
    end

    local object = ObjectManager.CreateObject(objType)
    if not object then
        Logger.LogError("[ObjectManager](CreateClientObject) objType error: %d", objType)
        return nil
    end
   
    object:Init()
    ObjectManager.AddObject(objId, object)
    object:SetObjectID(objId)
    object:SetModelID(modelId)
    object:SetPosition(position)
    object:SetAngle(angle)
    object:SetScale(scale)

    if isHero then
        ObjectManager.SetHero(object)
    end

    local modelAddress = config.Address
    local animationType = config.AnimationType
    if objType == ObjectTypeEnum.Player and not isHero and string.IsNullOrEmpty(config.LODAddress) then
        modelAddress = config.LODAddress
    end
    ResourceManager.InstantiateAsync(modelAddress, function(go)
        if not go then
            Logger.LogErrorFormat("[ObjectManager](CreateObject)Instantiate model failed, model id: {0}", modelId)
            return
        end

        if not object:IsValid() then
            Logger.LogInfo("[ObjectManager](CreateObject) Object Invalid after instantiate, Release. path: %s", modelAddress)
            ResourceManager.ReleaseInstance(go)
            return
        end
    
        object:SetModel(go, animationType)
        object:SetModelPath(config.Address)
        if object.OnModelLoadComplete then
            object:OnModelLoadComplete()
        end
        if callBack then
            callBack(object)
        end
    end, PoolingStrategyTypeEnum.Default)

    return object
end

function ObjectManager.GetObject(objId)
    if ObjectManager.m_ObjectMap == nil then
        return nil
    end
    return ObjectManager.m_ObjectMap[objId]
end

function ObjectManager.GetObjects(func)
    if not func then
        return nil
    end

    local result = {}
    for i, object in pairs(ObjectManager.m_ObjectMap) do
        if func(object) then
            result[i] = object
        end
    end
    return result
end

function ObjectManager.GetObjectCount()
    return Core_ObjectManager.Instance:GetObjectCount()
end

function ObjectManager.HasObject(func)
    for i, object in pairs(ObjectManager.m_ObjectMap) do
        if func(object) then
            break
        end
    end
end

function ObjectManager.SetHero(hero)
    ObjectManager.m_Hero = hero
    Core_ObjectManager.Instance.Hero = hero.m_Core
end

function ObjectManager.GetHero()
    return ObjectManager.m_Hero
end

function ObjectManager.AddObject(objectId, object)
    if object == nil or objectId == nil then
        Logger.Error("[ObjectManager](AddObject)Try to add null,objectId:%s", tostring(objectId))
        return
    end

    if ObjectManager.GetObject(objectId) ~= nil then
        Logger.Error("[ObjectManager](AddObject)Repeated Add,ObjectId:%s", tostring(objectId))
        return
    end

    if object.m_Core ~= nil then
        Core_ObjectManager.Instance:AddObject(objectId, object.m_Core)
    end
    ObjectManager.m_ObjectMap[objectId] = object
end

function ObjectManager.Init()
    --Logger.LogInfo("ObjectManager.Init")
    ObjectManager.m_ObjectMap = {}
    local mt = {}
    mt.__index = function(t, k)
        return rawget(t, tostring(k))
    end
    mt.__newindex = function(t, k, v)
        rawset(t, tostring(k), v)
    end
    setmetatable(ObjectManager.m_ObjectMap, mt)
    Core_ObjectManager.Instance:SetObjRemoveFunction(ObjectManager.RemoveObjectImmediately)
    ObjectManager.m_ObjectCacheMap = {}
    ObjectManager.m_CacheObjctCount = 0

    local checkModelVisibileTime = tonumber(GameSettings["CheckModelVisibileTime"].Value)
    local checkShadowVisibileTime = tonumber(GameSettings["CheckShadowVisibileTime"].Value)
    -- Core_ObjectManager.Instance:InitVisibileConfig(ModelVisbile, ShadowVisbile, checkModelVisibileTime, checkShadowVisibileTime)

    for k,v in pairs(ModelVisbile) do
        Core_ObjectVisibleManager.Instance:AddModelVisibleConfig(v.EntityType, v.Radious, v.Count)
    end

    for k,v in pairs(ShadowVisbile) do
        Core_ObjectVisibleManager.Instance:AddShadowVisibleConfig(v.EntityType, v.Radious, v.Count)
    end

    Core_ObjectVisibleManager.Instance:SetVisibileTimeConfig(checkModelVisibileTime, checkShadowVisibileTime)

    if UNITY_EDITOR then
       if ObjectManager.m_LineRenderGos == nil then
          local lineRenderGos = GameObject.New()
          lineRenderGos.name = "LineRenderGos"
          UnityEngine.GameObject.DontDestroyOnLoad(lineRenderGos)
          ObjectManager.m_LineRenderGos = lineRenderGos.transform
       end
    end
end

function ObjectManager.Update(deltaTime)
    local tempReleaseList = ObjectManager.m_TempRemoveObjectKeyList
    for i, v in pairs(ObjectManager.m_ObjectMap) do
        v:Update(deltaTime)
    end

    for i, v in pairs(ObjectManager.m_DelayRemoveObjectMap) do
        v:Update(deltaTime)
        if v:IsFinishDelayRemove() then
            tinsert(tempReleaseList, v)
        end
    end

    for i = #tempReleaseList, 1, -1 do
        local v = tempReleaseList[i]
        ObjectManager.RemoveObjectImmediately(v)
        tremove(tempReleaseList, i)
    end
end

function ObjectManager.LateUpdate()
    for i, v in pairs(ObjectManager.m_ObjectMap) do
        v:LateUpdate()
    end

    for i, v in pairs(ObjectManager.m_DelayRemoveObjectMap) do
        v:LateUpdate()
    end
end

function ObjectManager.Restart()
    ObjectManager.Destroy()
    ObjectManager.Init()
end

function ObjectManager.BeforeChangeScene(prevSceneType, nextSceneType)
    --Logger.LogInfo("prevSceneType:"..tostring(prevSceneType))
    if prevSceneType ~= SceneTypeEnum.Login and prevSceneType ~= SceneTypeEnum.Loading then
        ObjectManager.RemoveAllObjectsExceptHero()
    end
    ObjectManager.m_ObjectCacheMap = nil
    ObjectManager.m_CacheObjctCount = 0
    Core_ObjectManager.Instance:ClearCacheObject()
end

function ObjectManager.AfterChangeScene(prevSceneType, nextSceneType)
    for objId, object in pairs(ObjectManager.m_ObjectMap) do
        object:AfterChangeScene(prevSceneType, nextSceneType)
    end
end

function ObjectManager.Destroy()
    --Logger.LogInfo("ObjectManager.Destroy")
    local removeList = {}

    for objId, object in pairs(ObjectManager.m_ObjectMap) do
        tinsert(removeList, objId)
    end

    for _, objId in ipairs(removeList) do
        ObjectManager.RemoveObjectImmediately(objId)
    end

    ObjectManager.m_ObjectMap = nil
    ObjectManager.m_ObjectCacheMap = nil
    ObjectManager.m_CacheObjctCount = 0
end

----------------------------------------------------------------NPC相关----------------------------------------

function ObjectManager.CreateClientNpc(npcId, position, angle, scale, callBack)
    local npcCfg = Npcs[npcId]

    if not npcCfg then
        Logger.LogErrorFormat("[[ObjectManager](CreateClientNpc)Npc config not found, npcId: {0}", npcId)
        return nil
    end

    local npc = nil

    npc = ObjectManager.GetClientNpc(npcId)
    if npc ~= nil then
        if callBack then
            callBack(npc)
        end
       return npc
    end

    local npc = ObjectManager.CreateClientObject(ObjectTypeEnum.OutLook, npcCfg.ModelID, position, angle, scale, false, function(object)
        object.m_npcID = npcId
        if callBack then
            callBack(object)
        end
    end)
    npc.m_npcID = npcId
    return npc
end

function ObjectManager.GetClientNpc(npcId)
    for k,v in pairs(ObjectManager.m_ObjectMap) do
        if v.m_npcID == npcId then
            return v
        end
    end
end

return ObjectManager