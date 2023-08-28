local GMItem = class('GMItem', BaseItem)

function GMItem:InitUI()
    self.m_BtnName = self:GetChildComponent('btn/txtName', 'Text')
    self.m_inputField = self:GetChildComponent('InputField', 'InputField')
end

function GMItem:OnGUI(itemData)
    self.m_Data = itemData
    self.btn.onClick:RemoveAllListeners()
    self:AddButtonListener(self.btn, function ()
        self.m_Data.func(self.m_inputField.text)
    end)
    self.m_BtnName.text = self.m_Data.name
    if self.m_Data.OpenCallBack then
        self.m_Data.OpenCallBack(self)
    end
end

return GMItem
