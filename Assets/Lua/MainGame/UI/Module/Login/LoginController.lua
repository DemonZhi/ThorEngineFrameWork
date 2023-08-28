PlatformSDK = SGEngine.Core.PlatformSDK
local LoginMessage = require('MainGame/Message/LoginMessage')
local k_LoginView = 'LoginView'
local k_ModView = 'MODView'

LoginController = LoginController or {}

--子类重新写
function LoginController.Init()
end

function LoginController.RegisterCommand()
end

function LoginController.GetAllViewsName()
    return { k_LoginView, k_ModView }
end

function LoginController.OpenView(callback)
    UIManager.OpenUI(k_LoginView, nil, nil, callback)
end

function LoginController.ShowEnterGamePanel()
    local loginView = UIManager.GetUI(k_LoginView)
    if loginView ~= nil and loginView:IsActive() then
        loginView:ShowEnterGamePanel()
    end
end

function LoginController.CloseSelectServerPanel()
    local loginView = UIManager.GetUI(k_LoginView)
    if loginView ~= nil and loginView:IsActive() then
        loginView:CloseSelectServerPanel()
    end
end

function LoginController.Logout()
    LoginMessage.SendCloseConnectSession()
end

return LoginController
