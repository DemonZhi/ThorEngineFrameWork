local SRPBatcherProfilerView = class('SRPBatcherProfilerView', BaseView)

function SRPBatcherProfilerView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)
end

function SRPBatcherProfilerView:OnDestroy()
end

function SRPBatcherProfilerView:AddEvent()
end

return SRPBatcherProfilerView
