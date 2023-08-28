local defaultAlertData = 
{
	title = '提示',
	showLeftButton = true,
	content = '',
	onConfirmCallback = nil,
	onCancelCallback = nil,
	confirmLabel = '确定',
	cancelLabel = '取消'	,
	param = nil,
}

local AlertData = class("AlertData", defaultAlertData)

function AlertData:Ctor(options)
	options = options or {}

	local currentMeta = getmetatable(self)
	if currentMeta then 
		setmetatable(options, currentMeta)
	end
	options.__index = options
	setmetatable(self, options)
end

local AlertModel = class("AlertModel")

--子类重新写
function AlertModel:Init()
	self.m_CurrentAlertData = nil
	self.m_AlertDataList= {}
end

function AlertModel:AddAlertData(param)
	local alertData
	if type(param) == 'string' then 
		alertData = AlertData.New()
		alertData.content = param
	else
		alertData = AlertData.New(param)
	end

	table.insert(self.m_AlertDataList, alertData)
	self.m_CurrentAlertData = alertData
end

function AlertModel:RemoveAlertData()
	table.remove(self.m_AlertDataList, #self.m_AlertDataList)
	self.m_CurrentAlertData = self.m_AlertDataList[#self.m_AlertDataList]
end

function AlertModel:GetCurrentAlertData()
	return self.m_CurrentAlertData
end

function AlertModel:CleanAlertDataList()
	self.m_CurrentAlertData = {}
	self.m_CurrentAlertData = nil
end

return AlertModel