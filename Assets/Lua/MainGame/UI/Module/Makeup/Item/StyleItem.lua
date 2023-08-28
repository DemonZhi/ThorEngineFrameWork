local StyleItem = class('StyleItem', BaseItem)

function StyleItem:InitUI()
	self:AddButtonListener(self.btnStyle, function ()
		MakeupController.RefreshSliderView(self.data)
	end)
end

function StyleItem:OnGUI(itemData)
    self.txtStyle.text = itemData.desc
    self.data = itemData.data
end

return StyleItem