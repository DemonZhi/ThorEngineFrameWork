local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local InstancingModelInfoConfig = require("MainGame/Configs/Model/InstancingModelInfo")
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local ModelLoadTypeEnum = require("Engine/Common/Const/ModelLoadTypeEnum")
local SGTrigger = class("SGTrigger", SGCtrl)

SGTrigger.m_ObjectType = ObjectTypeEnum.Trigger

local function LoadModelDefault(self, config, isPlayer, isHero, callBack)
    local modelAddress = config.Address
    local animationType = config.AnimationType
    if isPlayer and not isHero and not string.IsNullOrEmpty(config.LODAddress) then
        modelAddress = config.LODAddress
    end

    ResourceManager.InstantiateAsync(modelAddress, function(go)
        local loadModelQueueComponent = self.m_LoadModelQueueComponent
        if loadModelQueueComponent then
            loadModelQueueComponent:OnLoaded()
        end
        if not go then
            Logger.LogErrorFormat("[SGTrigger](LoadModelDefault)Instantiate model failed, model id: {0}", modelId)
            return
        end

        if not self:IsValid() then
            Logger.LogDebugFormat("[SGTrigger](LoadModelDefault)Instantiate model failed, self:IsValid() false model id: {0}", modelId)
            ResourceManager.ReleaseInstance(go)
            return
        end

        if isHero then
            local isFirstTimeLoaded = self.m_IsFirstTimeLoaded
            BattleMessage.SendHeroAddSuccess(isFirstTimeLoaded)
            self.m_IsFirstTimeLoaded = false
            ActionController.RefreshRole()
        end

        --Logger.LogInfo("SetModel:%s, frame:%s", self:GetObjectID(), Time.frameCount)
        self:SetModel(go, animationType)
        self:SetModelPath(config.Address)

        if callBack then
            callBack(self)
        end

        if self.OnModelLoadComplete then
            self:OnModelLoadComplete()
        end
    end, PoolingStrategyTypeEnum.DontDestroyOnLoad)
end

local function OnModelLoadComplete(self, callback, instanceID)
    local loadModelQueueComponent = self.m_LoadModelQueueComponent
    if loadModelQueueComponent then
        loadModelQueueComponent:OnLoaded()
    end

    if callback then
        callback(self, instanceID)
    end

    if self.OnModelLoadComplete then
        self:OnModelLoadComplete()
    end
end

local function OnLoadInstancingModelPrefabCallback(go, objectID)
    local self = ObjectManager.GetObject(objectID)
    if not self then
        Logger.LogErrorFormat("[SGTrigger](OnLoadInstancingModelPrefabCallback)object not found:[{0}]", objectID)
        ResourceManager.ReleaseInstance(go)
        return
    end

    if not go then
        Logger.LogErrorFormat("[SGTrigger](OnLoadInstancingModelPrefabCallback)Instantiate model failed, model id: {0}", modelId)
        return
    end

    self:SetModel(go)

    local instanceID = self.m_InstanceID
    local callback = self.m_LoadModelCallback
    self.m_LoadModelCallback = nil
    OnModelLoadComplete(self, callback, instanceID)
end


local function CreateInstancingObjectCallback(instanceID, objectID)
    local self = ObjectManager.GetObject(objectID)
    if self == nil then
        Logger.LogErrorFormat("[SGTrigger](CreateInstancingObjectCallback)object not found:[{0}]", objectID)
        ResourceManager.DestroyInstanceObject(instanceID)
        return
    end

    self.m_InstanceID = instanceID
    ResourceManager.SetInstancePosition(instanceID, self:GetPosition())
    ResourceManager.SetInstanceRotation(instanceID, self:GetRotation())
    --ResourceManager.SetInstanceScale(instanceID, self:GetScale())
    
    local modelId = self:GetModelID()
    local config = ModelConfig[modelId]
    local instancingModelInfo = InstancingModelInfoConfig[config.Address]
    local prefab = instancingModelInfo.Prefab
    local callback = self.m_LoadModelCallback
    self.m_LoadModelCallback = nil
    if not prefab then
        OnModelLoadComplete(self, callback, instanceID)
    else
        ResourceManager.InstantiateAsync(prefab, OnLoadInstancingModelPrefabCallback, PoolingStrategyTypeEnum.Default, objectID)
    end  
end

local function LoadModelGPUInstancing(self, config, callBack)
    if callback then
        self.m_LoadModelCallback = callBack
    end
    ResourceManager.CreateInstancingObject(config.Address, CreateInstancingObjectCallback, self:GetObjectID())
end

function SGTrigger:Ctor()
    SGTrigger.__super.Ctor(self)
end

function SGTrigger:RegisterCommonComponents()
end

function SGTrigger:RegisterSerializedComponents()
end

function SGTrigger:OnModelLoadComplete()
    self:SetLayer("Trigger")
    
    -- setMap obstacle
    local obstacleLayerMask = SGEngine.Core.Layers.k_TriggerMask;
    local color = UnityEngine.Color.red
    OutlineManager.SetNodeInObstacle(self:GetModel(), obstacleLayerMask, color)
end

function SGTrigger:Destroy()
    -- Clear obstacle
    local obstacleLayerMask = SGEngine.Core.Layers.k_TriggerMask;
    local color = UnityEngine.Color.white
    OutlineManager.SetNodeInObstacle(self:GetModel(), obstacleLayerMask, color)
    
    SGTrigger.__super.Destroy(self)
    if self.m_InstanceID then
        ResourceManager.DestroyInstanceObject(self.m_InstanceID)
        self.m_InstanceID = nil
    end
end

function SGTrigger:Deserialize(netBuffer)
    SGTrigger.__super.Deserialize(self, netBuffer)
    
    self.m_TriggerId = netBuffer:ReadInt()
    
    local endFlags = ComponentDefine.TriggerDeserializeEndFlag
    
    if not self:CheckSerialize(netBuffer, endFlags.k_SER_FLAG_TRIGGER_END) then
        Logger.LogError("[SGTrigger](Deserialize)SGTrigger Deserialize failed, endFlags.k_SER_FLAG_TRIGGER_END not match")
        return
    end
end

function SGTrigger:LoadModelCore(isPlayer, isHero, callBack)
    --Logger.LogErrorFormat("Trigger LoadModelCore:[{0}], frame:[{1}]", self:GetObjectID(), Time.frameCount)
    local modelId = self:GetModelID()
    local config = ModelConfig[modelId]
    if not config then
        Logger.LogErrorFormat("[SGTrigger](LoadModelCore)Create Object failed, model config not found, model id: {0}", modelId)
        return nil
    end

    if config.LoadType == ModelLoadTypeEnum.GPUInstancing then
        LoadModelGPUInstancing(self, config, callBack)
    else
        LoadModelDefault(self, config, isPlayer, isHero, callBack)
    end
end

return SGTrigger

