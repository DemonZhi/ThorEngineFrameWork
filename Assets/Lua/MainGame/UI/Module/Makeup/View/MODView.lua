
---@class MODView:BaseTabPanel
local MODView = class("MODView", BaseTabPanel)
local k_ShapeSubViewKey = "ShapeSubView"
local k_MakeSubViewKey = "MakeUpSubView"
local ShapeSubViewClass = require('MainGame/UI/Module/Makeup/View/ShapeSubView')
local MakeUpSubViewClass = require('MainGame/UI/Module/Makeup/View/MakeUpSubView')
local JobIDEnum = require("MainGame/Common/Const/JobIDEnum")
local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local PoolingStrategyTypeEnum = require('Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum')
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")

local k_MeshRenderNameList = {
    {"mod_role_fa_01"},
    {"mod_role_ey_01", "mod_role_ey_02", "mod_role_tg"},
    {"mod_role_eb"},
    {"mod_role_fa_01"},
    {"mod_role_fa_01"},
    {"mod_role_fa_01"},
}

local k_FaceMeshRenderName = "mod_role_fa_01"
local k_UIModelPosition = Vector3.New(-0.05, -1.53, 0.5)
local k_UIModelRotation = Vector3.New(0, 178.5, 0)
local k_PinchModelPostion = Vector3.New(0, 1000, 0)
local k_UIModelConfigIndex = 36
local k_PinchModelConfigIndex = 37
local k_DragFactor = 0.5

local function CreateModle(self)
	local showObj = ObjectManager.CreateObject(ObjectTypeEnum.OutLook)
    self.m_ObjID = ObjectManager.GenerateClientObjectID()
    ObjectManager.AddObject(self.m_ObjID, showObj)
    showObj:Init()
    showObj:SetObjectID(self.m_ObjID)
    showObj.m_Core:SetScale(1)
   	showObj.m_Core:SetRotation(Quaternion.Euler(k_UIModelRotation))

    local componentAvatar = ComponentAvatar.New()
    showObj:AddComponent(componentAvatar, false)
    self.m_ComponentAvatar = componentAvatar

    local componentFaceMakeUp = ComponentFaceMakeUp.New()
    showObj:AddComponent(componentFaceMakeUp, false)
    self.m_UIModelComponentFaceMakeUp = componentFaceMakeUp

    showObj:SetModelID(k_UIModelConfigIndex)
    componentAvatar:SetWearSubpart(AvatarSubpartTypeEnum.Body, 31, true, false)
    showObj:LoadModel(function()
        self.m_ShowObj = showObj
        UIManager.Set3DParent(self.m_ShowObj:GetModel(), Vector3.one, k_UIModelPosition);
        self.m_ShowObj:PlayAnimation(StateConsts.k_IdleAnimationName)
        self.m_UIModelComponentFaceMakeUp:InitPinchData()

        if self.m_CacheCurChangePart then 
            self:ChangePart(self.m_CacheCurChangePart)
        end
    end)
end

local function CreatePinchFaceModel(self)
    local pinchFaceObject = ObjectManager.CreateObject(ObjectTypeEnum.OutLook)
    local objID = ObjectManager.GenerateClientObjectID()
    ObjectManager.AddObject(objID, pinchFaceObject)
    pinchFaceObject:Init()
    pinchFaceObject:SetObjectID(objID)

    pinchFaceObject:SetScale(1)
    pinchFaceObject.m_Core:SetPosition(k_PinchModelPostion)

    local componentFaceMakeUp = ComponentFaceMakeUp.New()
    pinchFaceObject:AddComponent(componentFaceMakeUp, false)
    self.m_ComponentFaceMakeUpEdit =componentFaceMakeUp
    self.m_EditFaceMakeUpObject = pinchFaceObject 

    pinchFaceObject:SetModelID(k_PinchModelConfigIndex)
    pinchFaceObject:LoadModel(function ()
        self.m_ComponentFaceMakeUpEdit:InitPinchData()
        self.m_PinchFaceObject = pinchFaceObject
    end)
end 

local function OnDargHandler(self, eventData)
    local offset = (eventData.position.x - self.m_DragStartPostion.x) * k_DragFactor
    local angleY = self.m_DragStartAngleY - offset
    self.m_ShowObj:SetAngleXYZ(0, angleY, 0)
end

--界面初始化
function MODView:InitUI()
    -- UIManager.SetBGUIParent(self.m_BgRoot.gameObject)
    self.m_IsLoadEditModel = false
    self.m_IsLoadUIModel = false
	self:AddButtonListener(self.btnBack, function ()
        MakeupController.CloseMODView()
    end)

    self:AddButtonListener(self.btnFullScreen, function ()
        UIManager.OpenUI("FullScreenRedView")
    end)

	self.m_TabConfig = {
		{self.toggleShape, ShapeSubViewClass, k_ShapeSubViewKey},
		{self.toggleMakeUp, MakeUpSubViewClass, k_MakeSubViewKey},
	}
    self:InitTab(self.m_TabConfig)

    self.m_UIEventTriggerListener = self.toucharea:GetComponent('UIEventTriggerListener')
    self.m_UIEventTriggerListener.onDrag = function (eventData)
        OnDargHandler(self, eventData)
    end
    self.m_UIEventTriggerListener.onBeginDrag = function (eventData)
        self.m_DragStartPostion = eventData.position
        local x, y, z = self.m_ShowObj:GetAngleXYZ(true)
        self.m_DragStartAngleY = y
    end

    self.m_FaceCustomizeMask = self.m_Transform:GetComponent('FaceCustomizeMask')

    CreateModle(self)

    CreatePinchFaceModel(self)
end

--打开界面回调
function MODView:OnOpen(params)
    self.m_BgRoot.gameObject:SetActive(true)
	if self.m_ShowObj then 
		self.m_ShowObj.m_Core:SetActive(true)
	end
end

--关闭界面回调
function MODView:OnClose()
    self.m_BgRoot.gameObject:SetActive(false)
	if self.m_ShowObj then 
		self.m_ShowObj.m_Core:SetActive(false)
	end
end

--销毁界面回调
function MODView:OnDestroy()
    self.m_UIEventTriggerListener.onDrag = nil
    self.m_UIEventTriggerListener = nil
    self.m_FaceCustomizeMask = nil
    ObjectManager.RemoveObject(self.m_ObjID)
end

function MODView:PichFacce(config, value)
    if not self.m_ShowObj or not self.m_PinchFaceObject then 
        return
    end

    local strList = string.split(config.SwitchRange, "_")
    local minValue = tonumber(strList[1])
    local maxValue = tonumber(strList[2])

    if config.interchange == 1 then
        value = 1 - value
    end
    value = minValue + (maxValue - minValue) * value

    self.m_ComponentFaceMakeUpEdit:SetFaceTransformValue(config.FaceID, value)
end

function MODView:BakeFace(facialID)
    local renderNameList =  k_MeshRenderNameList[facialID]
    for i,renderName in ipairs(renderNameList) do
        local bakeMesh = self.m_UIModelComponentFaceMakeUp:GetBakeMesh(renderName)
        local skinedMeshRender = self.m_UIModelComponentFaceMakeUp:GetSkinedMeshRender(renderName)
        if skinedMeshRender then 
            self.m_ComponentFaceMakeUpEdit:BakeFaceMesh(renderName, skinedMeshRender, bakeMesh)
            skinedMeshRender.sharedMesh = bakeMesh
        end
    end
end

function MODView:SetFaceMakeupValue(makeupType, value, iLatitudeType, iMakeupID)
    self.m_UIModelComponentFaceMakeUp:SetFaceMakeupValue(makeupType, value, iLatitudeType, iMakeupID)
end

function MODView:RefreshFace()
    self.m_UIModelComponentFaceMakeUp:RefreshFace()
end

function MODView:GetUIComponentFaceMakeUp()
    return self.m_UIModelComponentFaceMakeUp
end

function MODView:ChangePart(index)
    local skinedMeshRender = self.m_UIModelComponentFaceMakeUp:GetSkinedMeshRender(k_FaceMeshRenderName)
    if skinedMeshRender == nil then 
        self.m_CacheCurChangePart = index
        return
    end

    if self.m_FaceCustomizeMask.material == nil then 
        self.m_FaceCustomizeMask.material = skinedMeshRender.materials[1]
    end
    self.m_FaceCustomizeMask:ChangePart(index)
end

function MODView:StopFaceCustomizeMask()
    self.m_FaceCustomizeMask:Stop()
end

function MODView:OnFullScreenCallback(isShow)
    if self.m_ShowObj == nil then 
        return 
    end
    self.m_ShowObj:GetModel():SetActive(isShow)
    self.m_BgRoot.gameObject:SetActive(isShow)
end

return MODView