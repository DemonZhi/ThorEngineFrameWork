local BaseStep = class("BaseStep")
local type_UIBinder = typeof(SGEngine.UI.UIBinder)

--子类重写
function BaseStep:Init(rootView, transformUI, cinemaActionType)
	self.m_RootView = rootView
	self.m_Transform = transformUI
	self.m_StepType = cinemaActionType
	BaseStep:ResolveUIBind(self.m_Transform, self)
	self:OnInit()
end

function BaseStep:Show(cinemaConfig)
   self.m_CinemaConfig = cinemaConfig
   if self.m_CinemaConfig == nil then
   	  return
   end
   self:OnShow(cinemaConfig)
   self.m_Transform.gameObject:SetActive(true)
end

function BaseStep:Hide()
   self:OnHide()
   self.m_CinemaConfig = nil
   self.m_Transform.gameObject:SetActive(false)
end

function BaseStep:Destroy()
	self:OnDestroy()
	self.m_Transform = nil
	self.m_RootView = nil
	self.m_StepType = nil
	self.m_CinemaConfig = nil
end

function BaseStep:Finish(params)
    if self.m_RootView == nil then
       return
    end
    self.m_RootView:StepFinished(self, params)
end

--由子类继承
function BaseStep:OnInit()

end

function BaseStep:OnShow(cinemaConfig)

end

function BaseStep:OnHide()
	
end

function BaseStep:OnDestroy()
   
end

function BaseStep:ResolveUIBind(transform, dicTab)
    if not transform then
        return false
    end
    local uibinder = transform:GetComponent(type_UIBinder)
    if uibinder == nil then
        return false
    end

    for i = 0, uibinder.uiList.Count - 1 do
        local component, name = uibinder:GetComponentByIndex(nil, i)
        if name ~= nil then
            dicTab[name] = component
        end
    end

    return true
end

return BaseStep
