local CategoryItem = class('CategoryItem', BaseItem)

function CategoryItem:InitUI()
	self:AddButtonListener(self.btnCategory, function ()
		MakeupController.model:SetCategory(self.type)
        MakeupController.RefreshTypeView()	
	end)
end

function CategoryItem:OnGUI(itemData)
    self.txtCategory.text = itemData.desc
    self.type = itemData.type
end

return CategoryItem
