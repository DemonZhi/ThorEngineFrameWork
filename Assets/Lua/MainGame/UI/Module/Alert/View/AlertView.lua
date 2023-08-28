local AlertView = class("AlertView",BaseView)

local k_ConfirmPosX = 189
local k_ConfirmPosY = -173
local k_ConfirmPosz = 0
local k_ConfirmMiddlePosX = 0

--子类重写
function AlertView:InitUI()	
	self.m_Transform.offsetMin = Vector2.New(0, 0)
	self.m_Transform.offsetMax = Vector2.New(0, 0)

	self:AddButtonListener(self.btnConfirm, function ()
		self:OnClickButtonConfirm()
	end)

	self:AddButtonListener(self.btnCancel, function ()
		self:OnClickButtonCancel()
	end)
end

--子类重写
function AlertView:OnOpen()
	self:UpdateUI()
end

function AlertView:UpdateUI()
	local alertModel = AlertController.model
	local currentAlertData = alertModel:GetCurrentAlertData()

	self.txtTitle.text = currentAlertData.title
	self.txtConfirm.text = currentAlertData.confirmLabel
	self.txtContent.text = currentAlertData.content
	self.txtCancel.text = currentAlertData.cancelLabel

	self.btnCancel.gameObject:SetActive(currentAlertData.showLeftButton)
	if currentAlertData.showLeftButton then 
		Core_ForLuaUtility.SetLocalPosition(self.btnConfirm.gameObject, k_ConfirmPosX, k_ConfirmPosY, k_ConfirmPosz)
	else
		Core_ForLuaUtility.SetLocalPosition(self.btnConfirm.gameObject, k_ConfirmMiddlePosX, k_ConfirmPosY, k_ConfirmPosz)
	end
end

--子类重写
function AlertView:BeforeDestroy()
end

function AlertView:OnClickButtonConfirm()
	local alertModel = AlertController.model
	local currentAlertData = alertModel:GetCurrentAlertData()

	if currentAlertData.onConfirmCallback ~= nil then 
		currentAlertData.onConfirmCallback(currentAlertData.param)
	end

	self:CheckNextAlert()
end

function AlertView:OnClickButtonCancel()
	local alertModel = AlertController.model
	local currentAlertData = alertModel:GetCurrentAlertData()

	if currentAlertData.onCancelCallback ~= nil then 
		currentAlertData.onCancelCallback(currentAlertData.param)
	end

	self:CheckNextAlert()
end

function AlertView:CheckNextAlert()
	local alertModel = AlertController.model
	alertModel:RemoveAlertData()
	currentAlertData = alertModel:GetCurrentAlertData()
	if currentAlertData == nil then 
		self:Close()
	else
		self:UpdateUI()
	end
end

return AlertView