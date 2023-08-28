local BaseItem = class("BaseItem", BaseUI)
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")

function BaseItem:Init(index, go, scrollList)
	BaseItem.__super.Init(self, go)
	self.m_Index = index
	self.m_ScrollList = scrollList
	self:InitUIBinder()
	self:InitUI()
end

function BaseItem:Destroy()
	BaseItem.__super.Destroy(self)
	self:OnDestroy()
end

--[[
重新设置Index，因为go和index有可能重新分配到不同
]]
function BaseItem:SetIndex(index)
	self.m_Index = index
end

--子类重写
function BaseItem:InitUI()
end

--子类重写
function BaseItem:OnGUI(data)
end

--子类重写
function BaseItem:OnDestroy()
end

return BaseItem