local CreateRoleModel = class("CreateRoleModel")
local k_MaxSlotCount = 5

--子类重新写
function CreateRoleModel:Init()
end

function CreateRoleModel:OnPlayerListResult(data)
    self.m_PlayerListResult = data
end

function CreateRoleModel:GetPlayerListResult()
    return self.m_PlayerListResult
end

function CreateRoleModel:GetRandKey()
    if self.m_PlayerListResult then
        return self.m_PlayerListResult.randKey
    end
end

function CreateRoleModel:GetLastJoinOrFirstPlayerInfo()
    local playerListResult = self.m_PlayerListResult
    if playerListResult ~= nil and playerListResult.players ~= nil and #playerListResult.players > 0 then
        for k, v in pairs(playerListResult.players) do
            if v.playerID == playerListResult.lastJoinPlayerID then
                return v
            end
        end

        return playerListResult.players[1]
    end

    return nil
end

function CreateRoleModel:GetPlayerCount()
    local playerListResult = self.m_PlayerListResult
    if playerListResult and playerListResult.players then
        return #playerListResult.players
    end

    return 0
end

function CreateRoleModel:CanCreateRole()
    return self:GetPlayerCount() < k_MaxSlotCount
end

function CreateRoleModel:GetFirstEmptyCreateSlot()
    for i = 1, k_MaxSlotCount do
        local isUsed = false
        for _, v in ipairs(self.m_PlayerListResult.players) do
            if v.slot == i then
                isUsed = true
                break
            end
        end

        if not isUsed then
            return i - 1
        end
    end

    return -1
end

return CreateRoleModel