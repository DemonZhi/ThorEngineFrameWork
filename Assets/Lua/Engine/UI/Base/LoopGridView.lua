--- @class LoopGridView
local LoopGridView = class("LoopGridView")

---@param view BaseView
---@param csLoopGridView SuperScrollView.LoopGridView
function LoopGridView:Ctor(csLoopGridView, view)
    self.m_csLoopGridView = csLoopGridView
    -- 用于释放SuperBaseItem
    ---@type SuperBaseItem[]
    self.lstLuaItem = {}  -- 拿到index 对应的 LuaClass
    self.selectIndexDic = {}    --选中状态
    self.selectList = {}    -- 选中列表 多选list List<int>
    self.IsParentSelect = false --是否为父节点点击
    self.maxSelectNum = 1
    if view then -- 注册生命周期事件到 view/subview 中
        view:AddBehaviour(self)
    end
    self.mView = view
end

function LoopGridView:GetItemClass(prefabName,itemClass,index)
    local listItem = nil
    listItem = self.m_csLoopGridView:NewListViewItem(prefabName)
    local item = listItem.UserObjectData
    local mIndex = index + 1
    if item == nil then
        item = itemClass.New()
        item:InitListData(self, mIndex, listItem)
        listItem.UserObjectData = item
        table.insert(self.lstLuaItem, item)
    end    
    item:RefreshIndex(mIndex)
    local bValueShow = false
    if self:IsSelected(mIndex) then
        bValueShow = true
    end
    if self.IsParentSelect then
        item:AddClick(function() self:OnItemClick(mIndex) end)
    end
    item:OnSelected(bValueShow)
    if self.reflushCallBack ~= nil then
        self.reflushCallBack(mIndex)
    end
    return item
end

--- 初使化list
--- @param itemTotalCount System.Int32 显示数量
--- @param fnGetItemByIndex function(LoopGridView,int,int,int, LoopGridViewItem) 回调 
function LoopGridView:InitListView(itemTotalCount, fnGetItemByIndex)
    self.m_csLoopGridView:InitGridView(itemTotalCount, fnGetItemByIndex)
end

---移动到指定位置
---@param iItemIndex System.Int32 移动到第几行(从1开始)
---@param fOffsetX number x轴偏移
---@param fOffsetY number y轴偏移
---@param isAnim boolean 是否使用动画
function LoopGridView:MovePanelToItemIndex(iItemIndex, fOffsetX, fOffsetY,isAnim)
    local iMoveIndex = iItemIndex - 1
    self.m_csLoopGridView:MovePanelToItemByIndex(iMoveIndex, fOffsetX, fOffsetY,isAnim)
end

-- 通过lua直接刷新
---@param iItemIndex number 1开始
---@param data any
function LoopGridView:RefreshItemByItemLuaIndex(iItemIndex, data)  
    local item = self:GetLuaItemByLuaIndex(iItemIndex)
    if item then
        item:OnGUI(data)
    end
end

-- 获取luaItem
---@param iItemIndex number 从1开始
---@return SuperBaseItem
function LoopGridView:GetLuaItemByLuaIndex(iItemIndex)
    local csItem = self:GetShownItemByItemIndex(iItemIndex)
    if LuaUtil.IsNil(csItem) then
        return nil
    end
    return csItem.UserObjectData
end

--- 刷新指定索引的Data
function LoopGridView:RefreshItemByItemIndex(iItemIndex)
    self.m_csLoopGridView:RefreshItemByItemIndex(iItemIndex)
end

-- 获取cslooplistItem
---@param iItemIndex number 从1开始
---@return SuperScrollView.LoopGridViewItem
function LoopGridView:GetShownItemByItemIndex(iItemIndex)
    return self.m_csLoopGridView:GetShownItemByItemIndex(iItemIndex - 1)
end

--- 设置GridCount
--- @param iItemCount number 数量
--- @param bResetPos boolean 重设位置
function LoopGridView:SetListItemCount(iItemCount, bResetPos, bForceRefresh)
    self.m_csLoopGridView:SetListItemCount(iItemCount, bResetPos, bForceRefresh)
end

--- 全部刷新
function LoopGridView:RefreshAllShownItem()
    self.m_csLoopGridView:RefreshAllShownItem()
end

---获取元预制体
function LoopGridView:GetItemPrefab(index)
    return self.m_csLoopGridView:GetItemPrefab(index)
end

------------ 【 外部方法 】
-- 设置单选
-- isRresh 是否强制刷新 
-- index 等于 当前选中的 index的时候 会不处理， 如果需要刷新则为true
---@param bItemClick boolean 是主动点击触发 还是调用的SetSelect的点击触发
function LoopGridView:SetSelect(index, isRresh, bItemClick)
    local curIndex = self:GetSelectIndex()
    if curIndex ~= nil or isRresh then
        local tab = {}
        table.insert(tab, index)
        self:SetSelectList(tab, bItemClick)         -- 从多选调用业务逻辑
    end
end

-- 设置多选
function LoopGridView:SetSelectList(table, bItemClick)    --table is List<int> by LuaTable
    -- 清除选中
    for _, selectIndex in ipairs(self.selectList) do
        self:SetItemSelect(selectIndex,false,false)
    end
    -- 更新选中
    self.selectList = table
    -- 设置选中
    for _, selectIndex in ipairs(self.selectList) do
        self:SetItemSelect(selectIndex,true,bItemClick)
    end
end

-- 添加选中状态回调
function LoopGridView:AddSelect(callback)
    self.selectCallBack = callback
end

-- 添加取消选中的回调
function LoopGridView:AddDeSelect(callback)
    self.deSelectCallBack = callback
end

-- 当item隐藏or显示的时候 会回调
function LoopGridView:AddItemReflush(callback)
    self.reflushCallBack = callback
end

-- 清除所有选中
function LoopGridView:ClearSelect()
    if #self.selectList == 0 then
        return
    end
    for _, index in ipairs(self.selectList) do
        self:SetItemSelect(index,false)
    end
    self.selectList = {}
end

-- 拿到所有选中列表
function LoopGridView:GetSelectList()
    return self.selectList
end


------------ 【 内部方法 】
function LoopGridView:OnItemClick(mIndex)
    if self:IsSelected(mIndex) then
        if self.maxSelectNum == 1 then
            self:SetItemSelect(mIndex,true,true)
        else
            self:DeSelect(mIndex)
        end
    else
        self:AppendSelect(mIndex,true)
    end
end

function LoopGridView:DeSelect(index)
    if self:IsSelected(index) then
        self:RemoveSelectList(index)
        self:SetItemSelect(index,false)
    end
end

function LoopGridView:RemoveSelectList(nSelectIndex)
    local index = self:GetIndexFromSelectList(nSelectIndex)
    if index ~= -1 then
        table.remove(self.selectList, index)
    end
end

function LoopGridView:GetIndexFromSelectList(nSelectIndex)
    for key, value in ipairs(self.selectList) do
        if value == nSelectIndex then
            return key
        end
    end
    return -1
end

-- 添加选中
function LoopGridView:AppendSelect(index,bItemClick)
    if self.maxSelectNum == 1 then  --单选
        self:SetSelect(index,false, bItemClick)
    else
        table.insert(self.selectList,index)
        self:SetItemSelect(index,true,bItemClick)
    end
end

-- 对某个item设置选中状态
---@param bItemClick boolean 是主动点击触发 还是调用的SetSelect的点击触发
function LoopGridView:SetItemSelect(index , bValue, bItemClick)
    self.selectIndexDic[index] = bValue
    local baseItem = self:GetLuaItemByLuaIndex(index)
    if baseItem then        
        baseItem:OnSelected(bValue)
    end
    if bValue and self.selectCallBack ~= nil then
        self.selectCallBack(index, bItemClick)
    elseif not bValue and self.deSelectCallBack ~= nil then
        self.deSelectCallBack(index)
    end
end

-- 是否选中
function LoopGridView:IsSelected(index)
    return self.selectIndexDic[index]
end

-- 获得当前选中index
function LoopGridView:GetSelectIndex()
    if self.selectList[1] ~= nil then
        return self.selectList[1]
    end
    return -1
end

-- 获取luaItem
---@param index number
---@return SuperBaseItem
function LoopGridView:GetItemInfo(index)
    return self:GetLuaItemByLuaIndex(index)
end

function LoopGridView:Clear()
    self.selectIndexDic = {}
    self.m_csLoopGridView:SetListItemCount(0, false, false)
end

--------------------- 生命周期事件 ---------------------

function LoopGridView:OnClose()
    for _, value in ipairs(self.lstLuaItem) do
        if value then
            value:Close()
        end
    end
end

function LoopGridView:OnDestroy()
    for _, value in ipairs(self.lstLuaItem) do
        if value then
            value:Destroy()
        end
    end
    self.lstLuaItem = nil
    self.m_csLoopGridView:ResetLoopView()
    self.m_csLoopGridView = nil
end

--------------------------------------------------------

return LoopGridView