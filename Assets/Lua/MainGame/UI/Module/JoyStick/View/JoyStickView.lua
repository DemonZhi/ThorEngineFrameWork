local JoyStickView = class("JoyStickView",BaseView)
local Core_InputManagerInstance = SGEngine.Core.InputManager.Instance

--子类重写
function JoyStickView:InitUI()	
	self.m_Transform.offsetMin = Vector2.New(0, 0)
	self.m_Transform.offsetMax = Vector2.New(0, 0)

	self.m_JoyStickDragCallback = function(inputX, inputY)
		Core_InputManagerInstance:SetInputDirection(inputX, inputY)
	end
	self.m_JoyStickDragEndCallback = function()
		Core_InputManagerInstance:SetInputDirection(0, 0)
	end

	self.joyStickScrollCircle:SetOnDragCallback(self.m_JoyStickDragCallback)
	self.joyStickScrollCircle:SetOnDragEndCallback(self.m_JoyStickDragEndCallback)
end

--子类重写
function JoyStickView:BeforeDestroy()
	self.joyStickScrollCircle:SetOnDragCallback(nil)
	self.joyStickScrollCircle:SetOnDragEndCallback(nil)
end

return JoyStickView