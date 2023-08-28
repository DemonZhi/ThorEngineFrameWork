---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/9/14 20:20
---
local SkillComboConfig = require("MainGame/ConfigData/SkillComboConfig")
local SkillType = SGEngine.Core.SkillDefines

local SkillConfigData = {}
SkillConfigData.m_DataMap = {}
function SkillConfigData:Get(skillId)
    local data = self.m_DataMap[skillId]
    if data then
        return data
    end

    local configData = SkillConfig[skillId]
    if not configData then
        Logger.LogDebugFormat("None config for skillId:{0}", skillId)
        return nil
    end

    local config = {}
    config.ID = configData.ID
    config.SkillModule = configData.SkillModule
    config.CoolDown = configData.CoolDown / 1000   --ms to s
    config.AnimName = configData.AnimName
    config.StartSkillID = configData.StartSkillID
    if config.StartSkillID == 0 then
        config.StartSkillID = nil
    end
    config.IsAutoCombo = configData.IsAutoCombo == 1
    config.SkillEffectsList = self:ParseEffectData(configData.SkillEffectsList)
    config.AudioList = self:ParseAudioData(configData.AudioList)
    config.ComboConfig = self:ParseComboData(configData.ComboList)
    if config.ComboConfig ~= nil then
        config.ComboConfig.ComboTime = configData.ComboTime
    end
    config.JobList = configData.JobList
    config.Actions = configData.Actions
    config.IsInCombo = configData.ComboList ~= nil
    config.IsComboEnd = configData.ComboList == nil
    config.MovingSpeed = configData.MoveSpeed or 0
    config.RotateSpeed = configData.RotateSpeed or 0
    config.SkillModuleParams = self:ParseExtendParam(config.SkillModule, configData.SkillModuleParams)
    config.NeedFaceTarget = configData.NeedFaceTarget == 1
    config.FaceTargetSpeed = configData.FaceTargetSpeed
    config.MaxUseCount = configData.MaxUseCount
    config.RegainTime = configData.RegainTime
    config.RepeatCount = configData.RepeatCount
    config.AttackRadius = configData.AttackRadius

    self.m_DataMap[skillId] = config
    return config
end

function SkillConfigData:ParseEffectData(dataTable)
    if dataTable == nil then
        return nil
    end
    for i, data in pairs(dataTable) do
        local _key2index = {Id=1,BeginEvent=2,IsHeroOnly=3,IsDestroyOnSkillEnd=4}
        local _o =
        {
            __index = function(myTable, key)
                local temp = _key2index[key]
                if temp == nil then
                    --error("don't have the key in the table, key = "..key)
                    return nil
                end
                return myTable[temp]
            end,
            __newindex = function(myTable, key, value)
                error("can't modify read-only table!")
            end
        }
        setmetatable(data, _o)
    end
    return dataTable
end

function SkillConfigData:ParseAudioData(data)
    if string.IsNullOrEmpty(data) then
        return nil
    end
    local result = {}
    local dataList = string.split(data, ";")

    for i, v in pairs(dataList) do
        if not string.IsNullOrEmpty(v) then
            local strList = string.split(v, ",")
            if #strList == 2 then
                local config = {}
                config.BeginEvent = strList[1]
                config.Id = tonumber(strList[2])
                table.insert(result, config)
            else
                Logger.LogErrorFormat("Error effect data in parsing:{0}", v)
            end
        end
    end

    return result
end


function SkillConfigData:ParseComboData(dataTable)
    if dataTable == nil then
        return nil
    end
    local result = SkillComboConfig.New()
    for i, data in pairs(dataTable) do
        local _key2index = {SkillId=1,Threshold=2}
        local _o =
        {
            __index = function(myTable, key)
                local temp = _key2index[key]
                if temp == nil then
                    --error("don't have the key in the table, key = "..key)
                    return nil
                end
                return myTable[temp]
            end,
            __newindex = function(myTable, key, value)
                error("can't modify read-only table!")
            end
        }
        setmetatable(data, _o)
        table.insert(result.m_SkillCombos, data)
    end
    return result
end

function SkillConfigData:ParseExtendParam(skillModule, data)
    if skillModule == SkillType.k_SkillTypeCharge then
        return self:ParseChargeSkillData(data)
    elseif skillModule == SkillType.k_SkillTypeJump then
        return self:ParseJumpSkillData(data)
    elseif skillModule == SkillType.k_SkillTypeMove then
        return data
    elseif skillModule == SkillType.k_SkillTypeRootMotion then
        return data
    end

    return data
end

function SkillConfigData:ParseChargeSkillData(dataTable)
    if #dataTable == 0 then
        return nil
    end

    local timeList = {}
    local skillIdList = {}
    local result = {
        m_TimeList = timeList,
        m_SkillIdList = skillIdList
    }

    local length = #dataTable
    for i = 1, length do
        if i%2 ~= 0 then
            table.insert(timeList, dataTable[i] / 1000)
        else
            table.insert(skillIdList, dataTable[i])
        end
    end

    return result
end

function SkillConfigData:ParseJumpSkillData(dataTable)
    if #dataTable == 0 then
        return nil
    end

    local result = {}
    result.m_SpeedXZ = dataTable[1]/1000
    result.m_SpeedY = dataTable[2]/1000
    result.m_Gravity = dataTable[3]/1000
    result.m_CheckGroundHeight = dataTable[4]/1000
    return result
end

return SkillConfigData