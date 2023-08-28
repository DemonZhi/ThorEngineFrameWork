SettingController = SettingController or {}
local k_SettingView = "SettingView"
--子类重新写
function SettingController.Init()
end

function SettingController.RegisterCommand()
end

function SettingController.OpenView()
	UIManager.OpenUI(k_SettingView)
end

function SettingController.CloseView()
	UIManager.CloseUI(k_SettingView)
end

return SettingController