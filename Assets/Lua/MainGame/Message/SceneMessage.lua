---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2022/9/27 14:44
---
local MessageOpcodeEnum = require("MainGame/Message/MessageOpcodeEnum")
SceneMessage = SceneMessage or {}

function SceneMessage.Init()
    NetManager.Register(MessageOpcodeEnum.ST_MIGRATE_BF_BEGIN, BfClientManager.OnGameToBfBegin)
    NetManager.Register(MessageOpcodeEnum.ST_MIGRATE_BF_FAIL, BfClientManager.OnGameToBfFailed)
    NetManager.Register(MessageOpcodeEnum.ST_REJOIN_GAME_BEGIN, BfClientManager.OnBfToGameBegin)
    NetManager.Register(MessageOpcodeEnum.ST_RECONNECT_FROM_BF, BfClientManager.OnBfReconnect)
    NetManager.Register(MessageOpcodeEnum.ST_AFTER_CLIENT_ADD_ACTIVE_PLAYER_ON_BF, BfClientManager.OnBfConnected)
    NetManager.Register(MessageOpcodeEnum.ST_CITY_PLANE_UPDATE, SceneMessage.OnCityPlaneUpdate)
    NetManager.Register(MessageOpcodeEnum.ST_RECONNECT_FROM_BF, BfClientManager.OnReconnectFromBf)
    NetManager.Register(MessageOpcodeEnum.ST_AFTER_CLIENT_ADD_ACTIVE_PLAYER_ON_BF, BfClientManager.ThisIsAnUnusedProtocol)
end

function SceneMessage.Destroy()
    NetManager.UnRegister(MessageOpcodeEnum.ST_MIGRATE_BF_BEGIN, BfClientManager.OnGameToBfBegin)
    NetManager.UnRegister(MessageOpcodeEnum.ST_MIGRATE_BF_FAIL, BfClientManager.OnGameToBfFailed)
    NetManager.UnRegister(MessageOpcodeEnum.ST_REJOIN_GAME_BEGIN, BfClientManager.OnBfToGameBegin)
    NetManager.UnRegister(MessageOpcodeEnum.ST_RECONNECT_FROM_BF, BfClientManager.OnBfReconnect)
    NetManager.UnRegister(MessageOpcodeEnum.ST_AFTER_CLIENT_ADD_ACTIVE_PLAYER_ON_BF, BfClientManager.OnBfConnected)
    NetManager.UnRegister(MessageOpcodeEnum.ST_CITY_PLANE_UPDATE, SceneMessage.OnBfConnected)
    NetManager.UnRegister(MessageOpcodeEnum.ST_RECONNECT_FROM_BF, BfClientManager.OnReconnectFromBf)
    NetManager.UnRegister(MessageOpcodeEnum.ST_AFTER_CLIENT_ADD_ACTIVE_PLAYER_ON_BF, BfClientManager.ThisIsAnUnusedProtocol)
end

function SceneMessage.OnCityPlaneUpdate(buffer)
    local planeId = buffer:ReadInt()
    local status = buffer:ReadUByte()
end

return SceneMessage