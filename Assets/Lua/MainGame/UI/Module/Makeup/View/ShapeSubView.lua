
---@class ShapeSubView:BaseView
local ShapeSubView = class("ShapeSubView", BaseView)
local ShapeItem = require("MainGame/UI/Module/Makeup/Item/ShapeItem")
local SubShapeItem = require("MainGame/UI/Module/Makeup/Item/SubShapeItem")
local ShapeSliderItem = require("MainGame/UI/Module/Makeup/Item/ShapeSliderItem")
local MakeUpDefine = require("MainGame/UI/Module/Makeup/Model/Define/MakeUpDefine")
local FaceConfig = FaceConfig
local k_ToggleCount = 3

local function UpdateSliders(self)
    for i=1, k_ToggleCount do
        local shapingData = self.m_LatitudeTypelst[i]
        if shapingData then  
            self.m_ShapeSliderItemList[i]:SetActive(true)
            self.m_ShapeSliderItemList[i]:UpdateUI(shapingData, self.m_ArrayLatitudeType)
        else
            self.m_ShapeSliderItemList[i]:SetActive(false)
        end
    end
end 

local function OnClickToggle(self, index, value)
    if value then 
        local latitudeData = self.m_LatitudeList[index]
        self.m_ShapingList = MakeupController.model:GetLatitudeDataSubList(latitudeData)

         --维度调节slider
        self.m_LatitudeTypelst = {}
        self.m_ArrayLatitudeType = {}
        local LatitudeTypelst = self.m_ShapingList
        --只取FaceID最后一位为0和1的
        for index, value in ipairs(LatitudeTypelst) do
            if value.data.FaceID % 10 == 0 or value.data.FaceID % 10 == 1 then
                table.insert(self.m_LatitudeTypelst,value)
            end
            if self.m_ArrayLatitudeType[value.data.ShapingName] == nil then
                local namelst = {}
                table.insert(namelst,value)
                self.m_ArrayLatitudeType[value.data.ShapingName] = namelst
            else
                local namelst = self.m_ArrayLatitudeType[value.data.ShapingName]
                table.insert(namelst,value)
            end
        end
        
        UpdateSliders(self)
    end
end

local function UpdateToggleName(self)
    self.tab_toggle1.isOn = true
    OnClickToggle(self, 1, true)
    for i=1, k_ToggleCount do
        local latitudeData = self.m_LatitudeList[i]
        if latitudeData then  
            self["tab_toggle" .. i].gameObject:SetActive(true)
            self["txt_anniu" .. i].text = latitudeData.data.LatitudeMode
        else
            self["tab_toggle" .. i].gameObject:SetActive(false)
        end
    end
end

local function OnGetSubShapeItemByIndex(self, loopGridView, itemIndex)
    local newItem = self.m_loopSubShapeItemView:GetItemClass("item_bb", SubShapeItem, itemIndex)
    local curData  = self.m_AreaList[newItem.itemIndex]
    newItem:SetInfoItem(curData.data)
    return newItem.listItem
end

---选中子类型
local function RefeshSubItemInfo(self, areaData, index, bItemClick)
    self.m_LatitudeList = MakeupController.model:GetAreaDataSubList(areaData)
    local latitudeData = self.m_LatitudeList[1]
    local faceCustomizeMaskType = latitudeData.data.FacialID .. "_" .. latitudeData.data.AreaID
    MakeupController.ChangePart(MakeUpDefine.FaceCustomizeMaskType[faceCustomizeMaskType])
    UpdateToggleName(self)
end

local function UpdateShapeList(self)
    if self.m_ShapeInfolst == nil then
        return
    end
    self.m_LoopShapeItemView:SetListItemCount(#self.m_ShapeInfolst)
    self.m_LoopShapeItemView:RefreshAllShownItem()
    self.m_LoopShapeItemView:SetSelect(1,true) 
end

---更新
local function OnGetShapeItemByIndex(self, loopGridView, itemIndex)
    local newItem = self.m_LoopShapeItemView:GetItemClass("item_bb", ShapeItem, itemIndex)
    local shapeType  = self.m_ShapeInfolst[newItem.itemIndex]
    newItem:SetInfoItem(shapeType.data, self.m_TabIndex)
    return newItem.listItem
end

---选中大类型
local function RefreshShapeItemInfo(self, shapeData, index, bItemClick)
    self.m_AreaList = MakeupController.model:GetShapeDataSubList(shapeData)

    self.m_loopSubShapeItemView:Clear()
    self.m_loopSubShapeItemView:SetListItemCount(#self.m_AreaList)
    self.m_loopSubShapeItemView:RefreshAllShownItem()
    self.m_loopSubShapeItemView:SetSelect(1,true) 
end

--界面初始化
function ShapeSubView:InitUI()
    self.m_ShapeInfolst = MakeupController.model:GetShapeTypeList()
	 --大类型
    self.m_fnOnShapeItemByIndex = function(loopGridView, itemIndex)
        return OnGetShapeItemByIndex(self, loopGridView, itemIndex)
    end
    self.m_LoopShapeItemView = LoopListView2.New(self.lpGrid_shape, self)
    self.m_LoopShapeItemView:InitListView(0, self.m_fnOnShapeItemByIndex)
    self.m_LoopShapeItemView.IsParentSelect = true

    self.m_LoopShapeItemView:AddSelect(function(index, bItemClick)
        local shapeData = self.m_ShapeInfolst[index]
        RefreshShapeItemInfo(self, shapeData, index, bItemClick)
    end)

    --子类型
    self.m_fnOnSubShapeItemByIndex = function(loopGridView, itemIndex)
        return OnGetSubShapeItemByIndex(self, loopGridView, itemIndex)
    end
    self.m_loopSubShapeItemView = LoopListView2.New(self.lpGrid_subshape, self)
    self.m_loopSubShapeItemView:InitListView(0, self.m_fnOnSubShapeItemByIndex)
    self.m_loopSubShapeItemView.IsParentSelect = true

    self.m_loopSubShapeItemView:AddSelect(function(index,bItemClick)
        local areaData = self.m_AreaList[index]
        RefeshSubItemInfo(self, areaData, index, bItemClick)
    end)

    -- 右边toggle
    for i=1, k_ToggleCount do
        local toggle = self["tab_toggle" .. i]
        self:AddToggleOrSliderListener(toggle, function (isOn)
            OnClickToggle(self, i, isOn)
        end)
    end

    -- init slider
    self.m_ShapeSliderItemList = {}
    for i=1, k_ToggleCount do
        local shapeSliderItem = ShapeSliderItem.New()
        shapeSliderItem:Init(self["item_bb" .. i].gameObject)
        shapeSliderItem:InitUI(nil, i)
        table.insert(self.m_ShapeSliderItemList, shapeSliderItem)
    end

    UpdateShapeList(self)
end

--打开界面回调
function ShapeSubView:OnOpen()
    if self.m_LatitudeList then 
        local latitudeData = self.m_LatitudeList[1]
        local faceCustomizeMaskType = latitudeData.data.FacialID .. "_" .. latitudeData.data.AreaID
        MakeupController.ChangePart(MakeUpDefine.FaceCustomizeMaskType[faceCustomizeMaskType])
    end
end

--关闭界面回调
function ShapeSubView:OnClose()
end

--销毁界面回调
function ShapeSubView:OnDestroy()
end

return ShapeSubView