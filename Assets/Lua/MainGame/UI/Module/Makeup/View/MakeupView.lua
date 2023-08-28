local MakeupView = class('MakeupView', BaseView)
local CategoryItem = require('MainGame/UI/Module/Makeup/Item/CategoryItem')
local TypeItem = require('MainGame/UI/Module/Makeup/Item/TypeItem')
local StyleItem = require('MainGame/UI/Module/Makeup/Item/StyleItem')
local GridItem = require('MainGame/UI/Module/Makeup/Item/GridItem')
local SliderItem = require('MainGame/UI/Module/Makeup/Item/SliderItem')
local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local CreateRoleMessage = require("MainGame/Message/CreateRoleMessage")
 

function MakeupView:InitUI()
    --这是个潜规则。。。
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self:AddButtonListener(self.btnClose, function ()
        MakeupController.UnFocusModel()
        MakeupController.CloseView()
        CreateRoleController.OpenCreateRoleView()
    end)

    self.m_CategoryScrollList = ScrollList.New(self.categoryScrollList, CategoryItem)
    self.m_TypeScrollList = ScrollList.New(self.typeScrollList,  TypeItem)
    self.m_StyleScrollList = ScrollList.New(self.styleScrollList, StyleItem)
    self.m_StyleScrollList:SetActive(false)
    self.m_GridScrollList = ScrollList.New(self.gridScrollList, GridItem)
    self.m_GridScrollList:SetActive(false)
    self.m_SliderScrollList = ScrollList.New(self.sliderScrollList, SliderItem)
    self.m_SliderScrollList:SetActive(false)

    self:AddButtonListener(self.btnDay, function ()
        
    end)

    self:AddButtonListener(self.btnNight, function ()
        
    end)

    self:AddButtonListener(self.btnPM, function ()
        
    end)

    self:AddButtonListener(self.btnEnter, function ()
        local name = self.inputFieldName.text
        if self:CheckPlayerName(name) then
            local accountData = AccountManager.GetAccountData()
            local slot = CreateRoleController.model:GetFirstEmptyCreateSlot()
            local faceBlendshapeList = MakeupController.GetFaceBlendShapeList()
            local faceTextureIndexList = MakeupController.GetFaceTextureIndexList()
            local gender = MakeupController.GetGender()
            local roleJobID = MakeupController.GetRoleJobID()
            CreateRoleMessage.SendCreatePlayer(accountData.accountId, roleJobID, name, slot, gender, faceBlendshapeList, faceTextureIndexList)
        end
    end)

    self:AddButtonListener(self.btnRandom, function ()
        CreateRoleMessage.SendGetRandomName(MakeupController.model.GetGender())
    end)
end

function MakeupView:OnOpen()
    self.m_CategoryScrollList:SetLuaData(MakeupController.model:GetCategoryData())
    self.m_TypeScrollList:SetLuaData(MakeupController.model:GetPinchList())
    --self.m_SliderScrollList:SetLuaData(MakeupController.model:GetSliderData())

    if ProcedureCreateRole then
        local componentFaceMakeup = ProcedureCreateRole.m_ComponentFaceMakeup
        if componentFaceMakeup then
            componentFaceMakeup:ResetFace()
        end
    end

    MakeupController.FocusModel()
end

function MakeupView:OnClose()
    
end

function MakeupView:RefreshTypeView()
    if MakeupController.model:GetCategory() == 'pinch' then
        self.m_TypeScrollList:SetLuaData(MakeupController.model:GetPinchList())
        --self.m_StyleScrollList:SetActive(true)
        --self.m_StyleScrollList:SetLuaData(MakeupController.model:GetStyleData(1))
    elseif MakeupController.model:GetCategory() == 'makeup' then
        self.m_TypeScrollList:SetLuaData(MakeupController.model:GetMakeupList())
        --self.m_GridScrollList:SetLuaData(MakeupController.model:GetStyleData(1))
    end
    self.m_StyleScrollList:SetActive(false)
    self.m_GridScrollList:SetActive(false)
    self.m_SliderScrollList:SetActive(false)
end

function MakeupView:RefreshStyleView(index)
    local data = MakeupController.model:GetStyleData(index)
    self.m_StyleScrollList:SetActive(true)
    self.m_GridScrollList:SetActive(false)
    self.m_SliderScrollList:SetActive(false)
    self.m_StyleScrollList:SetLuaData(data)
end

function MakeupView:RefreshGridView(index)
    local data = MakeupController.model:GetGridData(index)
    self.m_GridScrollList:SetActive(true)
    self.m_StyleScrollList:SetActive(false)
    self.m_GridScrollList:SetLuaData(data.image)

    self.m_SliderScrollList:SetActive(true)
    self:RefreshSliderView(data.data)
end

function MakeupView:RefreshSliderView(data)
    self.m_SliderScrollList:SetActive(true)
    self.m_SliderScrollList:SetLuaData(data)
end

function MakeupView:CheckPlayerName(name)
    if string.IsNullOrEmpty(name) then
        AlertController.ShowTips("名字不能为空")
        return false
    end

    local k = 1
    local len = #name
    local haveSpecialChar = false
    local allAreNumbers = true
    while true do
        if k > len then
            break
        end

        local c = string.byte(name, k)
        if c < 48 or c > 57 then
            allAreNumbers = false
        end

        if c < 192 then
            if c < 48 or (c > 57 and c < 65) or (c > 90 and c < 97) or c > 122 then
                haveSpecialChar = true
                break
            end
            k = k + 1
        elseif c >= 224 and c < 240 then
            local c1 = string.byte(name, k + 1)
            local c2 = string.byte(name, k + 2)
            local unic = (c % 0xe0) * 2 ^ 12 + (c1 % 0x80) * 2 ^ 6 + (c2 % 0x80)
            if unic < 0x4e00 and unic > 0x9FA5 then
                haveSpecialChar = true
                break
            end
            k = k + 3
        else
            haveSpecialChar = true
            break
        end
    end

    if haveSpecialChar then
        AlertController.ShowTips("名字不允许有特殊字符")
        return false
    end

    if allAreNumbers then
        AlertController.ShowTips("名字不能全部为数字")
        return false
    end

    return true
end

return MakeupView