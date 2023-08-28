local ScrollList = class("ScrollList")

function ScrollList:Ctor(transform, itemClass)
	self.m_List = transform:GetComponent("UIScrollList")
	self.m_List.onUpdateItem = function (index, go, itemData)
		self:OnUpdateItem(index, go, itemData)
	end
	self.m_ItemDictionary = {}
	self.m_ItemClass = itemClass
	self.m_Transform = transform
	self.m_GameObjec = transform.gameObject
end

function ScrollList:SetLuaData(luaData)
	self.m_List.LuaData = luaData
end

function ScrollList:SetRefreshCallback(refreshCallback)
	self.m_List.onRefresh = refreshCallback
end

function ScrollList:SetUpdatePositionCallback(updatePositionCallback)
	self.m_List.onUpdatePostion = updatePositionCallback
end

function ScrollList:UpdateCurView()
	self.m_List:UpdateCurView()
end

function ScrollList:OnUpdateItem(index, go, itemData)
	local item = self.m_ItemDictionary[go]
	if item == nil then
		item = self.m_ItemClass.New()
		item:Init(index, go, self)
		self.m_ItemDictionary[go] = item
	end
	if item.m_Index ~= index then
		item:SetIndex(index)
	end
	item:OnGUI(itemData)
end

function ScrollList:SetActive(value)
	self.m_GameObjec:SetActive(value)
end

function ScrollList:Destroy()
	for key, item in pairs(self.m_ItemDictionary) do
		item:Destroy()
	end
	self.m_ItemDictionary = nil
end

function ScrollList:DoRefresh( ... )
	self.m_List:Refresh()
end

function ScrollList:SetItemHeight( index, height )
	self.m_List:SetItemHeight(index, height)
end

return ScrollList