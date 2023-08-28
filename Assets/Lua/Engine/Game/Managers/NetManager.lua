local Core_NetManager = SGEngine.Net.ClientNetManager
NetManager = NetManager or {}
--local pb = require "pb"
--local labelPb = "ProtobufMsg"
local Time = UnityEngine.Time
local ServerTypeEnum = require('MainGame/Common/Const/ServerTypeEnum')
local GameConfig = SGEngine.Core.Main.GameConfig
function NetManager.Init()
    if not GameConfig.useNetwork then
        return
    end

    --[[
    ResourceManager.LoadTextAssetsToBytesAsync(labelPb, function(prototext)
        assert(pb.load(tolua.tolstring(prototext)))
    end)
    ]]

    NetManager.m_CallBackMap = {} -- key:opcode value:callBack
    NetManager.m_SessionInfos = {}
    NetManager.m_IsConnected = false
    NetManager.m_SocketID = 0 -- 这里如果多socket连接 需要维护一个列表或者多个变量，一个连接 就报存这一个变量就行了
    NetManager.m_OnClientConnect = nil
    NetManager.m_OnClientDisconnect = nil
    NetManager.m_OnClientUpdate = nil
    NetManager.m_RecvBuffer = SGEngine.Net.NetBuffer.Pop()

    Core_NetManager.Instance:Init()
    Core_NetManager.Instance:RegisterDispatch(NetManager.Dispatch)
    Core_NetManager.Instance:RegisterConnect(NetManager.OnConnect)
    Core_NetManager.Instance:RegisterDisconnect(NetManager.OnDisconnect)

    NetManager.Register(Message.ST_SNAPSHOT, NetManager.OnSnapShot)

    ClientNetManager.Init()
    MessageManager.Init()
end

function NetManager.Destroy()
    if not GameConfig.useNetwork then
        return
    end
    Core_NetManager.Instance:Destory()
    Core_NetManager.Instance:UnRegisterDispatch(NetManager.Dispatch)
    Core_NetManager.Instance:UnRegisterConnect(NetManager.OnConnect)
    Core_NetManager.Instance:UnRegisterDisconnect(NetManager.OnDisconnect)
    NetManager.UnRegister(Message.ST_SNAPSHOT, NetManager.OnSnapShot)
    MessageManager.Destroy()
    NetManager.m_SocketID = 0
    NetManager.m_SessionInfos = {}
end

-- 注册lua层协议
function NetManager.Register(protocolID, callBack)
    if not GameConfig.useNetwork then
        return
    end
    if not protocolID then
        Logger.Error(string.format("[NetManager](Register)Lua: 未知的协议号:{0}", protocolID))
        return
    end
    NetManager.m_CallBackMap[protocolID] = callBack
end

-- 取消注册lua层协议
function NetManager.UnRegister(protocolID, callBack)
    if not protocolID then
        Logger.Error(string.format("[NetManager](UnRegister)Lua: 未知的协议号:{0}", protocolID))
        return
    end
    NetManager.m_CallBackMap[protocolID] = nil
end

-- 发送lua消息
function NetManager.Send(buffer, socketID)
    if not GameConfig.useNetwork then
        return
    end
    if socketID == nil then
        Core_NetManager.Instance:Send(buffer, NetManager.m_SocketID)
    else
        Core_NetManager.Instance:Send(buffer, socketID)
    end
end

-- 连接网络
function NetManager.Connect(serverType, serverHost, serverPort)
    if not GameConfig.useNetwork then
        return
    end
    local socketID = Core_NetManager.Instance:Connect(serverHost, serverPort, GameConfig.protocolTypeIndex)
    NetManager.m_SessionInfos[socketID] = {
        socketID = socketID,
        serverType = serverType,
        host = serverHost,
        port = serverPort,
        isConnected = false
    }
    return socketID
end

function NetManager.Close(socketID)
    Core_NetManager.Instance:Close(socketID)
end

function NetManager.Dispatch(protocolID, buffer)
    local callBack = NetManager.m_CallBackMap[protocolID]
    if callBack ~= nil then
        -- local buffer = NetManager.m_RecvBuffer
        -- buffer:SetProtocolID(protocolID, -1)
        -- buffer:Reset()
        -- buffer:WriteByteArray(message)
        callBack(buffer)
    else
        Logger.Error("[NetManager](Dispatch)ProtocolID No CallBack, Please RegisterCallBack!  protocolID: 0x%X",
            protocolID)
    end
end

function NetManager.Update()
    if not GameConfig.useNetwork then
        Logger.Warn("[NetManager](Update)No Use Network!")
        return
    end
    --Core_NetManager.Instance:Update()
    if NetManager.m_OnClientUpdate ~= nil then
        NetManager.m_OnClientUpdate(socketID)
    end
end

function NetManager.OnSnapShot(buffer)
    local cb = buffer:ReadUShort()
    if cb == nil or cb == 0 then
        return
    end
    for i = 1, cb do
        local protocolID = buffer:ReadUByte()
        buffer:SetProtocolID(Message.ST_SNAPSHOT, protocolID)
        local callBack = NetManager.m_CallBackMap[protocolID]
        if callBack ~= nil then
           callBack(buffer)
        else
            Logger.Error("[NetManager](OnSnapShot)ProtocolID No CallBack, Please RegisterCallBack!  protocolID: 0x%X",
                protocolID)
        end
    end
end

function NetManager.OnConnect(socketID)
    NetManager.m_SocketID = socketID
    NetManager.m_IsConnected = true
    for k, v in pairs(NetManager.m_SessionInfos) do
        if v.socketID == socketID then
            if NetManager.m_OnClientConnect ~= nil then
                NetManager.m_OnClientConnect(v)
            end
            break
        end
    end
end

function NetManager.OnDisconnect(socketID, errorCode)
    local removeSocketID = nil
    for k, v in pairs(NetManager.m_SessionInfos) do
        if v.socketID == socketID then
            if NetManager.m_OnClientDisconnect ~= nil then
                NetManager.m_OnClientDisconnect(v, errorCode)
            end
            break
        end
    end
end

function NetManager.GetServerType(socketID)
    local sessionInfo = NetManager.m_SessionInfos[socketID]
    if sessionInfo ~= nil then
        return sessionInfo.serverType
    end
    return nil
end

function NetManager.IsConnected(socketID)
    if socketID == nil then
        return false
    end
    return Core_NetManager.Instance:IsConnected(socketID)
end

function NetManager.ProtocolSerialize(protocolName, message)
    return pb.encode(protocolName, message or table.Empty)
end

function NetManager.ProtocolDeserialize(protocolName, messageBuffer)
    return assert(pb.decode(protocolName, tolua.tolstring(messageBuffer)));
end

function NetManager.GetProtoName(protocolID)
    return OpCodeTypeEnum.OpCode2Name[protocolID]
end

function NetManager.GetRTT()
    return Core_NetManager.Instance:GetRTT()
end

function NetManager.SetSocketOption(socketID, socketOptionLevel, socketOptionName, value)
    Core_NetManager.Instance:SetSocketOption(socketID, socketOptionLevel, socketOptionName, value)
end

function NetManager.GetSocketOption(socketID, optionLevel, optionName)
    return Core_NetManager.Instance:GetSocketOption(socketID, optionLevel, optionName)
end

return NetManager
