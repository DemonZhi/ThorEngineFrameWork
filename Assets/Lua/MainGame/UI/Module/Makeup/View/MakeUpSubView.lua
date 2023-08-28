
---@class MakeUpSubView:BaseView
local MakeUpSubView = class("MakeUpSubView", BaseView)
local MakeUpItem = require("MainGame/UI/Module/Makeup/Item/MakeUpItem")
local GroupItem = require("MainGame/UI/Module/Makeup/Item/GroupItem")
local DoubleItem = require("MainGame/UI/Module/Makeup/Item/DoubleItem")
local MakeUpDefine = require("MainGame/UI/Module/Makeup/Model/Define/MakeUpDefine")
local MakeUpSliderItem = require("MainGame/UI/Module/Makeup/Item/MakeUpSliderItem")
local ColorPicker = require("MainGame/UI/Common/ColorPicker")

local Color = UnityEngine.Color

---有底妆页签时候 有色盘 滑动条位置
---有底妆页签时候 无色盘 滑动条位置
---无底妆页签时候 有色盘 滑动条位置
---无底妆页签时候 无色盘 滑动条位置
---无底妆页签时候 有双眼页签时候 有色盘 滑动条位置
---无底妆页签时候 有双眼页签时候 无色盘 滑动条位置
local SliderPos = 
{
    Vector3.New(431,16,0),
    Vector3.New(431,143,0),
    Vector3.New(431,76,0),
    Vector3.New(431,199,0),
    Vector3.New(431,-34,0),
    Vector3.New(431,95,0),
}

---有底妆页签时候 有色盘 位置
---无底妆页签时候 有色盘 位置
---无底妆页签时候 有双眼页签时候 有色盘 位置
local ColorPos = 
{
    Vector3.New(424,168,0),
    Vector3.New(424,223,0),
    Vector3.New(424,118,0),
}

local singleColorPos = 
{
    Vector3.New(-91,-16,0),
    Vector3.New(91,-16,0),
}

local k_ColorPickerPostion = Vector3.New(328, 233, 0)
local k_ColorPickerScale = Vector3.New(0.4, 0.4, 0.4)

local k_ToggleCount = 2

local function GetCurEditType(self)
    if self.m_DoubleSelectInfo.dressConfig.SecondaryID == 0 then
        self.m_curEditType = table.concat({self.m_DoubleSelectInfo.dressConfig.PrimaryID, "_", self.m_DoubleSelectInfo.dressConfig.SecondaryID})
    else
        self.m_curEditType = table.concat({self.m_DoubleSelectInfo.dressConfig.PrimaryID, "_", self.m_threeSelectIndex})
    end
    return self.m_curEditType
end

local function OnChangeColor(self, color)
    --基础key
    self.m_curEditType = GetCurEditType(self)
    --双眼开启处理
    if self.m_DoubleSelectInfo.iEyeToggle == 1 then
        for i = 1, 2 do
            local curEditType = table.concat({self.m_curEditType,"_2_", i})
            MakeupController.SetFaceMakeupValue(curEditType, color)
        end
    else
        local curEditType = table.concat({self.m_curEditType, "_23"})
        MakeupController.SetFaceMakeupValue(curEditType, 1)
        self.m_curEditType = table.concat({self.m_curEditType,"_2"})
        MakeupController.SetFaceMakeupValue(self.m_curEditType, color)
    end
    MakeupController.RefreshModViewFace()
end 

local function OpenColorPicker(self, defaultColor)
    if self.m_ColorPicker then 
        self.m_ColorPicker:SetActive(true)
        self.m_ColorPicker:SetSelectColor(defaultColor)
    else
        self.m_ColorPicker = ColorPicker.New(self.m_Transform, 
        function (color)
            OnChangeColor(self, color)
        end, 
        function (go)
            local transform = go.transform
            transform.localPosition = k_ColorPickerPostion
            transform.localScale = k_ColorPickerScale
            self.m_ColorPicker:SetSelectColor(defaultColor)
        end)
    end
    self.btnCloseColorPicker.gameObject:SetActive(true)
end 

---插入三级页签数据
local function InsertListToGroup(self, posIndex,strGroupName)
    local iPos = posIndex
    local lstGroup = self.m_threeSelectInfo.doubleLatitudelst
    for i, v in ipairs(lstGroup) do
        iPos = iPos + 1
        table.insert(self.m_RefeshSublst, iPos, v)
    end
    self.dicGroupExpand[strGroupName] = true
end

---移除三级页签数据
local function RemoveListFromGroup(self, strGroupName)
    for i = #self.m_RefeshSublst, 1, -1 do
        if not self.m_RefeshSublst[i].config then
            local mixData = self.m_RefeshSublst[i]
            if mixData[1] and mixData[1].dressConfig then
                if mixData[1].dressConfig.SecondaryName  == strGroupName then
                    table.remove(self.m_RefeshSublst, i)
                end
            else
                table.remove(self.m_RefeshSublst, i)
            end
        end
    end

    self.dicGroupExpand[strGroupName] = nil
end

---重置三级页签选中状态
local function ResetThreeSelect(self, index, state)
    local item = self.m_loopDressSubItemView:GetItemInfo(index)
    if item then
        item:OnSelect(state)
    end
end

--选中item
local function SetSelect(self, index)
    local item = self.m_loopDressSubItemView:GetItemInfo(index)
    if item then
        local recordData = MakeupController.model:GetRecordMixData(self.m_SelectBigInfo.PrimaryID)
        if recordData then
            if recordData.iThreeIndexDic then
                local dic = recordData.iThreeIndexDic[self.m_threeSelectInfo.config.SecondaryName]
                if dic then
                    local realIndex = recordData.iThreeIndexDic[self.m_threeSelectInfo.config.SecondaryName].iSubIndex
                    if realIndex then
                        item:OnIndexSelect(realIndex, true)
                    end
                else
                    item:OnIndexSelect(1)
                end

            else
                if recordData.iSubIndex > 0 then
                    item:OnIndexSelect(recordData.iSubIndex, true)
                else
                    item:OnIndexSelect(1)
                end
            end
        else
            item:OnIndexSelect(1)
        end
    end
end

--小类型loop
local function SetSubDressLoopList(self, b, index, bclear, selectMuilt)
    if self.m_RefeshSublst == nil then
        return
    end

    if bclear then
        self.m_loopDressSubItemView:Clear()
    end
    self.m_loopDressSubItemView:SetListItemCount(#self.m_RefeshSublst, b)
    self.m_loopDressSubItemView:RefreshAllShownItem()
    if selectMuilt then
        self.m_loopDressSubItemView:SetSelectList(selectMuilt) 
    else
        if index > 0 then
            self.m_loopDressSubItemView:SetSelect(index, true) 
        end
    end
end

local function OnGetDressSubItemByIndex(self, loopGridView, itemIndex)
	local newItem = nil
    local iCurData  = self.m_RefeshSublst[itemIndex + 1]
    if iCurData.config then
        newItem = self.m_loopDressSubItemView:GetItemClass("GroupItem", GroupItem, itemIndex) 
    else
        if iCurData[1].sGroupName == "DoubleItem" then
            newItem = self.m_loopDressSubItemView:GetItemClass("DoubleItem", DoubleItem, itemIndex)
        elseif iCurData[1].sGroupName == "DoubleItem2" then
            newItem = self.m_loopDressSubItemView:GetItemClass("DoubleItem2", DoubleItem, itemIndex)    
        end    
    end

    newItem:SetInfoItem(iCurData, self)
    return newItem.listItem
end

local function RefeshDressSubItemInfo(self, data, index, isItemClick)
    if data.config then
        --sub
        self.m_threeSelectInfo = data
        
        if self.dicGroupExpand[data.config.SecondaryName] then
            --清除
            RemoveListFromGroup(self, data.config.SecondaryName)
            SetSubDressLoopList(self, true, 0)  
            self:SetArrowState("up", index)
            ResetThreeSelect(self, index, true)
        else
            --清除之前选中的三级页签
            local insertIndex = index
            local groupName = self.m_PreThreeInfolst.groupName
            if groupName then
                local bHas = false
                if self.dicGroupExpand[groupName] then
                    bHas = true
                end
                RemoveListFromGroup(self, groupName)
                self:SetArrowState("up", self.m_PreThreeInfolst.threeSelectIndex)
                if index > self.m_PreThreeInfolst.threeSelectIndex then
                    if bHas == true then
                        local lstGroup = self.m_PreThreeInfolst.threeSelectInfo.doubleLatitudelst
                        insertIndex = index - #lstGroup
                    end
                end
                
            end
            self.m_threeSelectIndex = insertIndex
            --插入子数据
            InsertListToGroup(self, insertIndex,data.config.SecondaryName)
            local recordData = MakeupController.model:GetRecordMixData(self.m_SelectBigInfo.PrimaryID)
            --有三级页签会共存选中记录
            if recordData then
                if not recordData.iThreeIndexDic then
                    SetSubDressLoopList(self, true, 1 + insertIndex) 
                else
                    local dic = recordData.iThreeIndexDic[data.config.SecondaryName]
                    if dic then
                        local iItemIndex = dic.iItemIndex
                        if iItemIndex then
                            SetSubDressLoopList(self, true, iItemIndex) 
                        else
                            SetSubDressLoopList(self, true, 1 + insertIndex)
                        end
                    else
                        SetSubDressLoopList(self, true, 1 + insertIndex)
                    end

                end
            else
                SetSubDressLoopList(self, true, 1 + insertIndex)  
            end
            self:SetArrowState("down", insertIndex)
            ResetThreeSelect(self, insertIndex, true)
            local doubleLatitudelst = {}
            self.m_PreThreeInfolst = {threeSelectInfo = data,threeSelectIndex = insertIndex, groupName = data.config.SecondaryName
            }
        end
    else
        if data[1].sGroupName == "DoubleItem" then --数组名字
            if not bItemClick then
                SetSelect(self, index)
            end
        elseif data[1].sGroupName == "DoubleItem2" then
            if not bItemClick then
                SetSelect(self, index)
            end
        end
    end
end

---获取妆容子类型数据
local function GetSubDresslst(self, iPrimaryID)
    local sublst = self.m_dressDic[iPrimaryID]
    return sublst
end

local function OnGetDressItemByIndex(self, loopGridView, itemIndex)
	local newItem = self.m_loopDressItemView:GetItemClass("item_bb", MakeUpItem, itemIndex)
    local iCurData  = self.m_DressInfolst[newItem.itemIndex]
    newItem:SetInfoItem(iCurData)
    return newItem.listItem
end

local function RefeshDressItemInfo(self, data, index, isItemClick)
    if self.m_SelectBigInfo and self.m_SelectBigInfo == data then
        return
    end

    self.m_SelectBigInfo = data

    self.m_SubDressInfolst = GetSubDresslst(self, data.PrimaryID)
    --是否有三级页签
    if self.m_SubDressInfolst[0] then --无三级页签的
        self.m_RefeshSublst = self.m_SubDressInfolst[0].doubleLatitudelst
    else
        self.m_RefeshSublst = table.clone(self.m_SubDressInfolst)
    end

    self.dicGroupExpand = {}
    self.m_PreThreeInfolst = {}
    local dIndex = 1
    local recordData = MakeupController.model:GetRecordMixData(self.m_SelectBigInfo.PrimaryID)
    if recordData then
        if not recordData.iThreeIndexDic then
            SetSubDressLoopList(self, true, recordData.iItemIndex, true)
        else
            SetSubDressLoopList(self, true, dIndex, true)
        end
    else
        SetSubDressLoopList(self, true, dIndex, true)    
    end
end

--大类型loop
local function SetDressLoopList(self)
    self.m_loopDressItemView:SetListItemCount(#self.m_DressInfolst)
    self.m_loopDressItemView:RefreshAllShownItem()
    self.m_loopDressItemView:SetSelect(1,true) 
end

local function GetMakeupEditType(self, playerData)
    local sMakeupEditType
    local beye = false
    ----后面优化掉 外部存好key值
    if self.m_SelectBigInfo.SecondaryID == 0 then
        sMakeupEditType = table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_SelectBigInfo.SecondaryID, "_", playerData.iLatitudeType})
    else
        --双眼开启处理
        if self.m_DoubleSelectInfo.iEyeToggle == 1 then
            beye = true
            sMakeupEditType = table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_threeSelectIndex, "_", playerData.iLatitudeType,"_",1})    
        else
            sMakeupEditType = table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_threeSelectIndex, "_", playerData.iLatitudeType})
        end    
        
    end

    return sMakeupEditType,beye
end

---维度调节slider状态
local function SetSliderState(self)
    local index = 0
    for i = 1, 5 do
        self.m_lstSliderInfo[i]:SetActive(false)
        if self.m_LatitudeTypelst[i] then
            index = index + 1
            self.m_lstSliderInfo[index]:SetActive(true)

            local sMakeupEditType = GetMakeupEditType(self, self.m_LatitudeTypelst[i])
            if self.m_DoubleSelectInfo.iEyebrowToggle == 1 then
                if self.m_EyebrowIndex == 1 then
                    sMakeupEditType = MakeUpDefine.MakeupEditType.EyebrowBG_Alpha
                elseif self.m_EyebrowIndex == 2 then
                    sMakeupEditType = MakeUpDefine.MakeupEditType.Eyebrow_Alpha
                end
            end
            local num =  MakeupController.model:GetFaceMakeupValue(sMakeupEditType, MakeupController.GetUIComponentFaceMakeUp())
            self.m_lstSliderInfo[index]:UpdateUI(self.m_LatitudeTypelst[i], num)
        end
    end
end

local function OnSliderValueChange(self, index, value)
    local playerData = self.m_LatitudeTypelst[index]
    local sMakeupEditType = GetMakeupEditType(self, playerData)
    --双眼开启处理 --双眼维度一起调节
    if self.m_DoubleSelectInfo.iEyeToggle == 1 then
        for i = 1, 2 do
            sMakeupEditType = table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_threeSelectIndex, "_", playerData.iLatitudeType,"_",i}) 
            MakeupController.SetFaceMakeupValue(sMakeupEditType, value, playerData.iLatitudeType, self.m_DoubleSelectInfo.dressConfig.MakeID)
        end
        MakeupController.RefreshModViewFace()
    elseif self.m_DoubleSelectInfo.iEyebrowToggle == 1 then
        if self.m_EyebrowIndex == 1 then
            MakeupController.SetFaceMakeupValue(MakeUpDefine.MakeupEditType.EyebrowBG_Alpha, value, playerData.iLatitudeType, self.m_DoubleSelectInfo.dressConfig.MakeID)
        elseif self.m_EyebrowIndex == 2 then
            MakeupController.SetFaceMakeupValue(MakeUpDefine.MakeupEditType.Eyebrow_Alpha, value, playerData.iLatitudeType, self.m_DoubleSelectInfo.dressConfig.MakeID)
        end
        MakeupController.RefreshModViewFace()
    end 

    if not beye and self.m_DoubleSelectInfo.iEyebrowToggle == 0 then
        MakeupController.SetFaceMakeupValue(sMakeupEditType, value, playerData.iLatitudeType, self.m_DoubleSelectInfo.dressConfig.MakeID)
        MakeupController.RefreshModViewFace()
    end
end 

---三级页签箭头状态 item.SetArrowRotate
function MakeUpSubView:SetArrowState(type, index)
    local item = self.m_loopDressSubItemView:GetItemInfo(index)
    if item and item.SetArrowRotate then
        item:SetArrowRotate(type)
    end
end

---点击子类型
function MakeUpSubView:ClickSubItem(itemIndex, subIndex, mixData, bIsHistory)
    if bIsHistory == nil then bIsHistory = false end
    local recordData = MakeupController.model:GetRecordMixData(self.m_SelectBigInfo.PrimaryID)
    if recordData then 
        if recordData.iThreeIndexDic and recordData.iThreeIndexDic[self.m_threeSelectInfo.config.SecondaryName] then
            local iItemIndex = recordData.iThreeIndexDic[self.m_threeSelectInfo.config.SecondaryName].iItemIndex
            local iSubIndex = recordData.iThreeIndexDic[self.m_threeSelectInfo.config.SecondaryName].iSubIndex
            if iItemIndex and iSubIndex then
                local oldItem = self.m_loopDressSubItemView:GetItemInfo(iItemIndex)
                if oldItem then
                    oldItem:CustomSelect(iSubIndex,false)
                end
            end
        else
            local oldItem = self.m_loopDressSubItemView:GetItemInfo(recordData.iItemIndex)
            if oldItem then
                oldItem:CustomSelect(recordData.iSubIndex,false)
            end
        end

    end

    local prevSelectItemIndex = self.m_SelectItemIndex
    local prevSelectSubIndex = self.m_SelectSubIndex
    local prevDoubleSelectInfo = self.m_DoubleSelectInfo
    self.m_SelectItemIndex = itemIndex
    self.m_SelectSubIndex = subIndex
    self.m_DoubleSelectInfo = mixData

    if mixData.sGroupName == "DoubleItem" then
        MakeupController.model:RecordDressMinData(self.m_SelectBigInfo.PrimaryID,0,itemIndex,subIndex)
    elseif mixData.sGroupName == "DoubleItem2" then
        MakeupController.model:RecordDressMinData(self.m_SelectBigInfo.PrimaryID,self.m_threeSelectIndex,itemIndex,subIndex,self.m_threeSelectInfo.config.SecondaryName)
    end

    --右边调节维度
    local nilState =  mixData.dressConfig.MakeID % 10 
    if nilState == 0 then
        self.transform_rightInfo.gameObject:SetActive(false)
        --卸下
        if not bIsHistory then
            if self.m_SelectBigInfo.SecondaryID == 0 then
                MakeupController.SetFaceMakeupValue(table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_SelectBigInfo.SecondaryID, "_0"}), nil)
            else
                --双眼开启处理
                if self.m_DoubleSelectInfo.iEyeToggle == 1 then
                    for i = 1, 2 do
                        MakeupController.SetFaceMakeupValue(table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_threeSelectIndex, "_0","_",i}), nil)
                    end
                else
                    -- 珠粉特殊处理 维度选0 
                    if self.m_DoubleSelectInfo.iToggle == 1 then
                        self.m_LatitudeTypelst = self.m_DoubleSelectInfo.zhuFenLatitude
                        for index, playerData in ipairs(self.m_LatitudeTypelst) do
                            local sMakeupEditType = table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_threeSelectIndex, "_", playerData.iLatitudeType})
                            MakeupController.SetFaceMakeupValue(sMakeupEditType, 0, playerData.iLatitudeType, self.m_SelectBigInfo.MakeID)
                        end
                        MakeupController.SetFaceMakeupValue(table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_threeSelectIndex, "_0"}), nil)
                    else
                        MakeupController.SetFaceMakeupValue(table.concat({self.m_SelectBigInfo.PrimaryID, "_", self.m_threeSelectIndex, "_0"}), nil)
                    end
                    
                end
            end
        end
        -- self.m_RootView.m_SGUIObj:ChangeFace()
    else
        self.transform_rightInfo.gameObject:SetActive(true)  
        self:SetRightPosState()
        if not bIsHistory then
            -- 是否为肤色
            if self.m_DoubleSelectInfo.dressConfig and self.m_DoubleSelectInfo.dressConfig.PrimaryID == 1 then 
                local colorLuminance = string.split(self.m_DoubleSelectInfo.dressConfig.SkinColour,",")
                MakeupController.SetFaceMakeupValue(MakeUpDefine.MakeupEditType.Skin_RecommendColor, Color.New(tonumber(colorLuminance[1]), tonumber(colorLuminance[2]), tonumber(colorLuminance[3]))) 
            elseif self.m_DoubleSelectInfo.dressConfig then
                --双眼开启处理
                if self.m_DoubleSelectInfo.iEyeToggle == 1 then
                    for i = 1, 2 do
                        MakeupController.SetFaceMakeupValue(table.concat({self.m_DoubleSelectInfo.dressConfig.PrimaryID, "_", self.m_DoubleSelectInfo.dressConfig.SecondaryID, "_0","_",i}), self.m_DoubleSelectInfo.dressConfig.MakeID)
                    end
                else
                    MakeupController.SetFaceMakeupValue(table.concat({self.m_DoubleSelectInfo.dressConfig.PrimaryID, "_", self.m_DoubleSelectInfo.dressConfig.SecondaryID, "_0"}), self.m_DoubleSelectInfo.dressConfig.MakeID)
                end
            end
        end
    end
    MakeupController.RefreshModViewFace()

    self.m_PreDoubleSelectInfo = self.m_DoubleSelectInfo
end

function MakeUpSubView:SetZhuToggle()
    self.tab_toggle1.isOn = true
    self:OnClickToggle(1, true)
end

---珠粉页签
function MakeUpSubView:SetEyebrowToggle()
    self.eyebrow_toggle1.isOn = true
    self:OnClickEyebrowToggle(1, true)
end

function MakeUpSubView:SerEyeToggle()
    self.eye_toggle2.isOn = true
    self:OnClickEyebrowToggle(2, true)
end

---右边维度坐标状态
function MakeUpSubView:SetRightPosState()
    self.m_ZhuIndex = 0
    self.m_EyeIndex = 0
    self.m_EyebrowIndex = 0
    --珠粉页签
    self.transform_tab.gameObject:SetActive(self.m_DoubleSelectInfo.iToggle == 1)
    -- --双眼页签
    -- self.transform_eyetab.gameObject:SetActive(self.m_DoubleSelectInfo.iEyeToggle == 1)
    self.transform_eyetab.gameObject:SetActive(false)
    -- --眉毛页签
    self.transform_tab_eyebrow.gameObject:SetActive(self.m_DoubleSelectInfo.iEyebrowToggle == 1)
    -- --色盘
    -- self.btn_popColor.gameObject:SetActive(self.m_DoubleSelectInfo.iPopColor == 1)
    self.btn_popColor.gameObject:SetActive(false)
    self.btn_freeColor.gameObject:SetActive(self.m_DoubleSelectInfo.iFreeColor == 1)
    local colorlst = {}
    -- if self.m_DoubleSelectInfo.iPopColor == 1 then
    --     table.insert(colorlst,self.btn_popColor)
    -- end
    if self.m_DoubleSelectInfo.iFreeColor == 1 then
        table.insert(colorlst,self.btn_freeColor)
    end
    -- --色盘单行位置
    if #colorlst > 0 then
        self.transform_color.gameObject:SetActive(true)
    end
    self.m_LatitudeTypelst = self.m_DoubleSelectInfo.Latitude
    if self.m_DoubleSelectInfo.iToggle == 1 then
        if #colorlst > 0 then
            self.transform_color.transform.localPosition = ColorPos[1]
            self.transform_slider.transform.localPosition = SliderPos[1]
        else
            self.transform_color.gameObject:SetActive(false)
            self.transform_slider.localPosition = SliderPos[2]
        end
        self:SetZhuToggle()
    elseif self.m_DoubleSelectInfo.iEyebrowToggle == 1 then
        if #colorlst > 0 then
            self.transform_color.transform.localPosition = ColorPos[1]
            self.transform_slider.transform.localPosition = SliderPos[1]
        else
            self.transform_tab_eyebrow.gameObject:SetActive(false)
            self.transform_color.gameObject:SetActive(false)
            self.transform_slider.transform.localPosition = SliderPos[2]
        end
        self:SetEyebrowToggle()
    else
        --是否有 页签
        if self.m_DoubleSelectInfo.iEyeToggle == 1 then
            if #colorlst > 0 then
                self.transform_color.transform.localPosition = ColorPos[3]
                self.transform_slider.transform.localPosition = SliderPos[5]
            else
                self.transform_color.gameObject:SetActive(false)
                self.transform_slider.transform.localPosition = SliderPos[6]
            end
            self:SerEyeToggle()
        else
            if #colorlst > 0 then
                self.transform_color.transform.localPosition = ColorPos[2]
                self.transform_slider.transform.localPosition = SliderPos[3]
            else
                self.transform_color.gameObject:SetActive(false)
                self.transform_slider.transform.localPosition = SliderPos[4]
            end
        end

        SetSliderState(self)      
    end
    
end

function MakeUpSubView:OnClickEyebrowToggle(index, value)
    self.m_EyebrowIndex = index
    if self.m_EyebrowIndex == 1 then
        self.m_LatitudeTypelst = self.m_DoubleSelectInfo.eyebrowBGLatitude
    else
        self.m_LatitudeTypelst = self.m_DoubleSelectInfo.Latitude
    end
    SetSliderState(self)
end

function MakeUpSubView:OnClickToggle(index, value)
    self.m_ZhuIndex = index
    if self.m_ZhuIndex == 2 then
        self.m_LatitudeTypelst = self.m_DoubleSelectInfo.zhuFenLatitude
    else
        self.m_LatitudeTypelst = self.m_DoubleSelectInfo.Latitude
    end
    SetSliderState(self)
end

function MakeUpSubView:OnClickEyeToggle(index, value)
    --检测左眼与右眼数据是否不同
    if self.m_EyeIndex == 0 and iTabIndex == 3 then --每次第一次进来 默认双眼数据
        self.m_EyeIndex = index
        SetSliderState(self) 
    else
        self.m_EyeIndex = index
        SetSliderState(self)    
    end
end

--界面初始化
function MakeUpSubView:InitUI()

    local biglst, sublst, dressDic = MakeupController.model:GetMakeUpDic()
    self.m_DressInfolst = table.clone(biglst)
    self.m_dressDic = table.clone(dressDic)

    self.m_lstSliderInfo = {}
    for i=1, 5 do
        local makeUpSliderItem = MakeUpSliderItem.New()
        makeUpSliderItem:Init(self["item_bb" .. i].gameObject)
        makeUpSliderItem:InitUI(function (index, value)
            OnSliderValueChange(self, index, value)
        end, i)
        table.insert(self.m_lstSliderInfo, makeUpSliderItem)
    end

    -- 右边toggle
    for i=1, k_ToggleCount do
        local toggle = self["eyebrow_toggle" .. i]
        self:AddToggleOrSliderListener(toggle, function (isOn)
            self:OnClickEyebrowToggle(i, isOn)
        end)
    end

    -- 右边toggle
    for i=1, k_ToggleCount do
        local toggle = self["tab_toggle" .. i]
        self:AddToggleOrSliderListener(toggle, function (isOn)
            self:OnClickToggle(i, isOn)
        end)
    end

    -- 右边toggle
    for i=1, 3 do
        local toggle = self["eye_toggle" .. i]
        self:AddToggleOrSliderListener(toggle, function (isOn)
            self:OnClickEyeToggle(i, isOn)
        end)
    end

    self:AddButtonListener(self.btn_freeColor, function ()
        self.m_curEditType = GetCurEditType(self)
        local curEditType = table.concat({self.m_curEditType,"_2"})
        --双眼开启处理
        if self.m_DoubleSelectInfo.iEyeToggle == 1 then
            curEditType = table.concat({self.m_curEditType,"_2_1"})
        end
        local defaultColor =  MakeupController.model:GetFaceMakeupValue(curEditType, MakeupController.GetUIComponentFaceMakeUp())
        OpenColorPicker(self, defaultColor)
    end)

    self:AddButtonListener(self.btnCloseColorPicker, function ()
        self.btnCloseColorPicker.gameObject:SetActive(false)
        self.m_ColorPicker:SetActive(false)
    end)

	--大类型
    self.m_fnOnDressItemByIndex = function(loopGridView, itemIndex)
        return OnGetDressItemByIndex(self, loopGridView, itemIndex)
    end
    self.m_loopDressItemView = LoopListView2.New(self.lpGrid_makeup, self)
    self.m_loopDressItemView:InitListView(0, self.m_fnOnDressItemByIndex)
    self.m_loopDressItemView.IsParentSelect = true

    self.m_loopDressItemView:AddSelect(function(index, bItemClick)
        local itemModel = self.m_DressInfolst[index]
        RefeshDressItemInfo(self, itemModel, index, bItemClick)
    end)

    --子类型
    self.m_fnOnDressSubItemByIndex = function(loopGridView, itemIndex)
        return OnGetDressSubItemByIndex(self, loopGridView, itemIndex)
    end
    self.m_loopDressSubItemView = LoopListView2.New(self.lpGrid_subMakeup, self)
    self.m_loopDressSubItemView:InitListView(0, self.m_fnOnDressSubItemByIndex)
    self.m_loopDressSubItemView.IsParentSelect = true

    self.m_loopDressSubItemView:AddSelect(function(index,bItemClick)
        local itemModel = self.m_RefeshSublst[index]
        RefeshDressSubItemInfo(self, itemModel, index, bItemClick)
    end)

    SetDressLoopList(self)

end

--打开界面回调
function MakeUpSubView:OnOpen()
    MakeupController.StopFaceCustomizeMask()
end

--关闭界面回调
function MakeUpSubView:OnClose()
end

--销毁界面回调
function MakeUpSubView:OnDestroy()
end

return MakeUpSubView