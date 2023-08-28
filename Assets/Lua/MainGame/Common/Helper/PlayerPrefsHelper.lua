local PlayerPrefs = PlayerPrefs

---@class PlayerPrefsHelper
local PlayerPrefsHelper = {}
PlayerPrefsHelper.Keys =
{    
    RenderSetting_Quality = "RenderSetting_Quality", -- 渲染质量设置
}

function PlayerPrefsHelper.HasKey(key)
    return PlayerPrefs.HasKey(key)
end

function PlayerPrefsHelper.SetString(key, value)
    PlayerPrefs.SetString(key, value)
end

function PlayerPrefsHelper.GetString(key)
    return PlayerPrefs.GetString(key)
end

function PlayerPrefsHelper.SetInt(key, value)
    PlayerPrefs.SetInt(key, value)
end

function PlayerPrefsHelper.GetInt(key)
    return PlayerPrefs.GetInt(key)
end 

function PlayerPrefsHelper.SetBool(key, value)
    local setValue = value and 1 or 0 
    PlayerPrefsHelper.SetInt(key, setValue)
end

function PlayerPrefsHelper.GetBool(key)
    local value = PlayerPrefsHelper.GetInt(key)
    return value == nil and false or value == 1 
end

local function GetKeyByPlayerId(key)
    local playerId = DataModels.PlayerModel:GetPlayerId()
    return string.format("%s_%s", playerId, key)
end

function PlayerPrefsHelper.HasKeyByPlayerId(key)
    return PlayerPrefsHelper.HasKey(GetKeyByPlayerId(key))
end

function PlayerPrefsHelper.SetIntByPlayerId(key, value)
    PlayerPrefsHelper.SetInt(GetKeyByPlayerId(key), value)
end

function PlayerPrefsHelper.GetIntByPlayerId(key)
    return PlayerPrefsHelper.GetInt(GetKeyByPlayerId(key))
end

function PlayerPrefsHelper.SetStringByPlayerId(key, value)
    PlayerPrefsHelper.SetString(GetKeyByPlayerId(key), value)
end

function PlayerPrefsHelper.GetStringByPlayerId(key)
    return PlayerPrefsHelper.GetString(GetKeyByPlayerId(key))
end

function PlayerPrefsHelper.SetBoolByPlayerId(key, bool)
    PlayerPrefsHelper.SetBool(GetKeyByPlayerId(key), bool)
end

function PlayerPrefsHelper.GetBoolByPlayerId(key)
    return PlayerPrefsHelper.GetBool(GetKeyByPlayerId(key))
end

return PlayerPrefsHelper