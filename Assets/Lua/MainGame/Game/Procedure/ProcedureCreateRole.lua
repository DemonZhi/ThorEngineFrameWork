local JobIDEnum = require("MainGame/Common/Const/JobIDEnum")
local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local PoolingStrategyTypeEnum = require('Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum')
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local RenderSetting = SGEngine.Rendering.RenderSetting
local AvatarSubpartTypeEnum = AvatarSubpartTypeEnum
ProcedureCreateRole = ProcedureCreateRole or {}

local k_CreatRoleCameraData = "Assets/Art/CameraData/CreatRoleCameraData.asset"

--region 生命周期
function ProcedureCreateRole.Init()
end

function ProcedureCreateRole.Enter()
    -- 设置阴影距离
    local renderSetting = RenderSetting.GetActiveSetting()
    ProcedureCreateRole.originalShadowDistance = renderSetting.sceneData.shadowDistance
    renderSetting.sceneData.shadowDistance = 10
    renderSetting:UpdateSceneData()

    ProcedureCreateRole.m_IsPreLoadFinish = false
    ProcedureCreateRole.PreLoad()
    WaitingController.OpenWaitingView(function()
        return ProcedureCreateRole.m_IsPreLoadFinish
    end)
end

function ProcedureCreateRole.Update(deltaTime)
    if ProcedureCreateRole.m_PreLoadingCount and ProcedureCreateRole.m_PreLoadingCount == 0 then
        ProcedureCreateRole.m_PreLoadingCount = -1
        ProcedureCreateRole.PreLoadFinish()
    end
end

function ProcedureCreateRole.Leave()
    if ProcedureCreateRole.m_ShowObj then
        ProcedureCreateRole.m_ShowObj.m_Core:CameraControllerSetZoomEnable(true)
        ObjectManager.RemoveObjectImmediately(ProcedureCreateRole.m_ShowObj:GetObjectID())
        ProcedureCreateRole.m_ShowObj = nil
    end
    UIManager.CloseAllUI()
    ProcedureCreateRole.ReleasePreLoadRes()

    local renderSetting = RenderSetting.GetActiveSetting()
    renderSetting.sceneData.shadowDistance = ProcedureCreateRole.originalShadowDistance
    renderSetting:UpdateSceneData()
end

function ProcedureCreateRole.Destroy()
end
--endregion

-- 预载资源
function ProcedureCreateRole.PreLoad()
    -- 预载角色模型及默认部件
    ProcedureCreateRole.m_PreLoadingCount = 0
    ProcedureCreateRole.m_PreLoadPrefabList = {}
    ProcedureCreateRole.m_PreLoadScriptableObjectList = {}

    ProcedureCreateRole.m_BeginPreloadTime = Time.time
    for _, v in pairs(JobConfig) do
        ProcedureCreateRole.PreLoadModel(v.MaleModelID)
        ProcedureCreateRole.PreLoadModel(v.FemaleModelID)
    end

    -- 预载UI
    ProcedureCreateRole.PreLoadView(CreateRoleController.GetAllViewsName())
end

function ProcedureCreateRole.PreLoadModel(modelID)
    local jobConfig = JobConfig
    local modelConfig = ModelConfig
    local subpartConfig = AvatarSubpartConfig
    local modelConfigItem = modelConfig[modelID]
    if modelConfigItem == nil then
        Logger.LogErrorFormat("[ProcedureCreateRole](PreLoad) can not find modelConfig by ID: {0}", modelID)
        return
    end
    ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount + 1
    -- 预载角色模型
    ResourceManager.CreateInstancePoolCache(
            modelConfigItem.Address,
            PoolingStrategyTypeEnum.DontDestroyOnLoad,
            1,
            function(param)
                ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount - 1
            end
    )

    -- 预载角色默认部件
    if not modelConfigItem.DefaultSubpartList then
        return
    end
    for _, suppartID in pairs(modelConfigItem.DefaultSubpartList) do
        local subpartConfigItem = subpartConfig[suppartID]
        ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount + 1
        ResourceManager.CreateInstancePoolCache(
                subpartConfigItem.PrefabAddress,
                PoolingStrategyTypeEnum.DontDestroyOnLoad,
                1,
                function(param)
                    ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount - 1
                end
        )

        -- 预载部件骨骼配置
        if not string.IsNullOrEmpty(subpartConfigItem.BoneConfigAddress) then
            ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount + 1
            local loadHandle = ResourceManager.LoadScriptableObjectAsync(subpartConfigItem.BoneConfigAddress, function(scriptableObject)
                ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount - 1
            end)
            table.insert(ProcedureCreateRole.m_PreLoadScriptableObjectList, loadHandle)
        end
    end
end

function ProcedureCreateRole.PreLoadView(viewsName)
    if not viewsName then
        return
    end

    for _, v in ipairs(viewsName) do
        ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount + 1
        ResourceManager.CreateInstancePoolCache(v, PoolingStrategyTypeEnum.Default, 1,
                function(param)
                    ProcedureCreateRole.m_PreLoadingCount = ProcedureCreateRole.m_PreLoadingCount - 1
                end
        )
    end
end

-- 预载完成
function ProcedureCreateRole.PreLoadFinish()
    ProcedureCreateRole.m_IsPreLoadFinish = true
    Logger.LogInfoFormat("[ProcedureCreateRole](PreLoadFinish)Preload Cost Time:[{0}]", Time.time - ProcedureCreateRole.m_BeginPreloadTime)
    UIManager.CloseAllUI()
    local modelPosTransform = GameObject.Find("ModelPos").transform
    ProcedureCreateRole.m_ModelPosTransform = modelPosTransform
    local createRoleModel = CreateRoleController.model
    local playerInfo = createRoleModel:GetLastJoinOrFirstPlayerInfo()
    local jobID = JobIDEnum.Min
    local gender = GenderTypeEnum.Male
    if playerInfo then
        jobID = playerInfo.jobID
        gender = playerInfo.gender
    end

    if JobConfig[jobID] == nil then
        Logger.LogErrorFormat("[ProcedureCreateRole](PreLoadFinish) can not find JobConfig! id = %s", jobID)
        return
    end

    local modelID = 0
    if gender == GenderTypeEnum.Female then
        modelID = JobConfig[jobID].FemaleModelID
    else
        modelID = JobConfig[jobID].MaleModelID
    end

    ProcedureCreateRole.m_ShowModelID = modelID
    local showObj = ObjectManager.CreateObject(ObjectTypeEnum.OutLook)
    ProcedureCreateRole.m_ShowObj = showObj
    local objID = ObjectManager.GenerateClientObjectID()
    ObjectManager.AddObject(objID, showObj)
    showObj:Init()
    showObj:SetObjectID(objID)
    showObj:SetModelID(modelID)
    showObj.m_Core:SetScale(1)
    showObj.m_Core:SetPosition(modelPosTransform.position)
    local componentAvatar = ComponentAvatar.New()
    componentAvatar:SetIsLoadResourceSync(true)
    showObj:AddComponent(componentAvatar, false)
    ProcedureCreateRole.m_ComponentAvatar = componentAvatar

    local componentFaceMakeup = ComponentFaceMakeUp.New()
    showObj:AddComponent(componentFaceMakeup, false)
    ProcedureCreateRole.m_ComponentFaceMakeup = componentFaceMakeup

    showObj:LoadModel(function()
        showObj:PlayAnimation(StateConsts.k_IdleAnimationName)
        showObj.m_Core:AddComponentCameraController()
        showObj.m_Core:SetCameraData(k_CreatRoleCameraData)
        showObj.m_Core:SetCameraRotation(Vector3.New(0, 180, 0))
        showObj.m_Core:ActivateMotorWithName("CreateRole")
        showObj.m_Core:CameraControllerSetZoomEnable(false)
        showObj.m_Core:CameraControllerResetZoomScale(false)
        showObj:SetLayer("Player")
    end)

    -- 平面反射
    local reflectionPlaneGameObejct = GameObject.Find("ReflectionPlane")
    if reflectionPlaneGameObejct ~= nil then
        local planarReflectionBlurComponent = reflectionPlaneGameObejct:GetComponent("PlanarReflectionBlurComponent")
        if planarReflectionBlurComponent ~= nil then
            local layer = 1 * (2 ^ LayerMask.NameToLayer("Player"))
            planarReflectionBlurComponent:SetUIRolePlanarReflection(true, Vector3.zero, layer, Camera.main)
        end
    end

    if playerInfo then
        CreateRoleController.OpenSelectRoleView()
    else
        CreateRoleController.OpenCreateRoleView()
    end
end

-- 卸载预载资源
function ProcedureCreateRole.ReleasePreLoadRes()
    local preLoadScriptableObjectList = ProcedureCreateRole.m_PreLoadScriptableObjectList
    if preLoadScriptableObjectList then
        for _, v in ipairs(preLoadScriptableObjectList) do
            ResourceManager.ReleaseScriptableObject(v)
        end
    end
end

function ProcedureCreateRole.ChangeModelInner(modelID)
    if ProcedureCreateRole.m_ShowModelID == modelID then
        return
    end

    local showObj = ProcedureCreateRole.m_ShowObj
    local config = ModelConfig[modelID]
    if showObj == nil or config == nil or config.Address == nil then
        return false
    end

    ProcedureCreateRole.m_ShowModelID = modelID
    showObj:SetModelID(modelID)
    showObj.m_Core.AnimationType = config.AnimationType
    showObj:ChangeModel(config.Address, function()
        showObj.m_Core:ActivateMotorWithName("CreateRole") -- 因为每次resetModel时 componentcameracontroller会将motor重设为3D、待优化
        showObj:PlayAnimation(StateConsts.k_IdleAnimationName)
        showObj:SetLayer("Player")

        -- local componentFaceMakeup = ProcedureCreateRole.m_ComponentFaceMakeup
        -- componentFaceMakeup:ResetFace()
        -- componentFaceMakeup:ApplyMakeupSync()
    end)
end

function ProcedureCreateRole.ChangeModel(modelID, gender)

    local componentAvatar = ProcedureCreateRole.m_ComponentAvatar
    local isNoApply = (ProcedureCreateRole.m_ShowModelID ~= modelID)
    componentAvatar:ClearCustomSubpart(isNoApply)
    componentAvatar:ClearWearSubpart(isNoApply)
    componentAvatar:ClearEquipSubpart(isNoApply)

    local componentFaceMakeup = ProcedureCreateRole.m_ComponentFaceMakeup
    componentFaceMakeup:ChangeGender(gender)

    ProcedureCreateRole.ChangeModelInner(modelID)
end

function ProcedureCreateRole.ChangeRole(playerInfo)
    -- Logger.LogInfo("[ProcedureCreateRole](ChangeRole)")
    local jobConfigItem = JobConfig[playerInfo.jobID]
    if not jobConfigItem then
        Logger.LogErrorFormat("[ProcedureCreateRole](ChangeRole) jobConfigItem not found! jobID = {0}", playerInfo.jobID)
        return
    end
    local modelID = (playerInfo.gender == GenderTypeEnum.Male and jobConfigItem.MaleModelID or jobConfigItem.FemaleModelID)
    local isNoApply = (ProcedureCreateRole.m_ShowModelID ~= modelID)
    local componentAvatar = ProcedureCreateRole.m_ComponentAvatar
    for _, subpartType in pairs(AvatarSubpartTypeEnum) do
        componentAvatar:SetCustomSubpart(subpartType, playerInfo.m_CustomSubpartDict[subpartType], true, isNoApply)
        componentAvatar:SetWearSubpart(subpartType, playerInfo.m_WearSubpartDict[subpartType], true, isNoApply)
    end

    -- 古风捏脸和奥丁捏脸配置不一样，暂时屏蔽奥丁
    -- local componentFaceMakeup = ProcedureCreateRole.m_ComponentFaceMakeup
    -- componentFaceMakeup:ChangeGender(playerInfo.gender)
    -- componentFaceMakeup:ResetFace()
    -- componentFaceMakeup:SetData(playerInfo.faceBlendshapeList, playerInfo.faceTextureList)

    -- if not isNoApply then
    --     componentFaceMakeup:ApplyMakeupSync()
    -- end
    ProcedureCreateRole.ChangeModelInner(modelID)
end

return ProcedureCreateRole