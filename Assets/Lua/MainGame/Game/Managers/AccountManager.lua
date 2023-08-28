AccountManager = AccountManager or {}
local cjson = require('cjson')
local SystemInfo = UnityEngine.SystemInfo
local GameConfig = SGEngine.Core.Main.GameConfig

local ServerStatus = {
    Maintain = 4,
    Recommend = 5
}

local k_LastLoginServerId = 'LastLoginServerId'
local k_LastAccountName = 'LastAccountName'

--子类重新写
function AccountManager.Init()
    AccountManager.m_CurrentServerInfo = nil
    AccountManager.m_ServerInfos = nil
    AccountManager.m_AccountData = nil
    AccountManager.m_SdkData = {}
    AccountManager.m_ServerBusyPlayerNum = 0
    AccountManager.m_ServerHotPlayerNum = 0

    AccountManager.m_LastLoginServerId = nil
    AccountManager.m_LastAccountName = nil

    AccountManager.m_LoginServerSocketId = -1
    AccountManager.m_GameServerSocketId = -1
end

function AccountManager.GetAccoutNamePlayerPrefsKey()
    if UNITY_EDITOR or AndroidUtil.IsAndroidEmulator() then
        return k_LastAccountName .. GameConfig.machineCode
    else
        return k_LastAccountName .. SystemInfo.deviceUniqueIdentifier
    end
end

function AccountManager.GetLoginServerIdPlayerPrefsKey()
    if UNITY_EDITOR or AndroidUtil.IsAndroidEmulator() then
        return k_LastLoginServerId .. GameConfig.machineCode
    else
        return k_LastLoginServerId .. SystemInfo.deviceUniqueIdentifier
    end
end

function AccountManager.LoginSuccessCallback(msg)
    local json = cjson.decode(msg)

    AccountManager.m_SdkData.ischangeAccount = json.ischangeAccount
    AccountManager.m_SdkData.puid = json.p_uid
    AccountManager.m_SdkData.uid = tonumber(json.uid)
    AccountManager.m_SdkData.timestamp = json.timestamp
    AccountManager.m_SdkData.channelId = json.channelId
    AccountManager.m_SdkData.channelLable = json.channelLable
    AccountManager.m_SdkData.sign = json.sign
end

function AccountManager.SetServerInfos(data)
    AccountManager.m_ServerInfos = data
    local lastLoginServerId =  AccountManager.GetLastLoginServerId()
    --设置默认选服
    if string.IsNullOrEmpty(lastLoginServerId) then
         AccountManager.SetCurrentServerInfo(data[1])
    else
        local isFoundServer = false
        for i = 1, #AccountManager.m_ServerInfos do
            local serverInfo = AccountManager.m_ServerInfos[i]
            if serverInfo.serverId == lastLoginServerId then
                 AccountManager.SetCurrentServerInfo(serverInfo)
                isFoundServer = true
            end
        end

        if not isFoundServer then
             AccountManager.SetCurrentServerInfo(data[1])
        end
    end
end

function AccountManager.SetLastLoginServerId(serverId)
    if serverId ~= AccountManager.m_LastLoginServerId then
        AccountManager.m_LastLoginServerId = serverId
        PlayerPrefs.SetInt( AccountManager.GetLoginServerIdPlayerPrefsKey(), serverId)
    end
end

function AccountManager.GetLastAccountName()
    if AccountManager.m_LastAccountName == nil then 
        AccountManager.m_LastAccountName = PlayerPrefs.GetString( AccountManager.GetAccoutNamePlayerPrefsKey())
    end
    return AccountManager.m_LastAccountName
end

function AccountManager.GetLastLoginServerId()
    if AccountManager.m_LastLoginServerId == nil then  
        AccountManager.m_LastLoginServerId = PlayerPrefs.GetInt( AccountManager.GetLoginServerIdPlayerPrefsKey())
    end
    return AccountManager.m_LastLoginServerId
end

function AccountManager.SetLastAccountName(accountName)
    AccountManager.m_LastAccountName = accountName
    PlayerPrefs.SetString( AccountManager.GetAccoutNamePlayerPrefsKey(), accountName)
end

function AccountManager.GetServerInfos()
    return AccountManager.m_ServerInfos
end

function AccountManager.GetSortServerInfos()
    table.sort(
        AccountManager.m_ServerInfos,
        function(a, b)
            if a.playerNum and b.playerNum then
                return a.playerNum > b.playerNum
            end
            return false
        end
    )
    return AccountManager.m_ServerInfos
end

function AccountManager.SetCurrentServerInfo(serverInfo)
    AccountManager.m_CurrentServerInfo = serverInfo
end

function AccountManager.GetCurrentServerInfo()
    return AccountManager.m_CurrentServerInfo
end

function AccountManager.SetAccountData(accountData)
    AccountManager.m_AccountData = accountData
end

function AccountManager.GetAccountData()
    return AccountManager.m_AccountData
end

function AccountManager.GetSdkData()
    return AccountManager.m_SdkData
end

function AccountManager.SetServerBusyPlayerNum(num)
    AccountManager.m_ServerBusyPlayerNum = num
end

function AccountManager.SetServerHotPlayerNum(num)
    AccountManager.m_ServerHotPlayerNum = num
end

function AccountManager.GetServerInfoById(id)
    for i, serverInfo in ipairs(AccountManager.m_ServerInfos) do
        if serverInfo.serverId == id then
            return serverInfo
        end
    end

    return nil
end

function AccountManager.SetLoginServerSocketId(socketId)
    AccountManager.m_LoginServerSocketId = socketId
end

function AccountManager.GetLoginServerSocketId()
    return AccountManager.m_LoginServerSocketId
end

function AccountManager.SetGameServerSocketId(socketId)
    AccountManager.m_GameServerSocketId = socketId
end

function AccountManager.GetGameServerSocketId()
    return AccountManager.m_GameServerSocketId
end

function AccountManager.GetUIServerName(serverInfo)
    if serverInfo then
        if serverInfo.playerNum == nil then
            return '<color=#B3B3B3>' .. serverInfo.serverName .. '</color>'
        else
            if serverInfo.status == ServerStatus.Maintain or serverInfo.playerNum < 0 then
                return '<color=#B3B3B3>' .. serverInfo.serverName .. '</color>'
            end

            if serverInfo.playerNum < AccountManager.m_ServerBusyPlayerNum then
                return '<color=#03FF00>' .. serverInfo.serverName .. '</color>'
             --绿色
            end

            if serverInfo.playerNum < AccountManager.m_ServerBusyPlayerNum then
                return '<color=#03FF00>' .. serverInfo.serverName .. '</color>' --黄色
            end
        end
    else
        return ''
    end
end

function AccountManager.SetCertify(certifyKey)
    AccountManager.m_CertifyKey = certifyKey
end

function AccountManager.GetCertifyKey()
    return AccountManager.m_CertifyKey
end

function AccountManager.IsCertify()
    return AccountManager.m_CertifyKey ~= nil
end

function AccountManager.ResetCertify()
    AccountManager.m_CertifyKey = nil
end

return AccountManager
