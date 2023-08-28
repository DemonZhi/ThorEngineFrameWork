ProcedureManager = ProcedureManager or 
{
    m_Type2Procedure = {}
}

function ProcedureManager.AddProcedure(type, procedure)
    ProcedureManager.m_Type2Procedure[type] = procedure
end

function ProcedureManager.Init()
    for k, v in pairs(ProcedureManager.m_Type2Procedure) do
        if v.Init ~= nil then
            v.Init()
        end
    end
end

function ProcedureManager.Update(deltaTime)
    local currentProcedure = ProcedureManager.m_CurrentProcedure
    if currentProcedure and currentProcedure.Update then
        currentProcedure.Update(deltaTime)
    end
end

function ProcedureManager.BeforeChangeScene()
    local currentProcedure = ProcedureManager.m_CurrentProcedure
    if currentProcedure and currentProcedure.BeforeChangeScene then
        currentProcedure.BeforeChangeScene()
    end
end

function ProcedureManager.AfterChangeScene()
    local currentProcedure = ProcedureManager.m_CurrentProcedure
    if currentProcedure and currentProcedure.AfterChangeScene then
        currentProcedure.AfterChangeScene()
    end
end

function ProcedureManager.Destroy()
    for k, v in pairs(ProcedureManager.m_Type2Procedure) do
        if v.Destroy ~= nil then
            v.Destroy()
        end
    end
end

function ProcedureManager.ChangeProcedure(procedureType, ...)
    Logger.LogInfoFormat("[ProcedureManager](ChangeProcedure) procedureType = {0}", procedureType)
    local nextProcedure = ProcedureManager.m_Type2Procedure[procedureType]
    if nextProcedure == nil then
        return
    end
    local currentProcedure = ProcedureManager.m_CurrentProcedure
    if nextProcedure == currentProcedure then
        return
    end

    ProcedureManager.m_lastProcedureType = ProcedureManager.m_CurrentProcedureType
    ProcedureManager.m_CurrentProcedureType = procedureType
    ProcedureManager.m_CurrentProcedure = nextProcedure
    if currentProcedure ~= nil and currentProcedure.Leave ~= nil then
        Logger.LogInfoFormat("[ProcedureManager](ChangeProcedure) procedure: {0}.Leave()", ProcedureManager.m_lastProcedureType)
        currentProcedure.Leave()
    end

    if nextProcedure.Enter ~= nil then
        Logger.LogInfoFormat("[ProcedureManager](ChangeProcedure) procedure: {0}.Enter()", procedureType)
        nextProcedure.Enter(...)
    end
end

function ProcedureManager.GetCurrentProcedureType()
    return ProcedureManager.m_CurrentProcedureType
end

function ProcedureManager.GetLastProcedureType()
    return ProcedureManager.m_lastProcedureType
end

function ProcedureManager.GetCurrentProcedure()
    return ProcedureManager.m_CurrentProcedure
end

return ProcedureManager