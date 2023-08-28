local TypeItem = class('TypeItem', BaseItem)

function TypeItem:InitUI()
    self:AddButtonListener(self.btnType, function ()
        if MakeupController.model:GetCategory() == 'pinch' then
            MakeupController.RefreshStyleView(self.index)
        elseif MakeupController.model:GetCategory() == 'makeup' then
            MakeupController.RefreshGridView(self.index)
        end
    end)
end

function TypeItem:OnGUI(itemData)
    self.txtType.text = itemData.desc
    self.index = itemData.index
end

return TypeItem