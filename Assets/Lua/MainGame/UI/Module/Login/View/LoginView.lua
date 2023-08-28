local LoginView = class('LoginView', BaseView)
local ServerInfoItem = require('MainGame/UI/Module/Login/View/Item/ServerInfoItem')
 

--子类重写
function LoginView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self.m_ServerList = ScrollList.New(self.serverList, ServerInfoItem)
    self:AddButtonListener(self.btnLogin, function ()
        if string.IsNullOrEmpty(self.inputFieldAccountName.text) then
            AlertController.ShowTips('用户名为空！')
            return
        end

        local lastAccountName = AccountManager.GetLastAccountName()
        if self.inputFieldAccountName.text ~= lastAccountName then
            AccountManager.SetLastAccountName(self.inputFieldAccountName.text)
        end
        ProcedureLogin.SDKLogin(self.inputFieldAccountName.text, self.m_UIBinder)
    end)

    self:AddButtonListener(self.btnEnterGame, function ()
          ProcedureLogin.Login()
    end)

    self:AddButtonListener(self.btnPinchFace, function ()
        MakeupController.OpenMODView()
    end)

    self:AddButtonListener(self.btnChangedServer, function ()
        self:ShowSelectServerPanel()
    end)

    self:AddButtonListener(self.btnCloseSelectServerPanel, function ()
        self:CloseSelectServerPanel()
    end)

    local lastAccountName = AccountManager.GetLastAccountName()
    if not string.IsNullOrEmpty(lastAccountName) then
        self.inputFieldAccountName.text = lastAccountName
    end
end

function LoginView:OnOpen()
    self:ShowLoginSDKPanel()
end

function LoginView:ShowEnterGamePanel()
    self.imgInputBg.gameObject:SetActive(false)
    self.imgEnterGamePanel.gameObject:SetActive(true)
    self.imgSelectServerPanel.gameObject:SetActive(false)

    self:UpdateEnterGamePanel()
end

function LoginView:ShowLoginSDKPanel()
    self.imgInputBg.gameObject:SetActive(true)
    self.imgEnterGamePanel.gameObject:SetActive(false)
end

function LoginView:ShowSelectServerPanel()
    self.imgSelectServerPanel.gameObject:SetActive(true)
    self:UpdateSelectServerPanel()
end

function LoginView:CloseSelectServerPanel()
    self.imgSelectServerPanel.gameObject:SetActive(false)
end

function LoginView:UpdateSelectServerPanel()
    local serverInfos = AccountManager.GetSortServerInfos()
    self.m_ServerList:SetLuaData(serverInfos)
end

function LoginView:UpdateEnterGamePanel()
    local currentServerInfo = AccountManager.GetCurrentServerInfo()
    self.txtCurrentServerName.text = AccountManager.GetUIServerName(currentServerInfo)
end

return LoginView
