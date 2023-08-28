---@class HeroCardItem:SuperBaseItem
local HeroCardItem = class("HeroCardItem", SuperBaseItem)
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local RectTransformUtility = UnityEngine.RectTransformUtility
local k_UIModelPosition = Vector3.New(-0.05, -1.53, 0.5)
local k_UIModelRotation = Vector3.New(0, 178.5, 0)

local function GetModelWorldPosition(self)
    return UIManager.GetPositionIn3DCamera(self.img_select.transform.position)
end

local function CreateModle(self)
    if self.m_ShowObj ~= nil then 
        self.m_ShowObj:SetObjectID(self.m_ObjID)
        self.m_ShowObj:SetModelID(self.m_ModelId)
        self.m_ShowObj:LoadModel(function()
            self.m_ShowObj.m_Core:SetScale(self.m_Scale)
            self.m_ShowObj.m_Core:EnableStencil()
            UIManager.Set3DParent(self.m_ShowObj:GetModel(), Vector3.one, GetModelWorldPosition(self));
            self.m_ShowObj:PlayAnimation(StateConsts.k_IdleAnimationName)
        end)
    else
        local showObj = ObjectManager.CreateObject(ObjectTypeEnum.OutLook)
        self.m_ObjID = ObjectManager.GenerateClientObjectID()
        ObjectManager.AddObject(self.m_ObjID, showObj)
        showObj:Init()
        showObj:SetObjectID(self.m_ObjID)
        showObj.m_Core:SetRotation(Quaternion.Euler(k_UIModelRotation))

        showObj:SetModelID(self.m_ModelId)
        showObj:LoadModel(function()
            self.m_ShowObj = showObj
            self.m_ShowObj.m_Core:SetScale(self.m_Scale)
            self.m_ShowObj.m_Core:EnableStencil()
            UIManager.Set3DParent(self.m_ShowObj:GetModel(), Vector3.one, GetModelWorldPosition(self));
            self.m_ShowObj:PlayAnimation(StateConsts.k_IdleAnimationName)
        end)
    end
end

function HeroCardItem:UpdatePerFrame()
    if self.m_ShowObj ~= nil then 
        self.m_ShowObj.m_Core:SetScale(self.m_Scale)
        local worldPos = GetModelWorldPosition(self)
        self.m_ShowObj.m_Core:SetPositionXYZ(worldPos.x, worldPos.y, 5)
    end
end

function HeroCardItem:SetData(data, index)
    if self.m_ModelId == nil or data.config.modelIndex ~= self.m_ModelId then 
        self.m_ModelId = data.config.modelIndex
        self.m_Scale = data.config.modelScale
        self.m_Rect = data.rect
        CreateModle(self)
    end

    if self.m_TimeId == nil then 
        self.m_TimeId = TimerManager:AddFrameTimer(self, self.UpdatePerFrame, 1, 0)
    end
end

--子类重写
function HeroCardItem:InitUI()    
end

--子类重写
function HeroCardItem:OnDestroy()
    self:OnClose()
end

function HeroCardItem:OnClose()
    self.m_ShowObj = nil
    if self.m_TimeId ~= nil then 
        TimerManager:RemoveTimer(self.m_TimeId)
        self.m_TimeId = nil
    end

    if self.m_ObjID ~= nil then 
        ObjectManager.RemoveObject(self.m_ObjID)
        self.m_ObjID = nil
    end

    self.m_ModelId = nil 
end

return HeroCardItem