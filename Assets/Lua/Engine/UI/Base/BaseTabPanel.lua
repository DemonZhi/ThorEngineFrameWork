local Core_UIManager = SGEngine.UI.UIManager

local BaseTabPanel = class("BaseTabPanel",  BaseView)

local k_DefaultViewIndex = 1
local k_ViewIndex = 1
local k_SubViewIndex = 2

local k_ToggleIndex = 1
local k_ClassIndex = 2
local k_AbKeyIndex = 3
local k_Params = 3
--[[
{self.toggle, subView, assetKey}
]]
--初始化页签
function BaseTabPanel:InitTab(tabConfig)
	self.m_CurView = nil--当前打开的界面
	self.m_SubViews = {}--所有子界面
	self.m_CurTabIndex = -1
	self.m_TabConfig = tabConfig
	for i, v in ipairs(tabConfig) do
		local toggle = v[k_ToggleIndex]
		self:AddToggleOrSliderListener(toggle, function (isOn)
			if isOn then 
				if i ~= self.m_CurTabIndex then 
					self.m_CurTabIndex = i
					self:OnClickToggle(i, toggle)
					self:CloseCurView()
					self:ShowView(i)
				end
			end
		end)
	end
end

function BaseTabPanel:InitTabWithGameObject(tabConfig)
	for index, config in ipairs(tabConfig) do
		local class = config[k_ClassIndex]
		local go = config[k_AbKeyIndex]
		local ui = class.New()
		ui:LoadUICallback(go)
		self.m_SubViews[index] = ui
	end
end

--打开界面
function BaseTabPanel:Open(...)
	UIManager.RegisterActiveView(self)
	local arg = {...}
	local index = arg[k_ViewIndex] or k_DefaultViewIndex--界面下标
	local subIndex = arg[k_SubViewIndex]--子界面下标
	local params = arg[k_Params]

	self:BeforeOpen(params)
	self.m_GameObject:SetActive(true)
	self.m_Transform:SetAsLastSibling()

	--关闭当前子界面
	self:CloseCurView()
	--全部设置为off
	for i, v in ipairs(self.m_TabConfig) do
		if i ~= index then 
			v[k_ToggleIndex]:SetIsOnWithoutNotify(false) 
		end
	end
	--设置toggle并且打开界面
	local config = self.m_TabConfig[index]
	if config[k_ToggleIndex] then
		self.m_CurTabIndex = index
		config[k_ToggleIndex]:SetIsOnWithoutNotify(true) 
		self:OnClickToggle(index, config[k_ToggleIndex])
		--打开子界面
		self:ShowView(index, subIndex)
	end

	self:PlayAllTween()
	self:OnOpen(params)
	UIManager.CheckAllCameraVisible()
end

--关闭界面
function BaseTabPanel:Close()
	UIManager.UnRegisterActiveView(self)
	self:BeforeClose()
	self.m_GameObject:SetActive(false)
	self:CloseCurView()
	self:OnClose()
	UIManager.CheckAllCameraVisible()
end

--关闭当前子界面
function BaseTabPanel:CloseCurView()
	if self.m_CurView and self.m_CurView:IsActive() then 
		self.m_CurView:Close()
	end
end

--展示子界面
function BaseTabPanel:ShowView(index, subIndex)	
	--打开子界面
	if self.m_SubViews[index] then 
		self.m_SubViews[index]:Open(subIndex)
		self.m_CurView = self.m_SubViews[index]
	else
		local config = self.m_TabConfig[index]
		if config == nil then 
			Logger.LogErrorFormat("子界面{0}没有配置", index)
			return 
		end
		ResourceManager.InstantiateAsync(config[k_AbKeyIndex], function (go)
			local class = config[k_ClassIndex]
			local ui = class.New()
			go.transform:SetParent(self.m_Transform)
			ui:LoadUICallback(go)
			self.m_SubViews[index] = ui
			self.m_CurView = self.m_SubViews[index]
			--在检查一次toggle，防止toggle改变
			if self.m_TabConfig[index][k_ToggleIndex].isOn then 
				ui:Open(subIndex)
			else
				ui:Close()
			end
		end)
	end
end

--销毁
function BaseTabPanel:Destroy()
	self:BeforeDestroy()
	for index=1, #self.m_TabConfig do
		if self.m_SubViews[index] then 
			self.m_SubViews[index]:Destroy()
			self.m_SubViews[index] = nil
		end 
	end
	self:KillAllTween()
	ResourceManager.ReleaseInstance(self.m_GameObject)
	self:OnDestroy()
	UIManager.CheckAllCameraVisible()
end

--子类重写
function BaseTabPanel:OnClickToggle(index, toggle)
end

return BaseTabPanel