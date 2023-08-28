local ColorPicker = class('ColorPicker')

local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local Color = UnityEngine.Color
local Mathf = UnityEngine.Mathf
local Quaternion = UnityEngine.Quaternion
local RectTransformUtility = UnityEngine.RectTransformUtility

local k_AssetKey = 'ColorPicker'

function ColorPicker:Ctor(parent, onColorChangeCallback, onLoadCallback)
	self.m_Parent = parent
	self.m_OnColorChangeCallback = onColorChangeCallback
    self.m_OnLoadCallback = onLoadCallback

	self.m_Hue = 0
	self.m_Saturation = 1
	self.m_Value = 1

	self.m_CurrentPickColor = self:HSVToRGB(self.m_Hue, self.m_Saturation, self.m_Value)

	ResourceManager.InstantiateAsync(
        k_AssetKey,
        function(go)
            self:Init(go)
        end,
        PoolingStrategyTypeEnum.Default
    )
end

function ColorPicker:Init(go)
	self.m_GameObject = go
    self.m_Transform = go.transform

    self.m_Transform:SetParent(self.m_Parent)
    self.m_Transform.localScale = Vector3.one
    self.m_Transform.localPosition = Vector3.zero
    self.m_Transform.anchoredPosition = Vector2.zero

    self:InitUIBinder()
    self:InitEventListener()

    if self.m_OnLoadCallback then 
        self.m_OnLoadCallback(go)
    end
end

--读取UIBinder配置
function ColorPicker:InitUIBinder()
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

function ColorPicker:InitEventListener()
    local uIEventTriggerListener = System.Type.GetType("SGEngine.UI.UIEventTriggerListener")
    self.m_CircleEventListener = Core_ForLuaUtility.GetOrAddComponent(self.imgCircle.gameObject, uIEventTriggerListener)
	self.m_RectangleEventListener = Core_ForLuaUtility.GetOrAddComponent(self.imgRectangle.gameObject, uIEventTriggerListener)

	self.m_CircleEventListener.onDrag = function (eventData)
		self:OnCircleDrag(eventData)
	end

	self.m_RectangleEventListener.onBeginDrag = function (eventData)
		self:OnRectangleClick(eventData)
	end

	self.m_RectangleEventListener.onDrag = function (eventData)
		self:OnRectangleDrag(eventData)
	end
end

-- 滑动圆环回调
function ColorPicker:OnCircleDrag(eventData)
	local currentScreenPosition = RectTransformUtility.WorldToScreenPoint(eventData.pressEventCamera, self.imgCircle.transform.position)
    local directionTo = currentScreenPosition - eventData.position
    local directionForm = directionTo - eventData.delta
    local directionToVecetor3 = Vector3.New(directionTo.x, directionTo.y, 0)
    local directionFormVecetor3 = Vector3.New(directionForm.x, directionForm.y, 0)
    self.imgCircle.transform.rotation = self.imgCircle.transform.rotation * Quaternion.FromToRotation(directionToVecetor3, directionFormVecetor3)

    local angle = self:GetAngle()
    self.m_Hue = 1 - (angle / 360)

    self:UpdateRectrangleColor()
    self:UpdatePickColor()

	if self.m_OnColorChangeCallback then 
		self.m_OnColorChangeCallback(self.m_CurrentPickColor)
	end
end

function ColorPicker:GetAngle()
    local angle = self.imgCircle.transform.localEulerAngles.z
    angle = angle % 360
    if angle < 0 then 
        angle = 360 - angle
    end 
    return angle
end

function ColorPicker:UpdateRectrangleColor()
    Core_ForLuaUtility.SetMaterialFloat(self.imgRectangle.material, "_Hue", self.m_Hue)
end

function ColorPicker:UpdatePickColor()
	self.m_CurrentPickColor = self:HSVToRGB(self.m_Hue, self.m_Saturation, self.m_Value)
end

function ColorPicker:UpdateSaturationAndValue(localPosition)
	local sizeDelta = self.imgRectangle.transform.sizeDelta
	local width = sizeDelta.x
    local high = sizeDelta.y

    local x = localPosition.x / width + 0.5
    local y = localPosition.y / high + 0.5

    self.m_Saturation = x
    self.m_Value = y
end

function ColorPicker:UpdateSelectPointPosition(localPosition)
	self.transformSelector.anchoredPosition = localPosition
end

-- 滑动矩形回调
 function ColorPicker:OnRectangleDrag(eventData)
 	local screenPoint = eventData.position;
    local localPosition = self:ScreenPointToLocal(screenPoint, eventData.pressEventCamera);

    self:UpdateSaturationAndValue(localPosition)
    self:UpdatePickColor()
    self:UpdateSelectPointPosition(localPosition)

 	if self.m_OnColorChangeCallback then 
		self.m_OnColorChangeCallback(self.m_CurrentPickColor)
	end
 end

-- 点击矩形回调
 function  ColorPicker:OnRectangleClick(eventData)
 	local screenPoint = eventData.pressPosition;
    local localPosition = self:ScreenPointToLocal(screenPoint, eventData.pressEventCamera);

    self:UpdateSaturationAndValue(localPosition)
    self:UpdatePickColor()
    self:UpdateSelectPointPosition(localPosition)

 	if self.m_OnColorChangeCallback then 
		self.m_OnColorChangeCallback(self.m_CurrentPickColor)
	end
 end

 function ColorPicker:ScreenPointToLocal(screenPoint, camera)
    local point = nil
    local isSuccess, localPoint = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.imgRectangle.transform, screenPoint, camera, point)
    local sizeDelta = self.imgRectangle.transform.sizeDelta
    localPoint.x = Mathf.Clamp(localPoint.x, - sizeDelta.x / 2, sizeDelta.x / 2)
    localPoint.y = Mathf.Clamp(localPoint.y, - sizeDelta.y / 2, sizeDelta.y / 2)
    return localPoint
 end

 function ColorPicker:HSVToRGB(hue, saturation, value)
 	local color = Color.white

 	local r = Mathf.Clamp01(math.abs((hue * 6.0 + 0.0) % 6 - 3) - 1.0)
 	local g = Mathf.Clamp01(math.abs((hue * 6.0 + 4.0) % 6 - 3) - 1.0)
 	local b = Mathf.Clamp01(math.abs((hue * 6.0 + 2.0) % 6 - 3) - 1.0)

	r = r * r * (3.0 - 2.0 * r)
    g = g * g * (3.0 - 2.0 * g)
    b = b * b * (3.0 - 2.0 * b)

    r = value * Mathf.Lerp(1, r, saturation)
    g = value * Mathf.Lerp(1, g, saturation)
    b = value * Mathf.Lerp(1, b, saturation)

    -- color.r = Mathf.Pow(r, 2.2)
    -- color.g = Mathf.Pow(g, 2.2)
    -- color.b = Mathf.Pow(b, 2.2)

    color.r = r^2.2
    color.g = g^2.2
    color.b = b^2.2

    return color
 end

 function ColorPicker:RGBToHSV(color)
     local saturation = 0
     local hue = 0
     local min = math.min(math.min(color.r, color.g), color.b)
     local value = math.max(math.max(color.r, color.g), color.b)

     local delta = value - min

     if v == 0 then  
        saturation = 0
    else
        saturation = delta / value
    end

    if saturation == 0 or delta == 0 then 
        hue = 360
    else
        if color.r == value then 
            hue = (color.g - color.b) / delta
        elseif color.g == value then 
            hue = 2 + (color.b - color.r) / delta
        elseif color.b == value then 
            hue = 4 + (color.r - color.g) / delta
        end

        hue = hue * 60
        -- if hue <= 60 then 
        --     hue = hue + 360
        -- end
    end

    -- hue = (360 - hue) / 360
    hue = hue / 360

    return hue, saturation, value
 end

function ColorPicker:Destroy()
	if self.m_RectangleEventListener then 
		self.m_RectangleEventListener.onEnter = nil
		self.m_RectangleEventListener.onDrag = nil
	end

	if self.m_CircleEventListener then 
		self.m_CircleEventListener.onDrag = nil
	end

    ResourceManager.ReleaseInstance(self.m_GameObject)
end

function ColorPicker:SetLocalPosition(localPosition)
    if self.m_Transform then 
        self.m_Transform.anchoredPosition = localPosition
    end
end

function ColorPicker:SetLocalScale(localScale)
    if self.m_Transform then 
        self.m_Transform.localScale = localScale
    end
end

function ColorPicker:SetSelectColor(color)
    --Logger.Table(color)
    if self.m_Transform == nil then 
        return 
    end
    self.m_CurrentPickColor = color
    local hue, saturation, value = self:RGBToHSV(color)
    --Logger.LogDebug(hue)
    self.m_Hue = hue
    self.m_Saturation = saturation
    self.m_Value = value

    self:UpdateRectrangleColor()

    -- 更新矩形位置
    local sizeDelta = self.imgRectangle.transform.sizeDelta
    local width = sizeDelta.x
    local high = sizeDelta.y

    local x = (self.m_Saturation - 0.5) * width
    local y = (self.m_Value - 0.5) * high

    self:UpdateSelectPointPosition(Vector2.New(x, y))

    -- 更新圆形角度
    local angle = (1 - self.m_Hue) * 360
    --Logger.LogDebug(angle)
    self.imgCircle.transform.localEulerAngles = Vector3.New(0, 0, angle)

end

function ColorPicker:SetActive(value)
    self.m_GameObject:SetActive(value)
end

return ColorPicker