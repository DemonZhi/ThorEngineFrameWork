local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentEffectAmountControl = class("ComponentEffectAmountControl", ComponentBase)
ComponentEffectAmountControl.m_ComponentId = ComponentDefine.ComponentType.k_ComponentEffectAmountControl
ComponentEffectAmountControl.k_EffectNumForSingleHangPoint = 3

function ComponentEffectAmountControl:Init(object)
    self.m_CurrentEffectMap = {}
    ComponentEffectAmountControl.__super.Init(self, object)
end

function ComponentEffectAmountControl:TryRegisterEffect(effectId, hangPoint)
    if hangPoint == nil then
        hangPoint = -1
    end
    local hangPoints = self.m_CurrentEffectMap[effectId]
    if not hangPoints then
        hangPoints = {}
        hangPoints[hangPoint] = 1
        self.m_CurrentEffectMap[effectId] = hangPoints
        return true
    end

    local currentNum = hangPoints[hangPoint]
    if not currentNum then
        hangPoints[hangPoint] = 1
        return true
    end

    if currentNum < ComponentEffectAmountControl.k_EffectNumForSingleHangPoint then
        hangPoints[hangPoint] = currentNum + 1
        return true
    end

    return false
end

function ComponentEffectAmountControl:UnRegisterEffect(effectId, hangPoint)
    if hangPoint == nil then
        hangPoint = -1
    end
    local hangPoints = self.m_CurrentEffectMap[effectId]
    if not hangPoints then
        return
    end

    local currentNum = hangPoints[hangPoint]
    if not currentNum then
        return
    end

    hangPoints[hangPoint] = math.max(0, currentNum - 1)
end

function ComponentEffectAmountControl:Destroy()
    self.m_Owner = nil
    self.m_CurrentEffectMap = nil
end

function ComponentEffectAmountControl:Reset()
    self.m_CurrentEffectMap = {}
end

return ComponentEffectAmountControl