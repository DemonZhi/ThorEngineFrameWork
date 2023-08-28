local TouchButton = class("TouchButton", BaseUI)
TouchButton.TouchButtonModeEnum = {
    Continuous = 1,
    OneTime = 2
}
function TouchButton:Ctor(transform)
    local component = transform:GetComponent("UITouchButton")
    self.m_Button = component
    component:SetOnDragCallback(function(angle)
        self:OnDrag(angle)
    end)
    component:SetOnDragEndCallback(function(angle)
        self:OnDragEnd(angle)
    end)
    component:SetOnClickDownCallback(function()
        self:OnClickDown()
    end)
    component:SetOnClickUpCallback(function()
        self:OnClickUp()
    end)
    component:SetUpdateCallback(function()
        self:OnUpdate()
    end)
    component:SetOnDisableCallback(function()
        self:OnDisable()
    end)

    self:Init(transform.gameObject)
    self:InitUIBinder()
end

--region private
function TouchButton:OnDrag(angle)
    if self.m_OnDragCallback then
        self.m_OnDragCallback(angle)
    end
end

function TouchButton:OnDragEnd(angle)
    if self.m_OnDragEndCallback then
        self.m_OnDragEndCallback(angle)
    end
end

function TouchButton:OnClickDown()
    if self.m_ButtonType == TouchButton.TouchButtonModeEnum.Continuous then
        self.m_IsPressing = true
    end

    if self.m_OnClickDownCallback then
        self.m_OnClickDownCallback()
    end
end

function TouchButton:OnClickUp()
    self.m_IsPressing = false

    if self.m_OnClickUpCallback then
        self.m_OnClickUpCallback()
    end
end

function TouchButton:OnUpdate()
    if self.m_ButtonType ~= TouchButton.TouchButtonModeEnum.Continuous then
        return
    end
    
    if self.m_IsPressing then
        self:OnClickDown()
    end
end

function TouchButton:OnDisable()
    self.m_IsPressing = false
end
--endregion

--region public
function TouchButton:SetButtonType(buttonType)
    self.m_ButtonType = buttonType
end

---@param callback action<float>
function TouchButton:SetOnDragCallback(callback)
    self.m_OnDragCallback = callback
end

---@param callback action<float>
function TouchButton:SetOnDragEndCallback(callback)
    self.m_OnDragEndCallback = callback
end

function TouchButton:SetOnClickDownCallback(callback)
    self.m_OnClickDownCallback = callback
end

function TouchButton:SetOnClickUpCallback(callback)
    self.m_OnClickUpCallback = callback
end

function TouchButton:SetDragEnable(enable)
    self.m_Button:SetDragEnable(enable)
end

function TouchButton:SetOnClickCallback(callback)
    self.m_Button:SetOnClickCallback(callback)
end

function TouchButton:GetCurrentAngle()
    return self.m_Button:GetAngle()
end
--endregion

return TouchButton