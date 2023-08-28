local TaskView = class("TaskView",BaseView)

--子类重写
function TaskView:InitUI()	
	self.m_Transform.offsetMin = Vector2.New(0, 0)
	self.m_Transform.offsetMax = Vector2.New(0, 0)

	self:AddToggleOrSliderListener(self.instanceToggle, function (isOn)
		local monsters = ObjectManager.GetObjects(
		function(x)
				return x:IsMonster()
			end
		)
		local modelId = 28
		if isOn then
			modelId = 27
		end
		for i, v in pairs(monsters) do
			v:ChangeModelAndSkinCore(modelId)
		end
	end)
end

--子类重写
function TaskView:BeforeDestroy()
end

return TaskView