GMController = GMController or {}
local k_GMView = 'GMView'

--子类重新写
function GMController.Init()
end

function GMController.RegisterCommand()
	-- body
end

function GMController.OpenGMView()
    if not UIManager.IsActive(k_GMView) then
        UIManager.OpenUI(k_GMView)
    else
        UIManager.CloseUI(k_GMView)
    end
end

return GMController
