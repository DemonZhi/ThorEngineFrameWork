---@class LoopListView2
local _M = class("LoopListView2")

---@param csLoopListView SuperScrollView.LoopListView2
function _M:Ctor(csLoopListView, view)
    self.m_csLoopListView = csLoopListView
    ---@type table<number, SuperBaseItem>  number起始1
    self.itemIndexDic = {}  -- 拿到index 对应的 LuaClass
    self.selectIndexDic = {}    --选中状态
    self.selectList = {}    -- 选中列表 多选list List<int>
    self.IsParentSelect = false --是否为父节点点击
    self.maxSelectNum = 1
    self.mView = view
    if view then -- 注册生命周期事件到 view/subview 中
        view:AddBehaviour(self)
    end
end

function _M:GetItemClass(prefabName,itemClass,index)
    local listItem = nil
    listItem = self.m_csLoopListView:NewListViewItem(prefabName)
    local item = listItem.UserObjectData
    local mIndex = index + 1
    if item == nil or item.bDestroy then
        item = itemClass.New()
        item:InitListData(self, mIndex, listItem)
        listItem.UserObjectData = item
    end
    item:RefreshIndex(mIndex)
    self.itemIndexDic[mIndex] = item
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

-- 初使化list
--- @param itemTotalCount System.Int32 显示数量
--- @param fnGetItemByIndex function(LoopListView2, int, LoopListViewItem2) 回调
function _M:InitListView(itemTotalCount, fnGetItemByIndex)
    self.m_csLoopListView:InitListView(itemTotalCount, fnGetItemByIndex)
end

-- 通过lua直接刷新
---@param iItemIndex number 1开始
---@param data any
function _M:RefreshItemByItemLuaIndex(iItemIndex, ...)
    local item = self.itemIndexDic[iItemIndex]
    if item then
        item:OnGUI(...)
    end
end

-- 刷新指定索引的Data
function _M:RefreshItemByItemIndex(iItemIndex)
    self.m_csLoopListView:RefreshItemByItemIndex(iItemIndex)
end

-- 指定索引位置刷新
function _M:RefreshAllShownItemWithFirstIndex(iFirstItemIndex)
    self.m_csLoopListView:RefreshAllShownItemWithFirstIndex(iFirstItemIndex)
end

-- 设置GridCount
--- @param iItemCount number 数量
--- @param bResetPos boolean 重设位置
function _M:SetListItemCount(iItemCount, bResetPos, bForceRefresh)
    local nCount = #self.itemIndexDic
    for i = nCount, 1, -1 do
        if i > iItemCount then
            self:RemoveLuaItem(i)
        else
            break
        end
    end
    self.m_csLoopListView:SetListItemCount(iItemCount, bResetPos, bForceRefresh)
end

function _M:RemoveLuaItem(nIndex)
    local item = table.remove(self.itemIndexDic, nIndex)
    if item then
        item:Close()
        
        --fix: 需要保持lua对象绑定
        --item:Destroy()
    end

    --fix: 需要保持lua对象绑定
    --local listItem = self:GetShownItemByIndex(nIndex - 1)
    --if listItem then
    --    listItem.UserObjectData = nil
    --end
end


-- 全部刷新
function _M:RefreshAllShownItem()
    self.m_csLoopListView:RefreshAllShownItem()
end

-- 改变size
function _M:OnItemSizeChanged(iItemIndex)
    self.m_csLoopListView:OnItemSizeChanged(iItemIndex)
end

-- 以显示中的item位置,获取显示中的Item
function _M:GetShownItemByIndex(iIndex)
    return self.m_csLoopListView:GetShownItemByIndex(iIndex)
end

function _M:GetShowItemByListItem(csListItem)
    return csListItem.UserObjectData
end

-- 以ItemIndex,获取显示中的LuaItem, 如果不在显示中则返回nil
---@param iItemIndex number 从0开始
---@return SuperBaseItem
function _M:GetShownLuaItemByItemIndex(iItemIndex)
    return self.itemIndexDic[iItemIndex + 1]
end

-- 以ItemIndex,获取显示中的Item, 如果不在显示中则返回nil
---@param iItemIndex number 从0开始
---@return SuperScrollView.LoopListViewItem2
function _M:GetShownItemByItemIndex(iItemIndex)
    return self.m_csLoopListView:GetShownItemByItemIndex(iItemIndex)
end

-- 获取显示中的最靠近指定itemIndex的Item
---@param iItemIndex number 从0开始
---@return SuperScrollView.LoopListViewItem2
function _M:GetShownItemNearestItemIndex(itemIndex)
    return self.m_csLoopListView:GetShownItemNearestItemIndex(itemIndex)
end

-- 获取item的位置
function _M:GetItemCornerPosInViewPort(item, corner)
    return self.m_csLoopListView:GetItemCornerPosInViewPort(item, corner)
end

-- 重置列表(用于列表transform动态变化时调用)
function _M:ResetListView(bResetPos)
    self.m_csLoopListView:ResetListView(bResetPos)
end

---@return UnityEngine.UI.ScrollRect
function _M:GetScrollRect()
    return self.m_csLoopListView.ScrollRect
end

function _M:GetViewPortSize()
    return self.m_csLoopListView.ViewPortSize
end

function _M:GetShownItemCount()
    return self.m_csLoopListView.ShownItemCount
end

function _M:GetItemList()
    return self.m_csLoopListView.ItemList
end

--region 拖动事件
function _M:SetBeginDragCallback(fnBeginDrag)
    self.m_csLoopListView.mOnBeginDragAction = fnBeginDrag
end

function _M:SetDragingCallback(fnDraging)
    self.m_csLoopListView.mOnDragingAction = fnDraging
end

function _M:SetEndDragCallback(fnEndDrag)
    self.m_csLoopListView.mOnEndDragAction = fnEndDrag
end
--endregion

--region snap_event

function _M:SetSnapItemFinishCallback(fnFinished)
    self.m_csLoopListView.mOnSnapItemFinished = fnFinished
end

function _M:SetSnapNearestChangedCallback(fnNearestChanged)
    self.m_csLoopListView.mOnSnapNearestChanged = fnNearestChanged
end

function _M:SetSnapScaleChangedCallback(fnSnapScaleChanged)
    self.m_csLoopListView.mOnSnapScaleAction = fnSnapScaleChanged
end

--endregion

function _M:Clear()
    self.m_csLoopListView:SetListItemCount(0, false, false)    
end

function _M:Destroy()

end

function _M:ClearAllItem()
    for _, value in pairs(self.itemIndexDic) do
        if value then
            value:Close()
            value:Destroy()
        end
    end
    self.itemIndexDic = {}    
end


--------------------- 生命周期事件 ---------------------

function _M:OnClose()
    for _, value in pairs(self.itemIndexDic) do
        if value then
            value:Close()
        end
    end
    self.selectIndexDic = {}
    self.selectList = {}
end

function _M:OnDestroy()
    for _, value in pairs(self.itemIndexDic) do
        if value then
            value:Destroy()
        end
    end
    self.itemIndexDic = nil
    if self.m_csLoopListView ~= nil and self.m_csLoopListView.ScrollRect ~= nil then
        self.m_csLoopListView.ScrollRect.onValueChanged:RemoveAllListeners();
    end
    self.m_csLoopListView:ResetLoopView()
    self.m_csLoopListView = nil
end

--------------------------------------------------------

function _M:SetActive(bValue)
    LuaUtil.SetCompObjActive(self.m_csLoopListView, bValue)
end

------------ 【 外部方法 】

---移动到指定位置
---@param index System.Int32 移动到第几行(从1开始)
---@param offset number 偏移量
---@param isAnim boolean 是否使用动画
function _M:MovePanelToItemIndex(index,offset,isAnim) 
	local offset = offset or 0
	local anim = isAnim or false
	local mIndex = index - 1
    self.m_csLoopListView:MovePanelToItemIndex(mIndex,offset,anim)
end

---动画移动到指定位置(用于item大小不一致的情况, 避免移动误差)
---@param index System.Int32 移动到第几行(从1开始)
---@param offset number 偏移量
function _M:MovePanelToItemIndexAccurate(index,offset)
    local offset = offset or 0
    local mIndex = index - 1
    self.m_csLoopListView:MovePanelToItemIndexAccurate(mIndex,offset)
end

-- 设置单选
-- isRresh 是否强制刷新 
-- index 等于 当前选中的 index的时候 会不处理， 如果需要刷新则为true
--- bItemClick 是主动点击触发 还是调用的SetSelect的点击触发
function _M:SetSelect(index,isRresh,bItemClick) 
    local curIndex = self:GetSelectIndex()
    if curIndex ~= nil or isRresh then
        local tab = {}
        table.insert(tab,index)
        self:SetSelectList(tab,bItemClick)         -- 从多选调用业务逻辑
    end
end

-- 设置多选
function _M:SetSelectList(table,bItemClick)    --table is List<int> by LuaTable
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
function _M:AddSelect(callback)
    self.selectCallBack = callback
end

-- 当item隐藏or显示的时候 会回调
function _M:AddItemReflush(callback)
    self.reflushCallBack = callback
end

-- 清楚所有选中
function _M:ClearSelect()
    for _, index in ipairs(self.selectList) do
        self:SetItemSelect(index,false)
    end
    self.selectList = {}
end

-- 添加选中
function _M:AppendSelect(index,bItemClick)
    if self.maxSelectNum == 1 then  --单选
        self:SetSelect(index,false,bItemClick)
    else
        table.insert(self.selectList,index)
        self:SetItemSelect(index,true,bItemClick)
    end
end

-- 添加取消选中的回调
function _M:AddDeSelect(callback)
    self.deSelectCallBack = callback
end

-- 拿到所有选中列表
function _M:GetSelectList()
    return self.selectList
end

---获取元预制体
function _M:GetItemPrefab(index)
    return self.m_csLoopListView:GetItemPrefab(index)
end

------------ 【 内部方法 】
function _M:OnItemClick(mIndex)
    local item = self.itemIndexDic[mIndex]
    if self:IsSelected(mIndex) then
        if self.maxSelectNum == 1 then
            self:SetItemSelect(mIndex,true)
        else
            self:DeSelect(mIndex)
        end
    else
        self:AppendSelect(mIndex)
    end
end

function _M:DeSelect(index)
    if self:IsSelected(index) then
        table.remove(self.selectList,index)
        self:SetItemSelect(index,false)
    end
end


-- 对某个item设置选中状态
--- bItemClick 是主动点击触发 还是调用的SetSelect的点击触发
function _M:SetItemSelect(index , bValue,bItemClick)
    self.selectIndexDic[index] = bValue
    if self.itemIndexDic[index] ~= nil then
        local baseItem = self.itemIndexDic[index]
        baseItem:OnSelected(bValue)
        if bValue and self.selectCallBack ~= nil then
            self.selectCallBack(index,bItemClick)
        elseif not bValue and self.deSelectCallBack ~= nil then
            self.deSelectCallBack(index)
        end
    end
end

-- 是否选中
function _M:IsSelected(index)
    return self.selectIndexDic[index]
end

-- 获得当前选中index
function _M:GetSelectIndex()
    if self.selectList[1] ~= nil then
        return self.selectList[1]
    end
    return -1 
end

function _M:GetItemInfo(index)
    local item = self.itemIndexDic[index]

    return item
end

return _M