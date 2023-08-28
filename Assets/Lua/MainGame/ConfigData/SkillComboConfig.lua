---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/9/15 11:22
---

local SkillComboConfig = class("SkillComboConfig")

function SkillComboConfig:Ctor()
    self.m_SkillCombos = {}
end

function SkillComboConfig:Random()
    local configs = self.m_SkillCombos
    if #configs == 0 then
        return nil
    end
    if #configs == 1 then
        return self.m_SkillCombos[1].SkillId
    end

    local totalNum = 0

    for i, comboData in pairs(configs) do
        totalNum = totalNum + comboData.Threshold
    end

    local random = math.random(0, totalNum)

    for i, comboData in pairs(configs) do
        random = random - comboData.Threshold
        if random <= 0 then
            return comboData.SkillId
        end
    end

    return nil
end

return SkillComboConfig