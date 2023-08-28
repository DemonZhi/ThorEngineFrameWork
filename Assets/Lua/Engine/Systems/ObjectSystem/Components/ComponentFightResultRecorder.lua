local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentFightResultRecorder = class("ComponentFightResultRecorder", ComponentBase)
ComponentFightResultRecorder.m_ComponentId = ComponentDefine.ComponentType.k_ComponentFightResultRecorder

local FightResultType = ComponentDefine.FightResultType

function ComponentFightResultRecorder:Init(object)
    ComponentFightResultRecorder.__super.Init(self, object)
    self.m_RecordFightResultList = {}
end

function ComponentFightResultRecorder:Destroy()
    ComponentFightResultRecorder.__super.Destroy(self)
end

function ComponentFightResultRecorder:Reset()

end

function ComponentFightResultRecorder:OnModelLoadComplete()

end

function ComponentFightResultRecorder:RecordFightResult(fightResult)
    if fightResult == nil then
        return
    end
    table.insert(self.m_RecordFightResultList, fightResult)
end

function ComponentFightResultRecorder:GetRecordedFightResultByType(fightResultType)
    for i = #self.m_RecordFightResultList, 1, -1 do
        local fightResult = self.m_RecordFightResultList[i]
        if fightResult ~= nil and fightResult.m_FightResultType == fightResultType then
            return fightResult
        end
    end

    return nil
end

function ComponentFightResultRecorder:GetRecordedBuffResultBySn(sn)
    for i = #self.m_RecordFightResultList, 1, -1 do
        local fightResult = self.m_RecordFightResultList[i]
        if fightResult ~= nil and fightResult.m_FightResultType == FightResultType.k_AddBuff and fightResult.m_Sn == sn then
            return fightResult
        end
    end

    return nil
end

function ComponentFightResultRecorder:RemoveFightResult(removeResult)
    if removeResult == nil then
        return
    end

    local removeIndex = -1
    for i = #self.m_RecordFightResultList, 1, -1 do
        local fightResult = self.m_RecordFightResultList[i]
        if fightResult == removeResult then
            removeIndex = i
            break
        end
    end

    if removeIndex > 0 then
        table.remove(self.m_RecordFightResultList, removeIndex)
    end
end

return ComponentFightResultRecorder