local DisconnectTypeEnum = require("MainGame/Common/Const/DisconnectTypeEnum")
local ServerTypeEnum = require('MainGame/Common/Const/ServerTypeEnum')
local k_MaxReconnectTimes = 10
local k_ReconnectInterval = 2
ProcedureHandler = ProcedureHandler or {} 

--region 生命周期
-- call by procedureInit
function ProcedureHandler.Init()
    ClientNetManager.RegisterTimeOutCallBack(ProcedureHandler.OnServerNoResponse)
    ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.LoginServer, ProcedureHandler.OnSocketError)
    ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.GameServer, ProcedureHandler.OnSocketError)
end

-- call by procedureInit
function ProcedureHandler.Destroy()
    ClientNetManager.UnRegisterTimeOutCallBack(ProcedureHandler.OnServerNoResponse)
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.LoginServer, ProcedureHandler.OnSocketError)
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.GameServer, ProcedureHandler.OnSocketError)
end
--region


--region 断线重连
function ProcedureHandler.OnServerNoResponse(serverType)
    Logger.LogInfoFormat("[ProcedureHandler](OnServerNoResponse) serverType = {0}", serverType)
    if serverType == ServerTypeEnum.GameServer then
        ProcedureHandler.Disconnect(DisconnectTypeEnum.SocketDisconnect)
    elseif serverType == ServerTypeEnum.LoginServer then
        --返回初始界面
        LoginController.OpenView()
    end
end

function ProcedureHandler.OnSocketError(serverType, errorCode)
    if errorCode == 0 then
       return
    end
    Logger.LogInfoFormat("[ProcedureHandler](OnSocketError) serverType = {0} errorCode = {1}", serverType, errorCode)
    if serverType == ServerTypeEnum.GameServer then
        ProcedureHandler.Disconnect(DisconnectTypeEnum.SocketError)
    end
end

function ProcedureHandler.Disconnect(disconnectType)
    Logger.LogInfoFormat("[ProcedureHandler](Disconnect) disconnectType = {0}", disconnectType)
    -- ClientNetManager.DisconnectLoginServer()
    -- ClientNetManager.DisconnectGameServer()
    ClientNetManager.Disconnect()
    local tipsContent
    local reconnect = false
    if disconnectType == DisconnectTypeEnum.LoginOtherPlace then
        tipsContent = "帐号已在其他地方登录"
    elseif disconnectType == DisconnectTypeEnum.KickPlayer then
        tipsContent = "你已被服务器踢出"
    elseif disconnectType == DisconnectTypeEnum.SocketDisconnect then
        tipsContent = "网络连接已断开，请重新登录"
        reconnect = true
    elseif disconnectType == DisconnectTypeEnum.SocketError then
        tipsContent = "网络异常，请重新登录"
        reconnect = true
    end

    if reconnect then
        if AccountManager.IsCertify() then
            ProcedureHandler.DoReconnect()
        else
            LoginController.OpenView()
        end
    else
        if tipsContent then
            local alertData =
            {
                showLeftButton = false,
                content = tipsContent,
                onConfirmCallback = function()
                    ProcedureManager.ChangeProcedure(ProcedureTypeEnum.Login)
                end
            }
            AlertController.ShowAlert(alertData)
        else
            Logger.LogError("ProcedureHandler.Disconnect：未处理的 disconnectType")
        end
    end
end

-- 重连
function ProcedureHandler.DoReconnect()
    Logger.LogInfoFormat("[ProcedureHandler](DoReconnect) ReconnectTimes = {0}", ProcedureHandler.m_ReconnectTimes)
    if ProcedureHandler.m_ReconnectTimes < k_MaxReconnectTimes then
        ProcedureHandler.m_ReconnectTimes = ProcedureHandler.m_ReconnectTimes + 1
        ProcedureHandler.m_IsReconnecting = true
        WaitingController.OpenWaitingView(ProcedureHandler.IsNotReconnecting)
        if ProcedureHandler.m_ReconnectTimerID then
            TimerManager:RemoveTimer(ProcedureHandler.m_ReconnectTimerID)
        end

        local delayConnectHandle = function()
            ProcedureHandler.m_ReconnectTimerID = nil
            ClientNetManager.UnRegisterConnectCallBack(ServerTypeEnum.GameServer,ProcedureHandler.OnConnectGameServer)
            ClientNetManager.RegisterConnectCallBack(ServerTypeEnum.GameServer, ProcedureHandler.OnConnectGameServer)
            local currentServerInfo = AccountManager.GetCurrentServerInfo()
            ClientNetManager.ConnectGameServer(currentServerInfo.ip, currentServerInfo.port)
        end

        if ProcedureHandler.m_ReconnectTimes > 1 then
            ProcedureHandler.m_ReconnectTimerID = TimerManager:AddTimer(nil, delayConnectHandle, k_ReconnectInterval, 1)
        else
            delayConnectHandle()
        end
    else
        ProcedureHandler.ReconnectFail()
    end
end

-- 重置重连次数
function ProcedureHandler.ResetReconnectTime()
    ProcedureHandler.m_ReconnectTimes = 0
end

-- 游戏服已连接
function ProcedureHandler.OnConnectGameServer()
    Logger.LogInfoFormat("[ProcedureHandler](OnConnectGameServer)")
    local currentProcedureType = ProcedureManager.GetCurrentProcedureType()
    if currentProcedureType ~= ProcedureTypeEnum.CreateRole then
        local hero = ObjectManager.GetHero()
        if hero then
            hero:ResetAllComponents()
        end
        ObjectManager.RemoveAllObjectsExceptHero()
    end
    ClientNetManager.UnRegisterConnectCallBack(ServerTypeEnum.GameServer,ProcedureHandler.OnConnectGameServer)
    ProcedureHandler.ResetReconnectTime()
    local LoginMessage = require("MainGame/Message/LoginMessage")
    local accountData = AccountManager.GetAccountData()
    local certifyKey = AccountManager.GetCertifyKey()
    LoginMessage.SendRequestSessionAlive(accountData.accountId, certifyKey)
end

-- 重连失败
function ProcedureHandler.ReconnectFail()
    Logger.LogInfoFormat("[ProcedureHandler](ReconnectFail)")
    ClientNetManager.UnRegisterConnectCallBack(ServerTypeEnum.GameServer, ProcedureHandler.OnConnectGameServer)
    ProcedureHandler.m_IsReconnecting = false
    local alertData =
    {
        showLeftButton = false,
        content = "尝试自动重连失败, 请重新登录",
        onConfirmCallback = function()
            ProcedureManager.ChangeProcedure(ProcedureTypeEnum.Login)
        end
    }
    AlertController.ShowAlert(alertData)
end

-- 响应会话存活
function ProcedureHandler.OnSessionAliveRet(isAlive)
    if isAlive == 0 then
        ProcedureHandler.ReconnectFail()
    else
        local currentProcedureType = ProcedureManager.GetCurrentProcedureType()
        if currentProcedureType == ProcedureTypeEnum.CreateRole then
            ProcedureHandler.m_IsReconnecting = false
            Logger.LogInfoFormat("[ProcedureHandler](OnSessionAliveRet) reconnect succeed!")
        end
    end
end

-- 玩家信息
function ProcedureHandler.OnReconnect(netBuffer)
    local hero = ObjectManager.GetHero()
    if hero == nil then
        ProcedureHandler.ReconnectFail()
        return
    end

    --
    hero:OnReconnect(netBuffer)
    ProcedureHandler.m_IsReconnecting = false
    Logger.LogInfoFormat("[ProcedureHandler](OnReconnect) reconnect succeed!")
end

function ProcedureHandler.IsNotReconnecting()
    return not ProcedureHandler.m_IsReconnecting
end
--endregion

return ProcedureHandler
