---@class SuperBaseItem:BaseUI
local SuperBaseItem = class("SuperBaseItem", BaseUI)

function SuperBaseItem:InitListData(owner, mIndex,listItem)
    SuperBaseItem.__super.Init(self, listItem.gameObject)
    self.owner = owner
    self.listItem = listItem
    self.itemIndex = mIndex
    self.selectCallBack = nil
    self.bDestroy = false
    self:InitUIBinder()
    self:InitUI()
    self:AfterInit()
end

function SuperBaseItem:AfterInit()
    self:AddSelect(function(bValue)
        self:OnSelect(bValue)
    end)
end

------------ 【 子类重写 】
--子类重写
function SuperBaseItem:InitUI()
end

--子类重写
function SuperBaseItem:OnGUI(data)
end

--子类重写
function SuperBaseItem:OnDestroy()
end

function SuperBaseItem:OnClose()

end

function SuperBaseItem:OnSelect(bValue)

end

------------ 【 外部方法 】
-- 添加选中
function SuperBaseItem:AddSelect(callback)
    self.selectCallBack = callback
end

-- 添加点击事件
function SuperBaseItem:AddItemClick(callBack)
    self.listItem:AddClick(function(eventData)
        callBack(eventData)
    end)
end

-- 显示隐藏
function SuperBaseItem:SetActive(bValue)
    LuaUtil.SetCompObjActive(self.listItem, bValue)
end

------------ 【 内部方法 】

--------------------- C#本身的生命周期事件 ---------------------

-- 一般只提供父层级调用 不提供外部方法 外部请用 AddSelect
function SuperBaseItem:AddClick(callBack)
    self.listItem:AddClick(function()
        callBack() 
    end)
end

function SuperBaseItem:AddEnable(callBack)
    self.listItem:AddEnable(function()
        callBack() 
    end)
end

function SuperBaseItem:AddDisable(callBack)
    self.listItem:AddDisable(function()
        callBack() 
    end)
end

function SuperBaseItem:AddDestroy(callBack)
    self.listItem:AddDestroy(function()
        callBack() 
    end)
end

--------------------- 依赖于外部调用的生命周期事件 ---------------------

function SuperBaseItem:Destroy()
    self.bDestroy = true
    self:OnDestroy()
	self.selectCallBack = nil
    SuperBaseItem.__super.Destroy(self)
end

function SuperBaseItem:Close()
    self:OnClose()
end

----------------------------------------------------------------------

-- 【 内部方法 】
function SuperBaseItem:OnSelected(bValue)
    if self.selectCallBack ~= nil then
        self.selectCallBack(bValue)
    end
end

function SuperBaseItem:RefreshIndex(index)
	self.itemIndex = index
end

return SuperBaseItem