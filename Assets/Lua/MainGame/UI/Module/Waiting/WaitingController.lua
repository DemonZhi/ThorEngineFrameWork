WaitingController = WaitingController or {}
local k_WaitingView = 'WaitingView'

--子类重新写
function WaitingController.Init()
end

function WaitingController.RegisterCommand()
end

function WaitingController.OpenWaitingView(isCanCloseFunction)
	WaitingController.model:AddWaitingData(isCanCloseFunction)
    UIManager.OpenUI(k_WaitingView)
end

-- function WaitingController.CloseWaitingView()
-- 	UIManager.CloseUI(k_WaitingView)
-- end

return WaitingController
