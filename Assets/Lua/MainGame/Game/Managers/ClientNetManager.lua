ClientNetManager = ClientNetManager or {}
local ServerTypeEnum = require('MainGame/Common/Const/ServerTypeEnum')
local SocketOptionLevel = System.Net.Sockets.SocketOptionLevel
local SocketOptionName = System.Net.Sockets.SocketOptionName
local Time = UnityEngine.Time
local GameConfig = SGEngine.Core.Main.GameConfig
function ClientNetManager.Init()
    ClientNetManager.m_LastReceivePingTime = math.huge
    ClientNetManager.m_DisconnectPingStep = 15
    ClientNetManager.m_RTT = 0
    ClientNetManager.m_CurrentSocketID = nil
    ClientNetManager.m_CurrentServerType = ServerTypeEnum.None

    ClientNetManager.m_OnLoginServerDisconnectCallBackList = {}
    ClientNetManager.m_OnGameServerDisconnectCallBackList = {}
    ClientNetManager.m_OnBfServerDisconnectCallBackList = {}

    ClientNetManager.m_OnLoginServerConnectCallBackList = {}
    ClientNetManager.m_OnGameServerConnectCallBackList = {}
    ClientNetManager.m_OnBfServerConnectCallBackList = {}

    ClientNetManager.m_OnTimeOutDisconnectCallBackList = {}
    ClientNetManager.m_SendBuffer = SGEngine.Net.NetBuffer.Pop()

    NetManager.Register(Message.ST_PING, ClientNetManager.OnReceivePing)
    NetManager.m_OnClientConnect = ClientNetManager.OnConnect
    NetManager.m_OnClientDisconnect = ClientNetManager.OnDisconnect
    NetManager.m_OnClientUpdate = ClientNetManager.OnUpdate
end

function ClientNetManager.Destroy()
    ClientNetManager.m_CurrentSocketID = nil
    ClientNetManager.m_CurrentServerType = ServerTypeEnum.None
    ClientNetManager.m_OnLoginServerDisconnectCallBackList = nil
    ClientNetManager.m_OnGameServerDisconnectCallBackList = nil
    ClientNetManager.m_OnBfServerDisconnectCallBackList = nil

    ClientNetManager.m_OnLoginServerConnectCallBackList = nil
    ClientNetManager.m_OnGameServerConnectCallBackList = nil
    ClientNetManager.m_OnBfServerConnectCallBackList = nil

    ClientNetManager.m_OnTimeOutDisconnectCallBackList = nil
    
    NetManager.UnRegister(Message.ST_PING, ClientNetManager.OnReceivePing)
    NetManager.m_OnClientConnect = nil
    NetManager.m_OnClientDisconnect = nil
    NetManager.m_OnClientUpdate = nil
end

----------------------------------------------------------------------------------------------------------------------------------------------
function ClientNetManager.OnConnect(sessionInfo)
    ClientNetManager.Disconnect()
    sessionInfo.isConnected = true
    local socketID = sessionInfo.socketID
    local serverType = sessionInfo.serverType
    NetManager.SetSocketOption(socketID, SocketOptionLevel.Tcp, SocketOptionName.NoDelay, GameConfig.openNoDelay)
    ClientNetManager.SetCurrentSocketInfo(socketID, serverType)
    if serverType == ServerTypeEnum.LoginServer then
        ClientNetManager.Invoke(ClientNetManager.m_OnLoginServerConnectCallBackList, socketID)
    elseif serverType == ServerTypeEnum.GameServer then
        ClientNetManager.Invoke(ClientNetManager.m_OnGameServerConnectCallBackList, socketID)
    elseif serverType == ServerTypeEnum.BfServer then
        ClientNetManager.Invoke(ClientNetManager.m_OnBfServerConnectCallBackList, socketID)
    end
end

function ClientNetManager.OnDisconnect(sessionInfo, errorCode)
    if sessionInfo == nil then
        return
    end
    sessionInfo.isConnected = false
    local serverType = sessionInfo.serverType
    local socketID = sessionInfo.socketID
    ClientNetManager.OnError(errorCode)
    if serverType == ServerTypeEnum.LoginServer then
        ClientNetManager.Invoke(ClientNetManager.m_OnLoginServerDisconnectCallBackList, serverType, errorCode)
    elseif serverType == ServerTypeEnum.GameServer then
        ClientNetManager.Invoke(ClientNetManager.m_OnGameServerDisconnectCallBackList, serverType, errorCode)
    elseif serverType == ServerTypeEnum.BfServer then
        ClientNetManager.Invoke(ClientNetManager.m_OnBfServerDisconnectCallBackList, serverType, errorCode)
    end
end

function ClientNetManager.OnUpdate()
    if Time.unscaledTime - ClientNetManager.m_LastReceivePingTime >= ClientNetManager.m_DisconnectPingStep then
        ClientNetManager.m_LastReceivePingTime = math.huge
        ClientNetManager.HandlePingTimeOut()
    end
end

function ClientNetManager.SendPing()

end

function ClientNetManager.HandlePingTimeOut()
    Logger.LogInfo("HandlePingTimeOut")
    if ClientNetManager.m_CurrentServerType == ServerTypeEnum.GameServer then
        ClientNetManager.Disconnect()
        ClientNetManager.Invoke(ClientNetManager.m_OnTimeOutDisconnectCallBackList, ServerTypeEnum.GameServer)
    elseif ClientNetManager.m_CurrentServerType == ServerTypeEnum.LoginServer then
        ClientNetManager.Disconnect()
        ClientNetManager.Invoke(ClientNetManager.m_OnTimeOutDisconnectCallBackList, ServerTypeEnum.LoginServer)
    elseif ClientNetManager.m_CurrentServerType == ServerTypeEnum.BfServer then
        ClientNetManager.Disconnect()
        ClientNetManager.Invoke(ClientNetManager.m_OnTimeOutDisconnectCallBackList, ServerTypeEnum.BfServer)
    end
end

function ClientNetManager.OnError(errorCode)
    if errorCode == 0 then
       return
    end

    local errorcodeStr = ClientNetManager.GetErrorCodeMessage(errorCode)
    if errorcodeStr == nil then
        errorcodeStr = errorCode
    end
    Logger.Error("[ClientNetManager](OnError) errorCode: " .. errorcodeStr)
end

function ClientNetManager.GetServerType(socketID)
    return NetManager.GetServerType(socketID)
end

function ClientNetManager.GetCurrentServerType()
    return ClientNetManager.m_CurrentServerType
end

function ClientNetManager.OnReceivePing(buffer)
    ClientNetManager.m_LastReceivePingTime = Time.unscaledTime
    local rtt = NetManager.GetRTT()
    local OpView = UIManager.GetUI("OpView")
    if OpView then
        OpView:SetRtt(string.format("RTT: %.0fms", rtt))
    end
end

function ClientNetManager.Register(protocolID, callBack)
    NetManager.Register(protocolID, callBack)
end

function ClientNetManager.UnRegister(protocolID, callBack)
    NetManager.UnRegister(protocolID, callBack)
end

function ClientNetManager.ConnectLoginServer(serverHost, serverPort)
    NetManager.Connect(ServerTypeEnum.LoginServer, serverHost, serverPort)
end

function ClientNetManager.ConnectGameServer(serverHost, serverPort)
    NetManager.Connect(ServerTypeEnum.GameServer, serverHost, serverPort)
end

function ClientNetManager.ConnectBfServer(serverHost, serverPort)
    NetManager.Connect(ServerTypeEnum.BfServer, serverHost, serverPort)
end

function ClientNetManager.GetSendBuffer(protocolID)
    local buffer = ClientNetManager.m_SendBuffer
    buffer:FlushBeforeSend(protocolID)
    return buffer
end

function ClientNetManager.Send(buffer)
    if ClientNetManager.m_CurrentSocketID == nil then
        return
    end
    NetManager.Send(buffer, ClientNetManager.m_CurrentSocketID)
end

function ClientNetManager.Disconnect()
    if ClientNetManager.m_CurrentSocketID == nil then
        return
    end
    NetManager.Close(ClientNetManager.m_CurrentSocketID)
    ClientNetManager.SetCurrentSocketInfo(nil, ServerTypeEnum.None)    
end

function ClientNetManager.RegisterDisconnectCallBack(serverType, callBack)
    if serverType == ServerTypeEnum.LoginServer then
        ClientNetManager.RegisterCallBack(ClientNetManager.m_OnLoginServerDisconnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.GameServer then
        ClientNetManager.RegisterCallBack(ClientNetManager.m_OnGameServerDisconnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.BfServer then
        ClientNetManager.RegisterCallBack(ClientNetManager.m_OnBfServerDisconnectCallBackList, callBack)
    end
end

function ClientNetManager.UnRegisterDisconnectCallBack(serverType, callBack)
    if serverType == ServerTypeEnum.LoginServer then
        ClientNetManager.UnRegisterCallBack(ClientNetManager.m_OnLoginServerDisconnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.GameServer then
        ClientNetManager.UnRegisterCallBack(ClientNetManager.m_OnGameServerDisconnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.BfServer then
        ClientNetManager.UnRegisterCallBack(ClientNetManager.m_OnBfServerDisconnectCallBackList, callBack)
    end
end

function ClientNetManager.RegisterConnectCallBack(serverType, callBack)
    if serverType == ServerTypeEnum.LoginServer then
        ClientNetManager.RegisterCallBack(ClientNetManager.m_OnLoginServerConnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.GameServer then
        ClientNetManager.RegisterCallBack(ClientNetManager.m_OnGameServerConnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.BfServer then
        ClientNetManager.RegisterCallBack(ClientNetManager.m_OnBfServerConnectCallBackList, callBack)
    end
end

function ClientNetManager.UnRegisterConnectCallBack(serverType, callBack)
    if serverType == ServerTypeEnum.LoginServer then
        ClientNetManager.UnRegisterCallBack(ClientNetManager.m_OnLoginServerConnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.GameServer then
        ClientNetManager.UnRegisterCallBack(ClientNetManager.m_OnGameServerConnectCallBackList, callBack)
    elseif serverType == ServerTypeEnum.BfServer then
        ClientNetManager.UnRegisterCallBack(ClientNetManager.m_OnBfServerConnectCallBackList, callBack)
    end
end

function ClientNetManager.RegisterTimeOutCallBack(callBack)
    ClientNetManager.RegisterCallBack(ClientNetManager.m_OnTimeOutDisconnectCallBackList, callBack)
end

function ClientNetManager.UnRegisterTimeOutCallBack(callBack)
    ClientNetManager.UnRegisterCallBack(ClientNetManager.m_OnTimeOutDisconnectCallBackList, callBack)
end

function ClientNetManager.Invoke(callBackList, arg1, arg2)
    if callBackList ~= nil and next(callBackList) ~= nil then
        for tempCallBack, v in pairs(callBackList) do
            tempCallBack(arg1, arg2)
        end
    end
end

function ClientNetManager.RegisterCallBack(callBackList, callBack)
    if callBackList == nil then
        callBackList = {}
    end
    if callBackList[callBack] then
        Logger.Error("[ClientNetManager](RegisterCallBack) the same callback please check")
        return
    end
    callBackList[callBack] = true
end

function ClientNetManager.UnRegisterCallBack(callBackList, callBack)
    if callBackList == nil then
        return
    end
    if callBackList[callBack] then
       callBackList[callBack] = nil
    end
end

function ClientNetManager.GetErrorCodeMessage(errorCode)
    return NetErrorCodeEnum[errorCode]
end

function ClientNetManager.SetCurrentSocketInfo(socketID, serverType)
    ClientNetManager.m_CurrentSocketID = socketID
    ClientNetManager.m_CurrentServerType = serverType
end

return ClientNetManager
