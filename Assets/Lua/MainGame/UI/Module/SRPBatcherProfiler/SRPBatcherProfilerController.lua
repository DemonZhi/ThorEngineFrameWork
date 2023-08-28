SRPBatcherProfilerController = SRPBatcherProfilerController or {}
local k_SRPBatcherProfilerView = "SRPBatcherProfilerView"
--子类重新写
function SRPBatcherProfilerController.Init()
end

function SRPBatcherProfilerController.RegisterCommand()
end

function SRPBatcherProfilerController.OpenView()
	if not UIManager.IsActive(k_SRPBatcherProfilerView) then
        UIManager.OpenUI(k_SRPBatcherProfilerView)
    else
        UIManager.CloseUI(k_SRPBatcherProfilerView)
    end
end

function SRPBatcherProfilerController.CloseView()
	UIManager.CloseUI(k_SRPBatcherProfilerView)
end

return SRPBatcherProfilerController