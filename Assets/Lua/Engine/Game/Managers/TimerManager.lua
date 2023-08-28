local Core_TimerManagerInstance = SGEngine.Core.TimerManager.Instance
TimerManager = TimerManager or {}

-- example :在外部调用 TimerManager:AddTimer(self,self.Test, 1 , 0, param1,param2)
--添加定时器，self传入自身，callback为调用的函数，interval间隔时间，executeTimes执行次数，0代表无限次，后面传递参数
--返回值 timer id
function TimerManager:AddTimer(objectSelf,callback,interval,executeTimes,...)
    interval = interval or 0
    executeTimes =  executeTimes or 1
    local p1,p2,p3,p4,p5,p6,p7 = ...
    function execute()
        callback(objectSelf, p1, p2, p3, p4, p5, p6, p7)
    end
    return Core_TimerManagerInstance:AddTimer(execute, interval, executeTimes)
end

function TimerManager:AddFrameTimer(objectSelf,callback,intervalFrame,executeTimes,...)
    intervalFrame = intervalFrame or 0
    executeTimes =  executeTimes or 1
    local p1,p2,p3,p4,p5,p6,p7 = ...
    function execute()
        callback(objectSelf, p1, p2, p3, p4, p5, p6, p7)
    end
    return Core_TimerManagerInstance:AddFrameTimer(execute, intervalFrame, executeTimes)
end

--取消定时器，参数是timer id
function TimerManager:RemoveTimer(timerId)
    Core_TimerManagerInstance:RemoveTimer(timerId)
end

function TimerManager:RemoveAll()
    Core_TimerManagerInstance:RemoveAll()
end


return TimerManager