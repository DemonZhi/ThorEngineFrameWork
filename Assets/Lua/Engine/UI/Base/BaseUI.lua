local ImageLoader = require("Engine/UI/Base/ImageLoader")
local UIPrefabLoader = require("Engine/UI/Base/UIPrefabLoader")
local HeadPhotoLoader = require("Engine/UI/Base/HeadPhotoLoader")
local UIHelper = require("Engine/UI/Common/UIHelper")
local string_IsNullOrEmpty = string.IsNullOrEmpty
local UIGray = SGEngine.UI.UIGray

local BaseUI = class('BaseUI')
function BaseUI:Init(go)
    self.m_GameObject = go
    self.m_Transform = go.transform
    self.m_ImageDictionary = {} --Image 是否获取过图片
    self.m_PrefabDictionary = {} --预设表
    self.m_HeadPhotoDictionary = {} --头像表
    

    -- 按钮注册事件
    self.m_RegisterButtonListenerMap = {}
    self.m_ListenerBtns = {}
    self.m_DicClickCD = {}
    self.m_ListenerToggles = {}
    self.m_ListenerLongPresses = {}
    
    --ObjectPool 容器
    self.m_ObjectPool = {}

    -- 按钮CD
    self.m_LastButtonClickTimeMap = {}
    -- Toggle注册事件
    self.m_RegisterToggleListenerMap = {}
end

-- 将Obj与LuaClass 做绑定
function BaseUI:SetObj(obj)
    self:Init(obj)
    self:InitUIBinder()
    LuaUtil

end

function BaseUI:Destroy()
    self:ReleaseAllSprite()
    self:RemoveAllButtonListener()
    self:RemoveAllToggleListener()
end

--获取脚本
function BaseUI:GetChildComponent(path, componentName)
    local transform = self.m_Transform:Find(path)
    if transform then
        return transform:GetComponent(componentName)
    else
        Logger.LogErrorFormat('{0}路径找不到对象')
        return nil
    end
end

--读取UIBinder配置
function BaseUI:InitUIBinder()
    local config = self.m_Transform:GetComponent('UIBinder')
    if config == nil then
        return
    end

    for i = 0, config.uiList.Count - 1 do
        local binderData = config.uiList[i]
        if binderData.go then
            self[binderData.name] = binderData.component
        end
    end

    self.m_UIBinder = config
end

--设置 image.sprite 异步加载 需添加 加载中的队列管理
function BaseUI:SetImageSprite(image, atlasKey, spriteName, callback)
    local atlasSpriteName = table.concat({atlasKey, "[", spriteName, "]"})
    local imageLoader = self.m_ImageDictionary[image]
    if imageLoader == nil then
        imageLoader = ImageLoader.New()
        self.m_ImageDictionary[image] = imageLoader
    end
    imageLoader:LoadImage(image, atlasSpriteName, callback)
end

function BaseUI:SetRawImage(rawImage, imagePath, callback)
    local imageLoader = self.m_ImageDictionary[rawImage]
    if imageLoader == nil then
        imageLoader = ImageLoader.New()
        self.m_ImageDictionary[rawImage] = imageLoader
    end
    imageLoader:LoadRawImage(rawImage, imagePath, callback)
end

function BaseUI:ReleaseAllSprite()
    if self.m_ImageDictionary ~= nil then
        for image, imageLoader in pairs(self.m_ImageDictionary) do
            self.m_ImageDictionary[image] = nil
            imageLoader:Destroy()
        end
        self.m_ImageDictionary = nil
    end
end

--是否激活
function BaseUI:IsActive()
    return self.m_GameObject.activeSelf
end

function BaseUI:AddButtonListener(button, event, cdTime)
    if button then 
        button.onClick:AddListener(function ()
            if cdTime then 
                local lastButtonClick = self.m_LastButtonClickTimeMap[button] 
                if lastButtonClick and os.time() - lastButtonClick < cdTime then 
                    -- TODO: CD逻辑
                    return
                end

                self.m_LastButtonClickTimeMap[button]  = os.time()
            end
            event()   
        end)

        self.m_RegisterButtonListenerMap[button] = true
    end
end

function BaseUI:AddToggleOrSliderListener(toggle, listener)
    toggle.onValueChanged:AddListener(listener)
    self.m_RegisterToggleListenerMap[toggle] = true
end

function BaseUI:RemoveAllButtonListener()
    for button,v in pairs(self.m_RegisterButtonListenerMap) do
        button.onClick:RemoveAllListeners()
    end
    self.m_RegisterButtonListenerMap = {}
    self.m_LastButtonClickTimeMap = {}
end

function BaseUI:RemoveAllToggleListener()
    for toggle,v in pairs(self.m_RegisterToggleListenerMap) do
        toggle.onValueChanged:RemoveAllListeners()
    end
    self.m_RegisterToggleListenerMap = {}
end

function BaseUI:SetUIGray(graphic, isGray, includeChildren)
    includeChildren = includeChildren and true or false
    if isGray then 
        UIGray.SetUIGray(graphic, includeChildren)
    else
        UIGray.Recovery(graphic, includeChildren)
    end
end

function BaseUI:SetActive(value)
    self.m_GameObject:SetActive(value)
end

function BaseUI:SetLocalScale(x, y, z)
    Core_ForLuaUtility.SetLocalScale(self.m_GameObject, x, y, z)
end

function BaseUI:SetLocalPosition(x, y, z)
    Core_ForLuaUtility.SetLocalPosition(self.m_GameObject, x, y, z)
end

function BaseUI:SetAnchoredPosition(x, y)
    Core_ForLuaUtility.SetAnchoredPosition(self.m_GameObject, x, y)
end

return BaseUI