local MessageOpcodeEnum = require("MainGame/Message/MessageOpcodeEnum")
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
AvatarMessage = AvatarMessage or {}

function AvatarMessage.Init()
    NetManager.Register(MessageOpcodeEnum.ST_SET_AVATAR_SUBPART_RESULT, AvatarMessage.OnSetAvatarSubpartResult)
    NetManager.Register(MessageOpcodeEnum.ST_SET_PLAYER_AVATAR_SUBPART, AvatarMessage.OnSetPlayerAvatarSubpart)
end

function AvatarMessage.Destroy()
    NetManager.UnRegister(MessageOpcodeEnum.ST_SET_AVATAR_SUBPART_RESULT, AvatarMessage.OnSetAvatarSubpartResult)
    NetManager.UnRegister(MessageOpcodeEnum.ST_SET_PLAYER_AVATAR_SUBPART, AvatarMessage.OnSetPlayerAvatarSubpart)
end

function AvatarMessage.SendSetAvatarSubpart(isOn, subpartType, configID)
    local buffer = ClientNetManager.GetSendBuffer(MessageOpcodeEnum.PT_SET_AVATAR_SUBPART)
    buffer:WriteUByte(isOn and 1 or 0)
    buffer:WriteUByte(subpartType)
    buffer:WriteInt(configID)
    ClientNetManager.Send(buffer)
end


function AvatarMessage.OnSetAvatarSubpartResult(netBuffer)
    local isSucceed = netBuffer:ReadUByte()
    --Logger.LogInfo("[AvatarMessage](OnSetAvatarSubpartResult) isSucceed = %s", isSucceed)
    local isOn = netBuffer:ReadUByte() > 0
    local SubpartType = netBuffer:ReadUByte()
    local configID = netBuffer:ReadInt()
end

function AvatarMessage.OnSetPlayerAvatarSubpart(netBuffer)
    --Logger.LogInfo("[AvatarMessage](OnSetPlayerAvatarSubpart)")
    local objectID = netBuffer:ReadInt()
    local isOn = netBuffer:ReadUByte() > 0
    local subpartType = netBuffer:ReadUByte()
    local configID = netBuffer:ReadInt()
    local sgObject = ObjectManager.GetObject(objectID)
    if sgObject == nil then
        return
    end

    local avatarComponent = sgObject:GetComponent(ComponentDefine.ComponentType.k_ComponentAvatar)
    if avatarComponent == nil then
        return
    end

    avatarComponent:SetWearSubpart(subpartType, configID, isOn)
end

return AvatarMessage