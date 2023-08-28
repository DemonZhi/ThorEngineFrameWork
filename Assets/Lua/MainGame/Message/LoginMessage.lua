local DisconnectTypeEnum = require("MainGame/Common/Const/DisconnectTypeEnum")
 
LoginMessage = LoginMessage or {}
local k_PlatformIOS = 1
local k_PlatformAndroid = 2
local k_PlatformEditor = 3
local ServerStatus = {
    Maintain = 4,
    Recommend = 5
}

local k_LoginAccountVerifyFailed = 200
local k_LoginSDKLoginFailed = 201
local k_LoginAccountNotFound = 202
local k_LoginAccountForbid = 203
local k_LoginAccountTimeout = 204
local k_LoginVersionNotMatch = 205
local k_LoginGameserverMaintaining = 206
local k_LoginMachineForbid = 207
local k_LoginNeedActiveCode = 208
local k_LoginActiveInvalid = 209

local errorString = {
    [k_LoginAccountVerifyFailed] = "登录出错，账号验证失败！",
    [k_LoginSDKLoginFailed] = "登录出错，SDK登录失败！",
    [k_LoginAccountNotFound] = "登录出错，不存在账号！",
    [k_LoginAccountForbid] = "登录出错，账号禁止登录！",
    [k_LoginAccountTimeout] = "登录出错，账号登录超时！",
    [k_LoginVersionNotMatch] = "登录出错，版本不匹配！",
    [k_LoginGameserverMaintaining] = "登录出错，服务器正在维护！",
    [k_LoginMachineForbid] = "登录出错，设备禁止登录！",
    [k_LoginNeedActiveCode] = "登录出错，需要激活码！",
    [k_LoginActiveInvalid] = "登录出错，激活码不存在！",
}

function LoginMessage.Init()
    NetManager.Register(Message.ST_SERVER_INFO, LoginMessage.OnServerInfo)
    NetManager.Register(Message.LC_TYPE_SERVER_LIST, LoginMessage.OnTypeServerList)
    NetManager.Register(Message.LC_TYPE_LOGIN_RESULT, LoginMessage.OnTypeLoginResult)
    NetManager.Register(Message.ST_CERTIFY_RESULT, LoginMessage.OnCertifyResult)
    NetManager.Register(Message.LC_TYPE_SERVER_PLAYER_NUM, LoginMessage.OnTypeServerPlayerNum)
    NetManager.Register(Message.ST_LOGIN_CLOSE_SESSION_RET, LoginMessage.OnLoginCloseSessionRet)
    NetManager.Register(Message.ST_ALREADY_LOGIN_OTHER, LoginMessage.OnAlreadyLoginOther)
    NetManager.Register(Message.ST_LOGIN_OTHER_PLACE, LoginMessage.OnLoginOtherPlace)
    NetManager.Register(Message.ST_LOGIN_SESSION_ALIVE_RET, LoginMessage.OnLoginSessionAliveRet)
    NetManager.Register(Message.ST_LOGIN_ERR, LoginMessage.OnLoginErr)
    NetManager.Register(Message.ST_KICK_PLAYER, LoginMessage.OnKickPlayer)
    NetManager.Register(Message.ST_RECONNECT, LoginMessage.OnReconnect)

    -- miniserver
    --NetManager.Register(OpCodeTypeEnum.SC_Login_Result, LoginMessage.OnLogin)
end

function LoginMessage.Destroy()
    NetManager.UnRegister(Message.ST_SERVER_INFO, LoginMessage.OnServerInfo)
    NetManager.UnRegister(Message.LC_TYPE_SERVER_LIST, LoginMessage.OnTypeServerList)
    NetManager.UnRegister(Message.LC_TYPE_LOGIN_RESULT, LoginMessage.OnTypeLoginResult)
    NetManager.UnRegister(Message.ST_CERTIFY_RESULT, LoginMessage.OnCertifyResult)
    NetManager.UnRegister(Message.LC_TYPE_SERVER_PLAYER_NUM, LoginMessage.OnTypeServerPlayerNum)
    NetManager.UnRegister(Message.ST_LOGIN_CLOSE_SESSION_RET, LoginMessage.OnLoginCloseSessionRet)
    NetManager.UnRegister(Message.ST_ALREADY_LOGIN_OTHER, LoginMessage.OnAlreadyLoginOther)
    NetManager.UnRegister(Message.ST_LOGIN_OTHER_PLACE, LoginMessage.OnLoginOtherPlace)
    NetManager.UnRegister(Message.ST_LOGIN_SESSION_ALIVE_RET, LoginMessage.OnLoginSessionAliveRet)
    NetManager.UnRegister(Message.ST_LOGIN_ERR, LoginMessage.OnLoginErr)
    NetManager.UnRegister(Message.ST_KICK_PLAYER, LoginMessage.OnKickPlayer)
    NetManager.UnRegister(Message.ST_RECONNECT, LoginMessage.OnReconnect)

    -- miniserver
    --NetManager.UnRegister(OpCodeTypeEnum.SC_Login_Result, LoginMessage.OnLogin)
end

--region miniserver
function LoginMessage.SendLogin()
    local accName = 'acc'
    local buffer = ClientNetManager.GetSendBuffer(OpCodeTypeEnum.CS_Login)
    buffer:WriteString(accName)
    --ClientNetManager.SendMessageToLoginServer()
    ClientNetManager.Send(buffer)
end

function LoginMessage.OnLogin(buffer)
    local secretKey = buffer:ReadInt()
    NetManager.SetSocketSecretKey(secretKey)
    local buffer = ClientNetManager.GetSendBuffer(OpCodeTypeEnum.CS_Test_Add_Obj)
    --ClientNetManager.SendMessageToLoginServer()
    ClientNetManager.Send(buffer)
end
--endregion

function LoginMessage.OnServerInfo(buffer)
    local isDebug = buffer:ReadUByte() ~= 0
    local isOpenNewbieGuild = buffer:ReadUByte() ~= 0
    local gameArea = buffer:ReadString()
    local isEnableChatVoice = buffer:ReadUByte() ~= 0

end

function LoginMessage.OnTypeServerList(buffer)
    Logger.LogInfoFormat("[LoginMessage](OnTypeServerList)")
    local serverInfos = {}
    local serverNum = buffer:ReadInt() --服务器数量
    for i = 1, serverNum do
        local serverInfo = {}
        serverInfo.serverId = buffer:ReadInt()
        serverInfo.serverName = buffer:ReadString()
        serverInfo.startDateTimestamp = buffer:ReadUInt()
        serverInfo.ip = buffer:ReadString()
        serverInfo.port = buffer:ReadInt()
        serverInfo.zoneId = buffer:ReadUShort()
        serverInfo.status = buffer:ReadUByte()
        serverInfo.isShow = buffer:ReadUByte() == 1

        --默认选服逻辑
        if serverInfo.isShow then
            if serverInfo.status == ServerStatus.Recommend then
            end
        else
        end
        table.insert(serverInfos, serverInfo)
    end

    --排序

    --区组
    local zoneGroupInfos = {}
    local zoneGroupNum = buffer:ReadInt()
    for i = 1, zoneGroupNum do
        local zoneGroupInfo = {}
        zoneGroupInfo.zoneGoupId = buffer:ReadUShort()
        zoneGroupInfo.zoneName = buffer:ReadString()
        zoneGroupInfo.minZoneNum = buffer:ReadUShort()
        zoneGroupInfo.maxZoneNum = buffer:ReadUShort()
        zoneGroupInfo.groupServerList = {}
        for j = 1, #serverInfos do
            local serverInfo = serverInfos[j]
            if zoneGroupInfo.minZoneNum <= serverInfo.zoneId and serverInfo.zoneId <= zoneGroupInfo.maxZoneNum then
                table.insert(zoneGroupInfo.groupServerList, serverInfo)
            end
        end
        table.insert(zoneGroupInfos, zoneGroupInfo)
    end
    AccountManager.SetServerInfos(serverInfos)
end

function LoginMessage.SendTypeGetServerInfo()
    local buffer = ClientNetManager.GetSendBuffer(Message.CL_TYPE_GET_SERVER_INFO)
    --ClientNetManager.SendMessageToLoginServer()
    ClientNetManager.Send(buffer)
end

function LoginMessage.SendTypeLogin(
    uid,
    macineCode,
    channelAccount,
    channelId,
    channelLabel,
    sdkTimeStamp,
    sdkSign,
    version,
    serverId,
    puid,
    sdkPlatformTag,
    activeCode)
    local buffer = ClientNetManager.GetSendBuffer(Message.CL_TYPE_LOGIN)
    buffer:WriteDouble(uid)
    buffer:WriteString(macineCode)
    buffer:WriteString(channelAccount)
    buffer:WriteString(channelId)
    buffer:WriteString(channelLabel)
    buffer:WriteString(sdkTimeStamp)
    buffer:WriteString(sdkSign)
    buffer:WriteUByte(k_PlatformEditor)
    buffer:WriteInt(version)
    buffer:WriteInt(serverId)
    buffer:WriteString(puid)
    buffer:WriteString('10SWCTO1WW(LENOVO)')
    buffer:WriteString('Windows 10 (10.0.18363) 64bit')
    buffer:WriteString(sdkPlatformTag)
    buffer:WriteString(activeCode)
    --ClientNetManager.SendMessageToLoginServer()
    ClientNetManager.Send(buffer)
    LoginMessage.m_IsOnTypeLoginResult = false
    WaitingController.OpenWaitingView(function()
        return LoginMessage.m_IsOnTypeLoginResult
    end)
end

function LoginMessage.OnTypeLoginResult(buffer)
    Logger.LogInfo("[LoginMessage](OnTypeLoginResult) OnTypeLoginResult CallBackSucess")
    LoginMessage.m_IsOnTypeLoginResult = true
    local loginResult = buffer:ReadShort()
    local accountId = buffer:ReadDouble()
    local loginToken = buffer:ReadInt()

    if loginResult == 0 then
        local accountData = {}
        accountData.accountId = accountId
        accountData.loginToken = loginToken
        AccountManager.SetAccountData(accountData)
        ProcedureLogin.OnTypeLoginResult(loginResult, accountData)
    else
        ProcedureLogin.OnTypeLoginResult(loginResult, errorString[loginResult])
    end
end

function LoginMessage.SendCertify()
    Logger.LogInfo("[LoginMessage](SendCertify) SendCertify to GameServer")
    local accountData = AccountManager.GetAccountData()

    local buffer = ClientNetManager.GetSendBuffer(Message.PT_CERTIFY)
    buffer:WriteDouble(accountData.accountId)
    buffer:WriteInt(accountData.loginToken)

    ClientNetManager.Send(buffer)
end

function LoginMessage.OnCertifyResult(buffer)
    local certifyCode = buffer:ReadUShort()
    local certifyKey = buffer:ReadInt()
    local extParam = buffer:ReadInt()
    Logger.LogInfo("[LoginMessage](OnCertifyResult) certify code:"..certifyCode)
    ProcedureLogin.OnCertify(certifyCode)

    if certifyCode == 0 then
        AccountManager.SetCertify(certifyKey)
    end
end

function LoginMessage.OnTypeServerPlayerNum(buffer)
    Logger.LogInfoFormat("[LoginMessage](OnTypeServerPlayerNum)")
    local serverBusyPlayerNum = buffer:ReadInt()
    local serverHotPlayerNum = buffer:ReadInt()
    local serverNum = buffer:ReadInt()
    for i = 1, serverNum do
        local serverId = buffer:ReadInt()
        local playerNum = buffer:ReadInt()
        local serverInfo = AccountManager.GetServerInfoById(serverId)
        if serverInfo ~= nil then
            serverInfo.playerNum = playerNum
        end
    end
    AccountManager.SetServerBusyPlayerNum(serverBusyPlayerNum)
    AccountManager.SetServerHotPlayerNum(serverHotPlayerNum)
    -- 登录成功后，会向服务器请求服务器列表，服务器会回复服务器信息和服务器人数
    ProcedureLogin.OnTypeServerPlayerNum()
    LoginController.ShowEnterGamePanel()
end

function LoginMessage.SendCloseConnectSession()
    local accountData = AccountManager.GetAccountData()
    local buffer = ClientNetManager.GetSendBuffer(Message.PT_CLOSE_CONNECT_SESSION)
    buffer:WriteDouble(accountData.accountId)
    ClientNetManager.Send(buffer)
    LoginMessage.m_OnLoginCloseSessionRet = false
    WaitingController.OpenWaitingView(function()
        return LoginMessage.m_OnLoginCloseSessionRet or false
    end)
end

function LoginMessage.OnLoginCloseSessionRet(buffer)
    LoginMessage.m_OnLoginCloseSessionRet = true
    ClientNetManager.Disconnect()
    ProcedureManager.ChangeProcedure(ProcedureTypeEnum.Login)
end

function LoginMessage.SendRequestSessionAlive(accountID, certifyKey)
    local buffer = ClientNetManager.GetSendBuffer(Message.PT_REQUEST_SESSION_ALIVE)
    buffer:WriteDouble(accountID)
    buffer:WriteInt(certifyKey)
    ClientNetManager.Send(buffer)
end

function LoginMessage.OnAlreadyLoginOther(buffer)
    -- AlertController.ShowAlert("在其他设备登录的此帐号已被踢下线")
end

-- 在其他地方登录
function LoginMessage.OnLoginOtherPlace(buffer)
    ProcedureHandler.Disconnect(DisconnectTypeEnum.LoginOtherPlace)
end

function LoginMessage.OnLoginSessionAliveRet(buffer)
    local alive = buffer:ReadUByte()
    ProcedureHandler.OnSessionAliveRet(alive)
end

function LoginMessage.OnLoginErr(buffer)
    local errorCode = buffer:ReadUByte()
    local alertData = 
    {
        showLeftButton = false,
        content = "LoginMessage.OnLoginErr errorCode = " .. errorCode,
        onConfirmCallback = function()
            ProcedureManager.ChangeProcedure(ProcedureTypeEnum.Login)
        end
    }
    AlertController.ShowAlert(alertData)
end

function LoginMessage.OnKickPlayer(buffer)
    ProcedureHandler.Disconnect(DisconnectTypeEnum.KickPlayer)
end

function LoginMessage.OnReconnect(buffer)
    ProcedureHandler.OnReconnect(buffer)
end

return LoginMessage
