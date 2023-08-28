local SelectRoleItem = class('SelectRoleItem', BaseItem)

function SelectRoleItem:InitUI()
    self:AddButtonListener(self.itemBtn, function ()
        if self.m_ItemData then
            self.m_ItemData.m_OwnerView:OnItemSelected(self.m_ItemData)
        end
    end)
end

function SelectRoleItem:OnGUI(itemData)
    self.m_ItemData = itemData
    self.labelRoleName.text = itemData.m_RoleInfo.name
    self.labelLevel.text = itemData.m_RoleInfo.level
    self.toggleItem.isOn = (itemData.m_Index == itemData.m_OwnerView:GetSelectedItemIndex())
end

return SelectRoleItem
