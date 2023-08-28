local LoadingView = class('LoadingView', BaseView)

function LoadingView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)
end

function LoadingView:OnDestroy()
end

function LoadingView:AddEvent()
end

function LoadingView:ShowProcess(process)
    self.m_ProcessSlider.value = process
end

function LoadingView:ShowLoadTips(tips)
    self.tipsLab.text = tips
end

return LoadingView
