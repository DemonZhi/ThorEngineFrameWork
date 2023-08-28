---@class TestUIMoldeClipView:BaseView
local TestUIMoldeClipView = class("TestUIMoldeClipView", BaseView)
local HeroCardItem = require("MainGame/UI/Module/TestUIMoldeClip/Item/HeroCardItem")
local CameraExtensions = UnityEngine.Rendering.Universal.CameraExtensions

local k_HeroConfigs = {
    [0] = {modelIndex = 34, modelScale = 1.5},
    [1] = {modelIndex = 35, modelScale = 1},
    [2] = {modelIndex = 5, modelScale = 2},
    [3] = {modelIndex = 6, modelScale = 0.8},
    [4] = {modelIndex = 35, modelScale = 1},
}

local function OnItemByIndex(self, scroll, index, row, col)
    local item = self.m_LoopListView:GetItemClass("item_bb", HeroCardItem, index)
    local data = self.m_HeroList[index + 1]
    item:SetData(data, index + 1)
    return item.listItem
end

--界面初始化
function TestUIMoldeClipView:InitUI()

    self:AddButtonListener(self.btnClose, function ()
    	UIManager.CloseUI("TestUIMoldeClipView")
    end)

    self.onItemByIndex = function(scroll, index, row, col)
        return OnItemByIndex(self, scroll, index, row, col)
    end
    self.m_LoopListView = LoopGridView.New(self.loopListView, self)
    self.m_LoopListView:InitListView(0, self.onItemByIndex)
end

--打开界面回调
function TestUIMoldeClipView:OnOpen()
    UIManager.Set3DCameraProjection(true)
    self.m_CameraRect = UIManager.GetRectIn3DCamera(self.loopListView.transform)
    self.m_HeroList = {}
    for i=1,100 do
        local index = i % 5
        table.insert(self.m_HeroList, {config = k_HeroConfigs[index], rect = self.m_CameraRect})
    end
    self.m_LoopListView:Clear()
    self.m_LoopListView:SetListItemCount(#self.m_HeroList, false, true)
    self.m_StencilPlane = UIManager.AddStencilPlane(self.m_CameraRect)

    if Camera.main.cullingMask ~= 0 then
        self.cullingMask = Camera.main.cullingMask
        Camera.main.cullingMask = 0

        local cameraData = CameraExtensions.GetUniversalAdditionalCameraData(Camera.main)
        self.renderPostProcessing = cameraData.renderPostProcessing
        cameraData.renderPostProcessing = false
    end
    
end

--关闭界面回调
function TestUIMoldeClipView:OnClose()
    UIManager.Set3DCameraProjection(false)
    self.m_LoopListView:OnClose()
    if self.m_StencilPlane ~= nil then 
        UIManager.RemoveStencilPlane(self.m_StencilPlane)
        self.m_StencilPlane = nil
    end

    if Camera.main.cullingMask == 0 then
        Camera.main.cullingMask = self.cullingMask
        self.cullingMask = 0

        local cameraData = CameraExtensions.GetUniversalAdditionalCameraData(Camera.main)
        cameraData.renderPostProcessing = self.renderPostProcessing
    end
end

--销毁界面回调
function TestUIMoldeClipView:OnDestroy()
    self.m_LoopListView:OnDestroy()
end

return TestUIMoldeClipView