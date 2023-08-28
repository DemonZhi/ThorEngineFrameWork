OperateController = OperateController or {}
local k_OpView = 'OpView'
--初始化
function OperateController.Init()
end

--注册事件
function OperateController.RegisterCommand()
end

function OperateController.UpdateObjDebugInfo(clientPx, clientPy, clientPz, serverPx, serverPy, serverPz, clientHeight, serverHeight)
    local opView = UIManager.GetUI(k_OpView)
    if opView ~= nil and opView:IsActive() then
        opView:UpdateObjPanelText(clientPx, clientPy, clientPz, serverPx, serverPy, serverPz, clientHeight, serverHeight)
    end
end

return OperateController