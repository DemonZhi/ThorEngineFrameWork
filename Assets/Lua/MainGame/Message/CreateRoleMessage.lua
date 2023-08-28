CreateRoleMessage = CreateRoleMessage or {}
local MessageOpcodeEnum = require("MainGame/Message/MessageOpcodeEnum")
local DisconnectTypeEnum = require("MainGame/Common/Const/DisconnectTypeEnum")
 

local ResultCode = 
{
    RC_PLAYER_NAME_OK = 0,
    RC_CREATE_PLAYER_OK = 0,
    RC_ACOUNT_NOT_FOUND = 1,
    RC_PLAYERLIST_FULL = 2,
    RC_PLAYER_JOB_ERROR = 7,
    RC_PLAYER_AVATAR_SUBPART_ERROR = 9,
    RC_SERVER_SQL_ERROR = 220,
    RC_PLAYER_NAME_EMPTY = 310,
    RC_PLAYER_NAME_HAS_INVALID_CHAR = 311,
    RC_PLAYER_NAME_UNAVAILABLE = 312,
}

function CreateRoleMessage.Init()
    NetManager.Register(MessageOpcodeEnum.ST_PLAYERLIST_RESULT, CreateRoleMessage.OnPlayerListResult)
    NetManager.Register(MessageOpcodeEnum.ST_RANDOM_NAME, CreateRoleMessage.OnRandomName)
    NetManager.Register(MessageOpcodeEnum.ST_CREATE_PLAYER_RESULT, CreateRoleMessage.OnCreatePlayerResult)
    NetManager.Register(MessageOpcodeEnum.ST_JOIN_PLAYER_RESULT, CreateRoleMessage.OnJoinResult)
end

function CreateRoleMessage.Destroy()
    NetManager.UnRegister(MessageOpcodeEnum.ST_PLAYERLIST_RESULT, CreateRoleMessage.OnPlayerListResult)
    NetManager.UnRegister(MessageOpcodeEnum.ST_RANDOM_NAME, CreateRoleMessage.OnRandomName)
    NetManager.UnRegister(MessageOpcodeEnum.ST_CREATE_PLAYER_RESULT, CreateRoleMessage.OnCreatePlayerResult)
    NetManager.UnRegister(MessageOpcodeEnum.ST_JOIN_PLAYER_RESULT, CreateRoleMessage.OnJoinResult)
end


function CreateRoleMessage.SendGetRandomName(gender)
    local buffer = ClientNetManager.GetSendBuffer(MessageOpcodeEnum.PT_GET_RANDOM_NAME)
    buffer:WriteUByte(gender)
    ClientNetManager.Send(buffer)
end

-- 退出创角要返还随机名
function CreateRoleMessage.SendUnlockRandomName()
    local buffer = ClientNetManager.GetSendBuffer(MessageOpcodeEnum.PT_GET_RANDOM_NAME)
    ClientNetManager.Send(buffer)
end

function CreateRoleMessage.SendCreatePlayer(accountID, jobID, playerName, slot, gender, faceBlendshapeList, faceTextureIndexList)

    CreateRoleMessage.notSendingCreatePlayer = false
    WaitingController.OpenWaitingView(function()
        return CreateRoleMessage.notSendingCreatePlayer or false
    end)

    local buffer = ClientNetManager.GetSendBuffer(MessageOpcodeEnum.PT_CREATE_PLAYER)
    buffer:WriteDouble(accountID)
    buffer:WriteInt(jobID)
    buffer:WriteString(playerName)
    buffer:WriteInt(slot)
    buffer:WriteUByte(gender)
    
    -- blendshape
    local blendshapeLength = #faceBlendshapeList
    buffer:WriteUByte(blendshapeLength)
    for i = 1, blendshapeLength, 1 do
        buffer:WriteFloat(faceBlendshapeList[i])
    end
    -- body
    buffer:WriteUByte(0)
    
    -- face texture
    local faceTextureLength = #faceTextureIndexList
    buffer:WriteUByte(faceTextureLength)
    for i = 1, faceTextureLength, 1 do
        buffer:WriteShort(faceTextureIndexList[i])
    end
    -- skin color
    buffer:WriteShort(0)
    -- hair color
    buffer:WriteFloat(0)
    buffer:WriteFloat(0)
    buffer:WriteFloat(0)
    -- hair color2
    buffer:WriteFloat(0)
    buffer:WriteFloat(0)
    buffer:WriteFloat(0)
    -- hair color2 strength
    buffer:WriteFloat(0)
    -- original avatar subpart
    buffer:WriteInt(0)
    
    ClientNetManager.Send(buffer)
end

function CreateRoleMessage.SendDeletePlayer(accountID, playerID)
    local buffer = ClientNetManager.GetSendBuffer(MessageOpcodeEnum.PT_DELETE_PLAYER)
    buffer:WriteDouble(accountID)
    buffer:WriteInt(playerID)
    ClientNetManager.Send(buffer)
end

function CreateRoleMessage.SendJoin(playerID, randKey)
    local buffer = ClientNetManager.GetSendBuffer(MessageOpcodeEnum.PT_JOIN)
    buffer:WriteInt(playerID)
    buffer:WriteInt(randKey)
    CreateRoleMessage.SerializeSDK(buffer)
    ClientNetManager.Send(buffer)
end

function CreateRoleMessage.SerializeSDK(buffer)
    local sdkData = AccountManager.GetSdkData()
    buffer:WriteDouble(sdkData.uid)
    buffer:WriteString('machine_code')
    buffer:WriteString(sdkData.puid)
    buffer:WriteString(sdkData.channelLabel)
    buffer:WriteString(sdkData.puid)
    buffer:WriteString("systemInfo.deviceModel")
    buffer:WriteString("systemInfo.operatingSystem")
    buffer:WriteString("atme")
end

function CreateRoleMessage.OnPlayerListResult(buffer)
    local playerCount = buffer:ReadUByte()
    local result = {}
    result.players = {}
    for i = 1, playerCount do
        local playerInfo = {}
        playerInfo.playerID = buffer:ReadInt()
        playerInfo.jobID = buffer:ReadInt()
        playerInfo.gender = buffer:ReadUByte()
        playerInfo.name = buffer:ReadString()
        playerInfo.level = buffer:ReadInt()
        playerInfo.slot = buffer:ReadInt()

        playerInfo.faceBlendshapeList = {}
        --blendshape
        local length = buffer:ReadUByte()
        for i = 1, length do
            playerInfo.faceBlendshapeList[i] = buffer:ReadFloat()
        end

        -- body
        length = buffer:ReadUByte()
        for i = 1, length do
            buffer:ReadFloat()
        end

        -- face texture
        playerInfo.faceTextureList = {}
        length = buffer:ReadUByte()
        for i = 1, length do
            playerInfo.faceTextureList[i] = buffer:ReadShort()
        end

        -- skin color
        buffer:ReadShort()

        -- hair color
        buffer:ReadFloat()
        buffer:ReadFloat()
        buffer:ReadFloat()
        
        -- hair color2
        buffer:ReadFloat()
        buffer:ReadFloat()
        buffer:ReadFloat()

        -- hair color2 strength
        buffer:ReadFloat()

        -- avatar
        local customSubpartDict = {}
        length = buffer:ReadInt()
        for i = 1, length do
            local subpartType = buffer:ReadUByte()
            customSubpartDict[subpartType] = buffer:ReadInt()
        end
        playerInfo.m_CustomSubpartDict = customSubpartDict

        local wearSubpartDict = {}
        length = buffer:ReadInt()
        -- Logger.LogInfoFormat("[CreateRoleMessage](OnPlayerListResult) length = {0}", length)
        for i = 1, length do
            local subpartType = buffer:ReadUByte()
            wearSubpartDict[subpartType] = buffer:ReadInt()
            -- Logger.LogInfoFormat("[CreateRoleMessage](OnPlayerListResult) subpartType = {0} id = {1}", subpartType, wearSubpartDict[subpartType])
        end
        playerInfo.m_WearSubpartDict = wearSubpartDict

        -- equip ids
        length = buffer:ReadUByte()
        for i = 1, length do
            buffer:ReadInt()
        end

        table.insert(result.players, playerInfo)
    end

    result.randKey = buffer:ReadInt()
    result.lastJoinPlayerID = buffer:ReadInt()
    CreateRoleController.model:OnPlayerListResult(result)
    CreateRoleController.OnPlayerListResult(result)
    ProcedureLogin.OnPlayerListResult()
end

function CreateRoleMessage.OnRandomName(buffer)
    local result = buffer:ReadString()
    if not string.IsNullOrEmpty(result) then
        CreateRoleController.OnRandomName(result)
    end
end

function CreateRoleMessage.OnCreatePlayerResult(buffer)
    CreateRoleMessage.notSendingCreatePlayer = true
    local msgID = buffer:ReadInt()
    local playerID = buffer:ReadInt()
    local playerName = buffer:ReadString()

    if msgID == ResultCode.RC_CREATE_PLAYER_OK then
        CreateRoleMessage.SendJoin(playerID, CreateRoleController.model:GetRandKey())
    else
        local errorMessage
        if msgID == ResultCode.RC_ACOUNT_NOT_FOUND then
            errorMessage = "未注册账号"
        elseif msgID == ResultCode.RC_PLAYERLIST_FULL then
            errorMessage = "角色数量已达最大"
        elseif msgID == ResultCode.RC_SERVER_SQL_ERROR then
            errorMessage = "已断开服务器连接"
        elseif msgID == ResultCode.RC_PLAYER_NAME_HAS_INVALID_CHAR then
            errorMessage = "非法名字"
        elseif msgID == ResultCode.RC_PLAYER_NAME_EMPTY then
            errorMessage = "名字不能为空"
        elseif msgID == ResultCode.RC_PLAYER_NAME_UNAVAILABLE then
            errorMessage = "该名字已被占用"
        elseif msgID == ResultCode.RC_PLAYER_JOB_ERROR then
            errorMessage = "职业错误"
        elseif msgID == ResultCode.RC_PLAYER_AVATAR_SUBPART_ERROR then
            errorMessage = "部件数据错误"
        else
            errorMessage = "未知错误"
        end

        AlertController.ShowAlert(errorMessage)
    end
end

-- 失败才发
function CreateRoleMessage.OnJoinResult(buffer)
    local retCode = buffer:ReadUByte()
    Logger.LogInfo("CreateRoleMessage.OnJoinResult: retCode-> " .. retCode)
end

return CreateRoleMessage