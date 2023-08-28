local WaitingView = class("WaitingView",BaseView)

local k_RotateSpeed = -100  -- 菊花旋转速度
local k_ForceCloseTime = 8  -- 强制关闭时间

--子类重写
function WaitingView:InitUI()	
	self.m_Transform.offsetMin = Vector2.New(0, 0)
	self.m_Transform.offsetMax = Vector2.New(0, 0)

    self.m_TimeId = nil
    self.m_RuningTime = 0
end

--子类重写
function WaitingView:OnOpen()
    if self.m_TimeId == nil then 
        self.m_TimeId = TimerManager:AddFrameTimer(self, self.UpdatePerFrame, 1, 0)
    end
    self.m_RuningTime = 0
end

function WaitingView:UpdatePerFrame()
    self:Rotate()

    local isClose = WaitingController.model:IsCanCloseWaitingView()
    local isForceClose = self.m_RuningTime >= k_ForceCloseTime
    if isClose or isForceClose then 
        self:Close()

        -- if isForceClose then 
        --     AlertController.ShowAlert('等待超时！！')
        -- end
    end
end

function WaitingView:Rotate()
	self.imgWaiting.transform:Rotate(0,0, Time.deltaTime * k_RotateSpeed)

    self.m_RuningTime = self.m_RuningTime + Time.deltaTime
end

function WaitingView:OnClose()
    self:Clean()
end

--子类重写
function WaitingView:BeforeDestroy()
    self:Clean()
end

function WaitingView:Clean()
    if self.m_TimeId ~= nil then 
        TimerManager:RemoveTimer(self.m_TimeId)
        self.m_TimeId = nil
        self.m_RuningTime = 0
    end
end

return WaitingView