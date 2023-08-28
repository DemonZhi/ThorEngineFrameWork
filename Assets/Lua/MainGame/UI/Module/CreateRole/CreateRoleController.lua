CreateRoleController = CreateRoleController or {}
local k_CreateRoleView = 'CreateRoleView'
local k_SelectRoleView = 'SelectRoleView'

--子类重新写
function CreateRoleController.Init()
end

function CreateRoleController.RegisterCommand()
    -- body
end

function CreateRoleController.GetAllViewsName()
    return {k_CreateRoleView, k_SelectRoleView}
end

function CreateRoleController.OpenCreateRoleView(callBack)
    UIManager.OpenUI(k_CreateRoleView, nil, nil, callBack)
end

function CreateRoleController.GetCreateRoleView()
    return UIManager.GetUI(k_CreateRoleView)
end

function CreateRoleController.CloseCreateRoleView()
	UIManager.CloseUI(k_CreateRoleView)
end

function CreateRoleController.OpenSelectRoleView(callBack)
    UIManager.OpenUI(k_SelectRoleView, nil, nil, callBack)
end

function CreateRoleController.CloseSelectRoleView()
	UIManager.CloseUI(k_SelectRoleView)
end


function CreateRoleController.OnRandomName(name)
    if UIManager.IsActive(k_CreateRoleView) then
        UIManager.GetUI(k_CreateRoleView):SetRandomName(name)
    end
end

function CreateRoleController.OnPlayerListResult(result)
    -- CreateRoleController.m_Model:OnPlayerListResult(result)

    if UIManager.IsActive(k_SelectRoleView) then
        if #result.players > 0 then
            UIManager.GetUI(k_SelectRoleView):RefreshRoleList()
        else
            UIManager.CloseUI(k_SelectRoleView)
            UIManager.OpenUI(k_CreateRoleView)
        end
    end
end

return CreateRoleController
