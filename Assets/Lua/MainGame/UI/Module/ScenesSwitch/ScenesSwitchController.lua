ScenesSwitchController = ScenesSwitchController or {}
local k_ScenesSwitchView = "ScenesSwitchView"
--子类重新写
function ScenesSwitchController.Init()
end

function ScenesSwitchController.RegisterCommand()
end

function ScenesSwitchController.OpenView()
    UIManager.OpenUI(k_ScenesSwitchView)
end

function ScenesSwitchController.CloseView()
    UIManager.CloseUI(k_ScenesSwitchView)
end

return ScenesSwitchController