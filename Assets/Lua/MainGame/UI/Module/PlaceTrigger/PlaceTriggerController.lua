
---@class PlaceTriggerController:BaseCtrl
PlaceTriggerController = PlaceTriggerController or {}
local k_PlaceTriggerView = "PlaceTriggerView"
local GmMessage = require("MainGame/Message/GmMessage")
--初始化
function PlaceTriggerController.Init()
end

--注册事件
function PlaceTriggerController.RegisterCommand()
end

function PlaceTriggerController.OpenPlaceTriggerView()
	UIManager.OpenUI(k_PlaceTriggerView)
end

function PlaceTriggerController.PlaceTrgger(posX, posY, posZ, angle, timeout)
	GmMessage.SendGmCommand("add_trigger", string.format("%f %f %f %f %d", posX, posY, posZ, angle, 60))
end

return PlaceTriggerController