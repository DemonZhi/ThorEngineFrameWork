local ServerInfoItem = class('ServerInfoItem', BaseItem)
 

function ServerInfoItem:InitUI()
    self:AddButtonListener(self.btnSelect, function ()
        if self.m_ItemData then
            AccountManager.SetCurrentServerInfo(self.m_ItemData)
            LoginController.CloseSelectServerPanel()
            LoginController.ShowEnterGamePanel()
        end
    end)
end

function ServerInfoItem:OnGUI(itemData)
    self.m_ItemData = itemData

    self.txtServerName.text = AccountManager.GetUIServerName(itemData)
end

return ServerInfoItem
