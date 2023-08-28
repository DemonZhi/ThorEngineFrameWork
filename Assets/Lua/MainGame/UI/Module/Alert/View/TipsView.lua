local TipsView = class('TipsView', BaseView)

local k_MoveUpY = 80
local k_ItemHeight = 80
local k_TotalTime = 2 -- 总时间
local k_StayTime = 0.5 -- 停留时间
local k_MoveUpTime = 0.2 -- 位移时间
local k_ShowNextInterval = k_StayTime + k_MoveUpTime -- 间隔时间
local k_MoveItemHeightTime = k_MoveUpTime / k_MoveUpY * k_ItemHeight -- 
local k_ReachTime = 0.5 -- 碰撞时间
local k_BackgroundExpand = Vector2.New(90, 0)

--子类重写
function TipsView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self.itemPoolList = {}
    self.showingItemInfoList = {}
end

--子类重写
function TipsView:BeforeOpen()
end

--子类重写
function TipsView:OnOpen()
    self.tipsContentList = {}
    self.m_CheckTimerID = TimerManager:AddTimer(self, self.OnTimerCheck, 0.1, 0)
end

--子类重写
function TipsView:BeforeClose()
end

--子类重写
function TipsView:OnClose()
    TimerManager:RemoveTimer(self.m_CheckTimerID)
end

--子类重写
function TipsView:BeforeDestroy()
    TimerManager:RemoveTimer(self.m_CheckTimerID)
end

--子类重写
function TipsView:OnDestroy()
end


function TipsView:AddTips(content)
    if self.tipsContentList[#self.tipsContentList] == content then
        return
    end
    
    table.insert(self.tipsContentList, content)
end

function TipsView:OnTimerCheck()
    self:OnTimerCheckShowNextTips()
    self:OnTimerCheckMove()
    self:OnTimerCheckShowingItemInvalid()
end

function TipsView:OnTimerCheckShowingItemInvalid()
    local tmpCurrTime = Time.time

    for i = #self.showingItemInfoList, 1, -1 do
        local tmpShowingItemInfo = self.showingItemInfoList[i]

        if tmpCurrTime > tmpShowingItemInfo.endTime then
            tmpShowingItemInfo.uiItem.itemGo:SetActive(false)
            tmpShowingItemInfo.moveTween:Kill()
            table.insert(self.itemPoolList, tmpShowingItemInfo.uiItem)
            table.remove(self.showingItemInfoList, i)
        end
    end

    if not next(self.showingItemInfoList) and not next(self.tipsContentList) then
        self:Close()
    end
end

function TipsView:OnTimerCheckShowNextTips()
    local tmpCurrTime = Time.time

    if not self.lastShowTipsTime or tmpCurrTime > self.lastShowTipsTime + k_ShowNextInterval then
        local tmpSucceed = self:ShowNextTips()

        if tmpSucceed then
            self.lastShowTipsTime = tmpCurrTime
        end
    end
end

function TipsView:OnTimerCheckMove()
    local tmpCurrTime = Time.time

    for i, v in ipairs(self.showingItemInfoList) do
        if not v.moveTween and v.showTime + k_StayTime < tmpCurrTime then
            local tmpMoveYTween = v.uiItem.itemGo.transform:DOLocalMoveY(k_MoveUpY, k_MoveUpTime)
            tmpMoveYTween:SetRelative(true)
            v.moveTween = tmpMoveYTween
        end
    end

    local tmpIndex = 0

    for i = #self.showingItemInfoList, 1, -1 do
        local tmpShowingItemInfo = self.showingItemInfoList[i]

        if tmpCurrTime >= tmpShowingItemInfo.showTime + k_ReachTime then
            if not tmpShowingItemInfo.replaced then
                tmpIndex = i
                tmpShowingItemInfo.replaced = true
            end

            break
        end
    end

    if tmpIndex <= 1 then
        return
    end

    for i = 1, tmpIndex - 1 do
        local tmpShowingItemInfo = self.showingItemInfoList[i]
        local tmpUIItem = tmpShowingItemInfo.uiItem
        local tmpMoveYTween = tmpUIItem.itemGo.transform:DOLocalMoveY(k_ItemHeight, k_MoveItemHeightTime)
        tmpMoveYTween:SetRelative(true)
        tmpShowingItemInfo.moveTween = tmpMoveYTween
    end
end

function TipsView:ShowNextTips()
    local tmpTipsData = self.tipsContentList[1]

    if tmpTipsData then
        self:ShowOneTips(tmpTipsData)
        table.remove(self.tipsContentList, 1)
    end
    
    return tmpTipsData ~= nil
end

function TipsView:ShowOneTips(content)
    local tmpUIItem = self.itemPoolList[#self.itemPoolList]

    if not tmpUIItem then
        tmpUIItem = {}
        local tmpItemGo = GameObject.Instantiate(self.tipsItem.gameObject, self.tipsPos)
        tmpUIItem.itemGo = tmpItemGo
        tmpUIItem.itemCanvasGroup = tmpItemGo:GetComponent("CanvasGroup")
        tmpUIItem.contentText = tmpItemGo.transform:Find("labelContent"):GetComponent("Text")
        tmpUIItem.contentCSF = tmpUIItem.contentText.gameObject:GetComponent("ContentSizeFitter")
    else
        table.remove(self.itemPoolList)
    end

    tmpUIItem.itemGo:SetActive(true)
    tmpUIItem.itemGo.transform.localPosition = Vector3.New(0, 0, 0)
    tmpUIItem.contentText.text = content
    tmpUIItem.contentCSF:SetLayoutHorizontal()
    tmpUIItem.itemGo.transform.sizeDelta = tmpUIItem.contentText.transform.sizeDelta + k_BackgroundExpand
    tmpUIItem.itemCanvasGroup.alpha = 0

    local tmpShowingItemInfo = {}
    tmpShowingItemInfo.uiItem = tmpUIItem
    tmpShowingItemInfo.showTime = Time.time
    tmpShowingItemInfo.endTime = Time.time + k_TotalTime
    table.insert(self.showingItemInfoList, tmpShowingItemInfo)
end

return TipsView