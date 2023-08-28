local BaseCtrl = class("BaseCtrl")

function BaseCtrl:InitCtrl(config)
    self.m_bSceneChangeCloseView = true
    self.m_Config = config
    self:InitModel()
    self:Init()
    self:RegisterCommand()
end

function BaseCtrl:InitModel()
    local class = require(self.m_Config.modelPath)
    if class then
        self.m_Model = class.New()
        if self.m_Model.Init then
            self.m_Model:Init()
        end
    else
        Log.ErrorFormat("Class is nil modelPath:%s", self.m_Conifg.modelPath)
    end    
end

function BaseCtrl:GetModel()
    if self.m_Model == nil then
        self:InitModel()
    end
    return self.m_Model
end

function BaseCtrl:OpenView(...)
    UIManager.OpenView(self.m_Config.viewName, ...)
end

function BaseCtrl:CloseView()
    UIManager.CloseView(self.m_Config.viewName)
end

function BaseCtrl:DestroyView()
    UIManager.DestroyView(self.m_Config.viewName)
end

function BaseCtrl:IsViewShow()
    return UIManager.IsViewShow(self.m_Config.viewName)
end

function BaseCtrl:GetUIWindow()
    return UIManager.GetUIWindow(self.m_Config.viewName)
end

--子类重新写
function BaseCtrl:Init(...)
end

--子类重新写
function BaseCtrl:RegisterCommand()
end

return BaseCtrl