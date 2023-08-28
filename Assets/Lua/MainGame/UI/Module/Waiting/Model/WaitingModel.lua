local defaultWaitingData = 
{
	title = '请稍候',
	isCanCloseFunction = nil,
	content = '',
}

local WaitingData = class("WaitingData", defaultWaitingData)

function WaitingData:Ctor(options)
	options = options or {}

	local currentMeta = getmetatable(self)
	if currentMeta then 
		setmetatable(options, currentMeta)
	end
	options.__index = options
	setmetatable(self, options)
end

local WaitingModel = class("WaitingModel")

--子类重新写
function WaitingModel:Init()
	self.m_WaitingDataList = {}
end

function WaitingModel:IsCanCloseWaitingView()
	if #self.m_WaitingDataList < 1 then
		return true
	end

	for i=#self.m_WaitingDataList, 1, -1 do
		local waitingData = self.m_WaitingDataList[i]
		local isCanClose = waitingData.isCanCloseFunction()
		if not isCanClose then 
			return false
		else
			table.remove(self.m_WaitingDataList,i)
		end
	end

	return true
end

function WaitingModel:AddWaitingData(param)
	local waitingData
	if type(param) == 'function' then 
		waitingData = WaitingData.New()
		waitingData.isCanCloseFunction = param
	else
		waitingData = WaitingData.New(param)
	end

	table.insert(self.m_WaitingDataList, waitingData)
end

return WaitingModel