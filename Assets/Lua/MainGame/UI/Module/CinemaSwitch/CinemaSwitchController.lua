CinemaSwitchController = CinemaSwitchController or {}
local k_CinemaSwitchView = "CinemaSwitchView"
--子类重新写
function CinemaSwitchController.Init()
end

function CinemaSwitchController.RegisterCommand()
end

function CinemaSwitchController.OpenView()
    UIManager.OpenUI(k_CinemaSwitchView)
end

function CinemaSwitchController.CloseView()
    UIManager.CloseUI(k_CinemaSwitchView)
end

return CinemaSwitchController