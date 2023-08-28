local SubpartItem = class('SubpartItem', BaseItem)
local k_ItemIconAtlasName = "ItemIconAtlas"

function SubpartItem:InitUI()
	self:AddButtonListener(self.itemBtn, function ()
		if self.m_ItemData then
            self.m_ItemData.m_OwnerView:OnClickSubpartItem(self)
        end
	end)
end

function SubpartItem:OnGUI(itemData)
    self.m_ItemData = itemData
    self:SetImageSprite(self.iconImg, k_ItemIconAtlasName, itemData.m_ConfigItem.IconName)
end

return SubpartItem
