local MessengerCls = require("Engine/Systems/EventSystem/Messenger") -- to do
local Core_Utility = ThorEngine.UI.Utility
local Core_UIManager = ThorEngine.UI.UIManager
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")

local BaseView = class('BaseView', BaseUI)
local k_HidePosition = {x = -10000, y = -10000}
local k_ShowPsition = {x = 0, y = 0}
local k_Params = 3
--初始化
function BaseView:Init(go)
    BaseView.__super.Init(self, go)
    self.m_Transform.localScale = Vector3.one
    self.m_Transform.localPosition = Vector3.zero
    self.m_Transform.anchoredPosition = Vector2.zero
    self.m_Transform.anchorMin = Vector2.New(0, 0)
    self.m_Transform.anchorMax = Vector2.New(1, 1)
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)
    self.m_Canvas = self.m_Transform:GetComponent('Canvas')

    self.m_EventList = {}
     --dotween对象
    self.m_TweenObjs = {}
    --外部生命周期事件
    self.m_BehaviourList = {OpenEvents = {}, CloseEvents = {}, DestroyEvents = {}}
end

--加载回调
function BaseView:LoadUICallback(go)
    self:Init(go)
    self:InitUIBinder()
    self:InitUI()
end

--添加事件监听
function BaseView:AddEventListener(event, handler, params)
    self.m_EventList[event] = self.m_EventList[event] or {}
    table.insert(self.m_EventList[event], handler)
    Dispatcher.AddEventListener(event, handler, params)
end

--删除事件监听
function BaseView:RemoveEventListener(event, handler)
    if self.m_EventList[event] == nil then
        return
    end

    local eventList = self.m_EventList[event]
    local length = #eventList
    for i=length, 1, -1 do
        if eventList[i] == handler then 
            table.remove(eventList, i)
            Dispatcher.RemoveEventListener(event, handler)
        end
    end
end

--删除所有事件监听
function BaseView:RemoveAllEventListener()
    for event, handlerList in pairs(self.m_EventList) do
        for i, handler in ipairs(handlerList) do
            Dispatcher.RemoveEventListener(event, handler)
        end
    end
    self.m_EventList = {}
end

--设置配置
function BaseView:SetUIConfig(config)
    self.m_Config = config
end

--获取UI配置
function BaseView:GetUIConfig()
    return self.m_Config
end

function BaseView:MoveToDistance()
    local pos = self.m_Transform.anchoredPosition
    if pos.x == k_HidePosition.x and pos.y == k_HidePosition.y then 
        return
    end

    self:SetAnchoredPosition(k_HidePosition.x, k_HidePosition.y)
    self:OnFullScreenCallback(false)
end

function BaseView:RevertToOrigin()
    local pos = self.m_Transform.anchoredPosition
    if pos.x == k_ShowPsition.x and pos.y == k_ShowPsition.y then 
        return
    end

    self:SetAnchoredPosition(k_ShowPsition.x, k_ShowPsition.y)
    self:OnFullScreenCallback(true)
end

function BaseView:SetSortingOrder(value)
    if self.m_Canvas == nil then 
        Logger.Error(string.format("[BaseView](GetSortingOrder)Lua: BaseView找不到Canvas:{0}", self.m_GameObject.name))
    end
    if self.m_Canvas.overrideSorting == false then 
        self.m_Canvas.overrideSorting = true
    end
    self.m_Canvas.sortingOrder = value
end

function BaseView:GetSortingOrder()
    if self.m_Canvas == nil then 
        Logger.Error(string.format("[BaseView](GetSortingOrder)Lua: BaseView找不到Canvas:{0}", self.m_GameObject.name))
    end
    return self.m_Canvas.sortingOrder
end

function BaseView:IsFullScreen()
    if self.m_Config.isFullScreen == nil then  
        return false
    else
        return self.m_Config.isFullScreen 
    end
end

----------------------------------------------------------------------Tween---------------------------------------------

--注册Tween, 打开时候自动播放
function BaseView:RegisterTweenOnOpen(gameObject)
    table.insert(self.m_TweenObjs, gameObject)
end

--注销Tween
function BaseView:RemoveTweenOnOpen(gameObject, isKill)
    for i, v in ipairs(self.m_TweenObjs) do
        if v == gameObject then
            if isKill then
                DOTween.Kill(gameObject)
            end
            table.remove(self.m_TweenObjs, i)
            return
        end
    end
end

--播放所有tween
function BaseView:PlayAllTween()
    for i, v in ipairs(self.m_TweenObjs) do
        DOTween.Restart(v)
    end
end

function BaseView:KillAllTween()
    for i, v in ipairs(self.m_TweenObjs) do
        DOTween.Kill(v)
    end
    self.m_TweenObjs = nil
end

--region 外部生命周期事件

function BaseView:AddBehaviour(luaClass)
    -- 提取类中的生命周期事件
    if luaClass.OnOpen and type(luaClass.OnOpen) == "function" then
        table.insert(self.m_BehaviourList.OpenEvents, CommonUtil.GetSelfFunc(luaClass, luaClass.OnOpen))
    end
    if luaClass.OnClose and type(luaClass.OnClose) == "function" then
        table.insert(self.m_BehaviourList.CloseEvents, CommonUtil.GetSelfFunc(luaClass, luaClass.OnClose))
    end
    if luaClass.OnDestroy and type(luaClass.OnDestroy) == "function" then
        table.insert(self.m_BehaviourList.DestroyEvents, CommonUtil.GetSelfFunc(luaClass, luaClass.OnDestroy))
    end
end

function BaseView:CheckOpenEvent()
    for i, event in ipairs(self.m_BehaviourList.OpenEvents) do
        event()
    end
end

function BaseView:CheckCloseEvent()
    for i, event in ipairs(self.m_BehaviourList.CloseEvents) do
        event()
    end
end

function BaseView:CheckDestroyEvent()
    for i, event in ipairs(self.m_BehaviourList.DestroyEvents) do
        event()
    end
    self.m_BehaviourList = nil
end

--endregion
-------------------------------------------------------------Tween End------------------------------------------------------

--打开界面
function BaseView:Open(...)
    UIManager.RegisterActiveView(self)
    local params = {...}
    self:BeforeOpen(params[k_Params])
    self.m_GameObject:SetActive(true)
    self.m_Transform:SetAsLastSibling()

    self:PlayAllTween()
    self:OnOpen(params[k_Params])
    UIManager.CheckAllCameraVisible()
end

--关闭界面
function BaseView:Close()
    UIManager.UnRegisterActiveView(self)
    self:BeforeClose()
    self.m_GameObject:SetActive(false)
    self:OnClose()

    UIManager.CheckAllCameraVisible()
end

--销毁界面
function BaseView:Destroy()
    if self:IsActive() then  
        self:Close()
    end

    self:BeforeDestroy()
    self:KillAllTween()
    self:RemoveAllEventListener()
    BaseView.__super.Destroy(self)
    ResourceManager.ReleaseInstance(self.m_GameObject)
    self:OnDestroy()

    UIManager.CheckAllCameraVisible()
end

--子类重写
function BaseView:InitUI()
end

--子类重写
function BaseView:BeforeOpen()
end

--子类重写
function BaseView:OnOpen()
end

--子类重写
function BaseView:BeforeClose()
end

--子类重写
function BaseView:OnClose()
end

--子类重写
function BaseView:BeforeDestroy()
end

--子类重写
function BaseView:OnDestroy()
end

--子类重写
function BaseView:OnFullScreenCallback(isShow)
end

return BaseView