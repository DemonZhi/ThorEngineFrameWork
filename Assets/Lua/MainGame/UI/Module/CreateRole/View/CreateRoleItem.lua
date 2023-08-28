local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local CreateRoleItem = class('CreateRoleItem', BaseItem)

function CreateRoleItem:InitUI()
    self:AddButtonListener(self.itemBtn, function ()
        if self.m_ItemData then
            self.m_ItemData.ownerView:OnItemSelected(self.m_ItemData)
        end
    end)

    self:AddToggleOrSliderListener(self.toggleMale, function(isOn)
        if isOn then 
            self.m_ItemData.ownerView:OnGenderSelected(GenderTypeEnum.Male)
        end
    end)

    self:AddToggleOrSliderListener(self.toggleFemale, function (isOn)
        if isOn then 
            self.m_ItemData.ownerView:OnGenderSelected(GenderTypeEnum.Female)
        end
    end)
end

function CreateRoleItem:OnGUI(itemData)
    self.m_ItemData = itemData
    self.labelRoleName.text = itemData.name
    local isSelected = (itemData.index == itemData.ownerView:GetSelectedItemIndex())
    self.toggleItem.isOn = isSelected
    self.transformGender.gameObject:SetActive(isSelected)

    if isSelected then
        local selectedGender = itemData.ownerView:GetSelectedGender()
        if selectedGender == GenderTypeEnum.Male then
            self.toggleMale.isOn = true
        else
            self.toggleFemale.isOn = true
        end
    end
end

return CreateRoleItem
