---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2022/9/27 11:43
---
local ServerTypeEnum = require('MainGame/Common/Const/ServerTypeEnum')
local CreateRoleMessage = require("MainGame/Message/CreateRoleMessage")
local DisconnectTypeEnum = require("MainGame/Common/Const/DisconnectTypeEnum")

BfClientManager = BfClientManager or {}
BfClientManager.StageType =
{
    k_None = 0,
    k_GS2BF = 1,
    k_BF2GS = 2,
    k_InBF = 3,
}
function BfClientManager.Init()
    BfClientManager.m_State = BfClientManager.StageType.k_None
    ClientNetManager.RegisterTimeOutCallBack(BfClientManager.OnServerTimeOut)
end

function BfClientManager.OnServerTimeOut(serverType)
    Logger.LogInfoFormat("[ProcedureHandler](OnServerNoResponse) serverType = {0}", serverType)
    if serverType == ServerTypeEnum.BfServer then
        BfClientManager.m_State = BfClientManager.StageType.k_None
        ProcedureHandler.Disconnect(DisconnectTypeEnum.SocketDisconnect)
    end
end

function BfClientManager.OnGameToBfBegin(buffer)
    Logger.LogInfo("[BfClientManager](OnGameToBfBegin)")
    BfClientManager.m_GameServerID = buffer:ReadInt()
    BfClientManager.m_BfIP = buffer:ReadString()
    BfClientManager.m_BfPort = buffer:ReadUShort()
    BfClientManager.m_BfCertifyCode = buffer:ReadInt()
    BfClientManager.m_State = BfClientManager.StageType.k_GS2BF

    local buffer = ClientNetManager.GetSendBuffer(Message.PT_SEND_MIGRATE_BEGIN_SUCC)
    ClientNetManager.Send(buffer)
    --ClientNet.on_disconnect_ -= ClientNet.Instance.try_to_reconnect
    --ClientNet.on_disconnect_ += on_game_server_disconnect
    NetManager.m_OnClientDisconnect = BfClientManager.OnGameServerDisconnect
    --ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.GameServer, BfClientManager.OnGameServerDisconnect)
end

function BfClientManager.OnGameServerDisconnect(sessionInfo)
    if sessionInfo == nil then
        return
    end
    sessionInfo.isConnected = false
    local serverType = sessionInfo.serverType
    if serverType == ServerTypeEnum.GameServer then
        --ClientNet.on_disconnect_ -= on_game_server_disconnect;
        ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.GameServer, BfClientManager.OnGameServerDisconnect)
        --ClientNet.on_disconnect_ -= ClientNet.Instance.try_to_reconnect;
        --ClientNet.on_disconnect_ += ClientNet.Instance.try_to_reconnect;
        --ClientNet.on_connected_ += on_bf_server_connected;
        NetManager.m_OnClientDisconnect = ClientNetManager.OnDisconnect
        ClientNetManager.RegisterConnectCallBack(ServerTypeEnum.BfServer, BfClientManager.OnBfServerConnect)
        ClientNetManager.ConnectBfServer(BfClientManager.m_BfIP, BfClientManager.m_BfPort)
        --WaitingUI.Show(() => UIManager.Instance.IsUIActive(UIConfig.InstanceLoadingUI));
        Logger.LogInfo("[BfClientManager](OnGameServerDisconnect)")
    end
end

function BfClientManager.OnBfServerConnect()
    ClientNetManager.UnRegisterConnectCallBack(ServerTypeEnum.BfServer, BfClientManager.OnBfServerConnect)
    ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.BfServer, BfClientManager.OnBfServerConnectError)
    local createRoleModel = CreateRoleController.model
    local playerInfo = createRoleModel:GetLastJoinOrFirstPlayerInfo()
    Logger.LogInfo("[BfClientManager](OnBfServerConnect), send ask, player id:%s", playerInfo.playerID)
    local buffer = ClientNetManager.GetSendBuffer(Message.PT_ASK_BF_REGISTER_DPID)
    buffer:WriteInt(BfClientManager.m_GameServerID)
    buffer:WriteUInt(playerInfo.playerID)
    buffer:WriteInt(BfClientManager.m_BfCertifyCode)
    ClientNetManager.Send(buffer)
    BfClientManager.m_State = BfClientManager.StageType.k_InBF

    ObjectManager.Restart()
    SGEngine.Core.ObjectManager.Instance:Restart()

    --ObjManager.Instance.clear_hero()
end

function BfClientManager.OnGameToBfFailed(buffer)
    local stateType = BfClientManager.StageType
    if BfClientManager.m_State == stateType.k_GS2BF then
        BfClientManager.m_State = stateType.k_None
        NetManager.m_OnClientDisconnect = ClientNetManager.OnDisconnect
        Logger.LogInfo("[BfClientManager](OnMigrateBfFailed)")
    end
end

function BfClientManager.OnBfToGameBegin(buffer)
    BfClientManager.m_Bf2GsCertifyCode = buffer:ReadInt()
    BfClientManager.m_State = BfClientManager.StageType.k_BF2GS
    local buffer = ClientNetManager.GetSendBuffer(Message.PT_SEND_REJOIN_BEGIN_SUCC)
    ClientNetManager.Send(buffer)
    AccountManager.SetCertify(BfClientManager.m_Bf2GsCertifyCode)
    NetManager.m_OnClientError = nil
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.BfServer, BfClientManager.OnBfServerConnectError)
    ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.BfServer, BfClientManager.OnBfServerDisconnect)
end

function BfClientManager.OnBfServerConnectError(serverType, errorCode)
    Logger.LogInfo("[BfClientManager](OnBfServerConnectError)")
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.BfServer, BfClientManager.OnBfServerConnectError)
    if errorCode == 203 then
        BfClientManager.m_State = BfClientManager.StageType.k_None
        ProcedureHandler.Disconnect(DisconnectTypeEnum.SocketError)
    end
end

function BfClientManager.OnBfServerDisconnect(serverType, errorCode)
    Logger.LogInfo("[BfClientManager](OnBfServerDisconnect)")
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.BfServer, BfClientManager.OnBfServerDisconnect)
    --ClientNet.on_disconnect_ -= on_bf_server_disconnect
    --ClientNet.on_disconnect_ -= ClientNet.Instance.try_to_reconnect
    --ClientNet.on_disconnect_ += ClientNet.Instance.try_to_reconnect
    --ClientNet.on_connected_ += on_game_server_connected
    ClientNetManager.RegisterConnectCallBack(ServerTypeEnum.GameServer, BfClientManager.OnGameServerConnect)
    local currentServerInfo = AccountManager.GetCurrentServerInfo()
    ClientNetManager.ConnectGameServer(currentServerInfo.ip, currentServerInfo.port)
    --WaitingUI.Show(() => UIManager.Instance.IsUIActive(UIConfig.SceneLoadingUI) || UIManager.Instance.IsUIActive(UIConfig.InstanceLoadingUI))
end

function BfClientManager.OnGameServerConnect()
    NetManager.m_OnClientError = ClientNetManager.OnError
    ClientNetManager.UnRegisterConnectCallBack(ServerTypeEnum.GameServer, BfClientManager.OnGameServerConnect)
    local createRoleModel = CreateRoleController.model
    local playerInfo = createRoleModel:GetLastJoinOrFirstPlayerInfo()
    Logger.LogInfo("[BfClientManager](OnGameServerConnect), send rejoin, player id:%s", playerInfo.playerID)
    local buffer = ClientNetManager.GetSendBuffer(Message.PT_REJOIN)
    buffer:WriteUInt(playerInfo.playerID)
    buffer:WriteInt(BfClientManager.m_Bf2GsCertifyCode)
    CreateRoleMessage.SerializeSDK(buffer)
    ClientNetManager.Send(buffer)
    BfClientManager.m_State = BfClientManager.StageType.k_None
    ObjectManager.Restart()
    SGEngine.Core.ObjectManager.Instance:Restart()
end

function BfClientManager.Destroy()
end

function BfClientManager.OnReconnectFromBf()

end

function BfClientManager.ThisIsAnUnusedProtocol()

end

function BfClientManager.SendPlayerBackToGame()
    if BfClientManager.m_State == BfClientManager.StageType.k_None then
        return
    end
    local createRoleModel = CreateRoleController.model
    local playerInfo = createRoleModel:GetLastJoinOrFirstPlayerInfo()
    GmMessage.SendGmCommand("send_player_back_to_game", string.format("%d %d", playerInfo.playerID, BfClientManager.m_GameServerID))
end

function BfClientManager.SendPlayerToBf()
    if BfClientManager.m_State == BfClientManager.StageType.k_InBF then
        return
    end
    local createRoleModel = CreateRoleController.model
    local playerInfo = createRoleModel:GetLastJoinOrFirstPlayerInfo()
    GmMessage.SendGmCommand("send_player_to_bf", string.format("%d %d", playerInfo.playerID, 0))
end

function BfClientManager.GetState()
    return BfClientManager.m_State
end

return BfClientManager