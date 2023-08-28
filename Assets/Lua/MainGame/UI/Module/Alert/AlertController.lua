AlertController = AlertController or {}
local k_AlertView = 'AlertView'
local k_TipsView = 'TipsView'

--子类重新写
function AlertController.Init()
end

function AlertController.RegisterCommand()
end

function AlertController.ShowAlert(param)
	AlertController.model:AddAlertData(param)
	AlertController.OpenView()
end

function AlertController.OpenView()
    UIManager.OpenUI(k_AlertView)
end

function AlertController.CloseView()
	UIManager.CloseUI(k_AlertView)
end

function AlertController.ShowTips(content)
	if UIManager.IsActive(k_TipsView) then
		UIManager.GetUI(k_TipsView):AddTips(content)
	else
		UIManager.OpenUI(k_TipsView, nil, nil, function()
			UIManager.GetUI(k_TipsView):AddTips(content)
		end)
	end
end

function AlertController.CloseTipsView()
	UIManager.CloseUI(k_TipsView)
end

return AlertController
