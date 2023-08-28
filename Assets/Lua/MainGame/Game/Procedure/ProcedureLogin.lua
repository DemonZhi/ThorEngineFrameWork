local BattleMessage = require("MainGame/Message/BattleMessage")
local ServerTypeEnum = require('MainGame/Common/Const/ServerTypeEnum')
local PoolingStrategyTypeEnum = require('Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum')
local LoginMessage = require('MainGame/Message/LoginMessage')
local GameConfig = SGEngine.Core.Main.GameConfig
local k_LoginIP = SGEngine.Core.Main.GameConfig.remoteIP
local k_OuterSDKLoginURL = SGEngine.Core.Main.GameConfig.outerSdkURL
local k_InnerSDKLoginURL = SGEngine.Core.Main.GameConfig.innerSdkURL
local k_SDKPostKey = 'partner_account'
ProcedureLogin = ProcedureLogin or {}
 

local WaitingStateEnum = 
{
    None = 0,
    SDKLogin = 1,
    ConnectLoginServer = 2,
    SendTypeLogin = 3,
    ConnectGameServer = 4,
    SendCertify = 5,
    SendTypeGetServerInfo = 6,
}

--region 生命周期
function ProcedureLogin.Init()
end

function ProcedureLogin.Enter()
    --网络连接回调
    ClientNetManager.RegisterConnectCallBack(ServerTypeEnum.LoginServer,ProcedureLogin.OnConnectLoginServer)
    ClientNetManager.RegisterConnectCallBack(ServerTypeEnum.GameServer,ProcedureLogin.OnConnectGameServer)
    ClientNetManager.RegisterTimeOutCallBack(ProcedureLogin.OnServerNoResponse)

    ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.LoginServer, ProcedureLogin.OnSocketError)
    ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.GameServer, ProcedureLogin.OnSocketError)

    local lastProcedureType = ProcedureManager.GetLastProcedureType()
    -- 如果上一流程为登录/创角流程 不用再次加载场景/预载资源
    if lastProcedureType == ProcedureTypeEnum.Login or lastProcedureType == ProcedureTypeEnum.CreateRole then
        UIManager.CloseAllUI()
        ProcedureLogin.PreLoadFinish()
    else
        SceneManager.ChangeScene(6, SceneTypeEnum.Login)
    end
end

function ProcedureLogin.Update(deltaTime)
    if ProcedureLogin.m_PreLoadingCount and ProcedureLogin.m_PreLoadingCount == 0 then
        ProcedureLogin.m_PreLoadingCount = -1
        ProcedureLogin.PreLoadFinish()
    end
end

function ProcedureLogin.Leave()
    ClientNetManager.UnRegisterConnectCallBack(ServerTypeEnum.LoginServer,ProcedureLogin.OnConnectLoginServer)
    ClientNetManager.UnRegisterConnectCallBack(ServerTypeEnum.GameServer,ProcedureLogin.OnConnectGameServer)
    ClientNetManager.UnRegisterTimeOutCallBack(ProcedureLogin.OnServerNoResponse)
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.LoginServer,ProcedureLogin.OnSocketError)
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.GameServer,ProcedureLogin.OnSocketError)
end

function ProcedureLogin.Destroy()
end

function ProcedureLogin.AfterChangeScene()
    ProcedureLogin.PreLoad()
    ProcedureLogin.PreLoadModel(36)
    ProcedureLogin.PreLoadModel(37)
end
--endregion

--region Odin
-- 预载资源
function ProcedureLogin.PreLoad()
    ProcedureLogin.m_PreLoadingCount = 0
    -- 预载UI
    local preLoadViewHandle = function(viewsName)
        if not viewsName then
            return
        end

        for _, v in ipairs(viewsName) do
            ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount + 1
            ResourceManager.InstantiateAsync(
                v,
                function(go)
                    ResourceManager.ReleaseInstance(go)
                    ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount - 1
                end,
                PoolingStrategyTypeEnum.Default
            )
        end
    end
    preLoadViewHandle(LoginController.GetAllViewsName())
    preLoadViewHandle(LoadingController.GetAllViewsName())
end

function ProcedureLogin.PreLoadModel(modelID)
    local jobConfig = JobConfig
    local modelConfig = ModelConfig
    local subpartConfig = AvatarSubpartConfig
    local modelConfigItem = modelConfig[modelID]
    if modelConfigItem == nil then
        Logger.LogErrorFormat("[ProcedureLogin](PreLoad) can not find modelConfig by ID: {0}", modelID)
        return
    end
    ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount + 1
    -- 预载角色模型
    ResourceManager.CreateInstancePoolCache(
            modelConfigItem.Address,
            PoolingStrategyTypeEnum.DontDestroyOnLoad,
            1,
            function(param)
                ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount - 1
            end
    )

    -- 预载角色默认部件
    if not modelConfigItem.DefaultSubpartList then
        return
    end
    for _, suppartID in pairs(modelConfigItem.DefaultSubpartList) do
        local subpartConfigItem = subpartConfig[suppartID]
        ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount + 1
        ResourceManager.CreateInstancePoolCache(
                subpartConfigItem.PrefabAddress,
                PoolingStrategyTypeEnum.DontDestroyOnLoad,
                1,
                function(param)
                    ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount - 1
                end
        )

        -- 预载部件骨骼配置
        if not string.IsNullOrEmpty(subpartConfigItem.BoneConfigAddress) then
            ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount + 1
            local loadHandle = ResourceManager.LoadScriptableObjectAsync(subpartConfigItem.BoneConfigAddress, function(scriptableObject)
                ProcedureLogin.m_PreLoadingCount = ProcedureLogin.m_PreLoadingCount - 1
            end)
            table.insert(ProcedureLogin.m_PreLoadScriptableObjectList, loadHandle)
        end
    end
end

-- 预载完成
function ProcedureLogin.PreLoadFinish()
    LoginController.OpenView(function()
        -- 销毁patch view
        local initUIManager = SGEngine.Core.InitUIManager.Instance
        if initUIManager then
            initUIManager:Destroy()
        end
    end)
end

-- 卸载预载资源
function ProcedureLogin.ReleasePreLoadRes()
    local preLoadScriptableObjectList = ProcedureLogin.m_PreLoadScriptableObjectList
    if preLoadScriptableObjectList then
        for _, v in ipairs(preLoadScriptableObjectList) do
            ResourceManager.ReleaseScriptableObject(v)
        end
    end
end

-- 设置等待状态
function ProcedureLogin.SetWaitingState(waitingState)
    Logger.LogInfoFormat("[ProcedureLogin](SetWaitingState) PreWaitingState = {0}  CurrentWaitingState = {1}", ProcedureLogin.m_WaitingState, waitingState)
    if waitingState ~= WaitingStateEnum.None then
        WaitingController.OpenWaitingView(function()
            return ProcedureLogin.m_WaitingState == WaitingStateEnum.None
        end)
    end
    ProcedureLogin.m_WaitingState = waitingState
end

-- SDK登录
function ProcedureLogin.SDKLogin(accountName, mono)
    if ProcedureLogin.m_WaitingState ~= nil and ProcedureLogin.m_WaitingState ~= WaitingStateEnum.None then
        Logger.LogErrorFormat("[ProcedureLogin](SDKLogin) Error, Current PreWaitingState : = {0}, can not login again!", ProcedureLogin.m_WaitingState)
        return
    end

    AccountManager.ResetCertify()
    ProcedureLogin.SetWaitingState(WaitingStateEnum.SDKLogin)
    local loginURL = k_OuterSDKLoginURL
    if string.sub(k_LoginIP, 1, 3) == "10." then
        loginURL = k_InnerSDKLoginURL
    elseif string.sub(k_LoginIP, 1, 8) == "192.168." then
        loginURL = k_InnerSDKLoginURL
    elseif string.sub(k_LoginIP, 1, 4) == "172." then
        loginURL = k_InnerSDKLoginURL
    end
    Logger.LogInfoFormat("[ProcedureLogin](SDKLogin):accountName = {0}, k_SDKLoginURL = {1}", accountName, loginURL)

    PlatformSDK.Instance:Login(
            accountName,
            '',
            loginURL,
            k_SDKPostKey,
            mono,
            function(msg)
                AccountManager.LoginSuccessCallback(msg)
                local sdkData = AccountManager.GetSdkData()
                if sdkData.uid then
                    ProcedureLogin.SDKLoginSucceed()
                else
                    ProcedureLogin.SDKLoginFailed()
                end
            end,
            function(msg)
                ProcedureLogin.SDKLoginFailed()
            end
    )
end

-- SDK登录成功
function ProcedureLogin.SDKLoginSucceed()
    ProcedureLogin.SetWaitingState(WaitingStateEnum.None)
    ProcedureLogin.ConnectLoginServer()
end

-- SDK登录失败
function ProcedureLogin.SDKLoginFailed()
    ProcedureLogin.SetWaitingState(WaitingStateEnum.None)
    local alertData = {
        showLeftButton = false,
        content = "SDK登录失败，请稍后再试",
    }
    AlertController.ShowAlert(alertData)
end

-- 连接登录服
function ProcedureLogin.ConnectLoginServer()
    Logger.LogInfoFormat("[ProcedureLogin](ConnectLoginServer):SDK Login Success! Start to connect login server!IP = {0}，Port = {1}", GameConfig.remoteIP, GameConfig.remotePort)
    ProcedureLogin.SetWaitingState(WaitingStateEnum.ConnectLoginServer)
    ClientNetManager.ConnectLoginServer(GameConfig.remoteIP, GameConfig.remotePort)
end

-- 登录服已连接
function ProcedureLogin.OnConnectLoginServer(socketId)
    Logger.LogInfoFormat("[ProcedureLogin](OnConnectLoginServer)connect to login server success, try to request server Info")
    ProcedureLogin.SetWaitingState(WaitingStateEnum.SendTypeGetServerInfo)
    LoginMessage.SendTypeGetServerInfo()
end

-- 服务器列表
function ProcedureLogin.OnTypeServerPlayerNum()
    Logger.LogInfoFormat("[ProcedureLogin](OnTypeServerPlayerNum)")
    ProcedureLogin.SetWaitingState(WaitingStateEnum.None)
end

-- 登录
function ProcedureLogin.Login()
    if ClientNetManager.GetCurrentServerType() ~= ServerTypeEnum.LoginServer then
        Logger.LogInfoFormat("[ProcedureLogin](Login) try to login. but loginserver is not connected!  currentServerType = {0}", ClientNetManager.GetCurrentServerType())
        return
    end

    local machineCode = ''
    local version = 2147483647
    local currentServerInfo = AccountManager.GetCurrentServerInfo()
    local sdkData = AccountManager.GetSdkData()
    local platformTag = 'atme'
    local activeCode = ''
    AccountManager.SetLastLoginServerId(currentServerInfo.serverId)
    Logger.LogInfoFormat("[ProcedureLogin](Login) SendTypeLogin 2 LoginServer!")
    ProcedureLogin.SetWaitingState(WaitingStateEnum.SendTypeLogin)
    LoginMessage.SendTypeLogin(
            sdkData.uid,
            machineCode,
            sdkData.puid,
            sdkData.channelId,
            sdkData.channelLable,
            sdkData.timestamp,
            sdkData.sign,
            version,
            currentServerInfo.serverId,
            sdkData.puid,
            platformTag,
            activeCode
    )
end

-- 登录成功
function ProcedureLogin.OnTypeLoginResult(code, data)
    if code == 0 then
        local currentServerInfo = AccountManager.GetCurrentServerInfo()
        Logger.LogInfoFormat("[ProcedureLogin](OnTypeLoginResult) login 2 loginServer succeed! now connect 2 gameServer. ip = {0} port = {1}", currentServerInfo.ip, currentServerInfo.port)
        ProcedureLogin.SetWaitingState(WaitingStateEnum.ConnectGameServer)
        ClientNetManager.ConnectGameServer(currentServerInfo.ip, currentServerInfo.port)
    else
        Logger.LogInfoFormat("[ProcedureLogin](OnTypeLoginResult) login 2 loginServer Failed!")
        ProcedureLogin.SetWaitingState(WaitingStateEnum.None)
        ProcedureLogin.AlertToRestartLoginProcedure(data)
    end
end

-- 游戏服已连接
function ProcedureLogin.OnConnectGameServer(socketId)
    Logger.LogInfoFormat("[ProcedureLogin](OnConnectGameServer) connected 2 gameserver! now SendCertify!")
    ProcedureLogin.SetWaitingState(WaitingStateEnum.SendCertify)
    LoginMessage.SendCertify()
end

-- 验证结果
function ProcedureLogin.OnCertify(certifyCode)
    Logger.LogInfoFormat("[ProcedureLogin](OnCertify) certify code = {0}!", certifyCode)
    if certifyCode == 0 then
        ProcedureHandler.ResetReconnectTime()
    else
        ProcedureLogin.SetWaitingState(WaitingStateEnum.None)
        ProcedureLogin.AlertToRestartLoginProcedure("服务器验证失败，请重新登录")
    end
end

-- 玩家列表回来了
function ProcedureLogin.OnPlayerListResult()
    if ProcedureManager.GetCurrentProcedureType() == ProcedureTypeEnum.Login then
        Logger.LogInfoFormat("[ProcedureLogin](OnPlayerListResult) receive playerList data. ChangeProcedure 2 CreateRole!")
        ProcedureLogin.SetWaitingState(WaitingStateEnum.None)
        ProcedureManager.ChangeProcedure(ProcedureTypeEnum.CreateRole)
    end
end

function ProcedureLogin.AlertToRestartLoginProcedure(tips)
    if tips then
        local alertData = 
        {
            showLeftButton = false,
            content = tips,
            onConfirmCallback = function()
                ProcedureManager.ChangeProcedure(ProcedureTypeEnum.Login)
            end
        }
        AlertController.ShowAlert(alertData)
    end
end

function ProcedureLogin.SocketBreak(serverType)
    ProcedureLogin.SetWaitingState(WaitingStateEnum.None)
    local tips
    if serverType == ServerTypeEnum.LoginServer then
        tips = "网络异常，请重新登录"
    elseif serverType == ServerTypeEnum.GameServer then
        if not AccountManager.IsCertify() then
            tips = "网络异常，请重新登录"
        end
    end

    if tips then
        ProcedureLogin.AlertToRestartLoginProcedure(tips)
    end
end

function ProcedureLogin.OnServerNoResponse(serverType)
    ProcedureLogin.SocketBreak(serverType)
end

function ProcedureLogin.OnSocketError(serverType, errorCode)
    if errorCode == 0 then
       return
    end
    ProcedureLogin.SocketBreak(serverType)
end

--endregion

return ProcedureLogin
