WardrobeController = WardrobeController or {}
local k_WardrobeView = 'WardrobeView'

--子类重新写
function WardrobeController.Init()
end

function WardrobeController.RegisterCommand()
end


function WardrobeController.OpenView()
    UIManager.OpenUI(k_WardrobeView)
end

function WardrobeController.CloseView()
	UIManager.CloseUI(k_WardrobeView)
end

return WardrobeController
