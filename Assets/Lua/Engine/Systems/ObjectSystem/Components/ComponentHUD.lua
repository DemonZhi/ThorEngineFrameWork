local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentHUD = class("ComponentHUD", ComponentBase)
local Core_UIManager = SGEngine.UI.UIManager
ComponentHUD.m_ComponentId = ComponentDefine.ComponentType.k_ComponentHUD

local k_headName = 'Bip001 Head'
local k_OffsetY = 0.9
local k_DefaultNameColor = UnityEngine.Color.white

function ComponentHUD:Init(object)
    ComponentHUD.__super.Init(self, object)
end

function ComponentHUD:OnInitHUDCallBack(uGUIFollowTransform)
    -- 对象销毁之后，回调回来
    if self.m_Owner == nil then 
        Core_UIManager.Instance:PushHUD(uGUIFollowTransform)
        return
    end

    self.m_HUDObj = uGUIFollowTransform.gameObject
    self.m_UGUIFollowTransform = uGUIFollowTransform

    self:InitHUD()
end

function ComponentHUD:InitHUD()
    local config = self.m_UGUIFollowTransform:GetComponent('UIBinder')
    local owner = self.m_Owner
    if config == nil then
        return
    end

    for i = 0, config.uiList.Count - 1 do
        local binderData = config.uiList[i]
        if binderData.go then
            self[binderData.name] = binderData.component
        end
    end

    self.m_UIBinder = config
    local name = owner.m_ObjectName
    if name == nil then
        self.txtName.text = self.m_Owner:GetObjectID()
    else
        self.txtName.text = name..self.m_Owner:GetObjectID()
    end

    local color = k_DefaultNameColor
    if owner:IsMonster() then
        color = owner:GetNameColor()
        if not color then
            color = k_DefaultNameColor
        end
    end
    self.txtName.color = color
    self.m_HUDObj.name = self.txtName.text
    self:ActiveLockTargetFlag(false)

    self.m_BillBoard3DUI = self.m_UGUIFollowTransform:GetComponent('BillBoard3DUI')

    local bodyPart = owner:GetBodyPartTransform(k_headName)
    self.m_UGUIFollowTransform:SetTarget(self.m_Owner:GetTransform(), Vector3.New(0, k_OffsetY, 0), Vector2.New(0, 0), bodyPart)

    ----hp
    local attrComponent = owner.m_AttrComponent
    if not attrComponent or ObjectManager.GetHero() == owner then
        self.m_EnableHpBar = false
    else
        self.m_EnableHpBar = true
        attrComponent:RegisterAttrChangeFunc(ComponentDefine.AttributeDefine.k_Hp, ComponentHUD.OnHpChange)
    end

    self.hpSlider.gameObject:SetActive(self.m_EnableHpBar)
    self.m_IsInit = true

    local maxHp = attrComponent:GetAttribute(ComponentDefine.AttributeDefine.k_MaxHp)
    local hp = attrComponent:GetAttribute(ComponentDefine.AttributeDefine.k_Hp)
    self:SetHpPercent(hp / maxHp, true)
end

function ComponentHUD:OnModelLoadComplete()
    Core_UIManager.Instance:PopHUD(function (uGUIFollowTransform)
        self:OnInitHUDCallBack(uGUIFollowTransform)
    end)
end

function ComponentHUD:Reset()
    self:InitHUD()
end

function ComponentHUD:Destroy()
    ComponentHUD.__super.Destroy(self)

    if self.m_UGUIFollowTransform ~= nil then 
        Core_UIManager.Instance:PushHUD(self.m_UGUIFollowTransform)
    end

    self.m_IsInit = false
end

function ComponentHUD:ActiveLockTargetFlag(enable)
    if not self.m_IsInit then 
        return
    end

    if self.lockTargetFlag then
        self.lockTargetFlag.gameObject:SetActive(enable)
    end
end

function ComponentHUD:SetDialogueEnable(enable)
    if not self.m_IsInit then
        return
    end

    if enable then
        self.dialogue.gameObject:SetActive(false)
    end
    self.dialogue.gameObject:SetActive(enable)
end

function ComponentHUD:SetDialogueContent(text)
    if not self.m_IsInit then
        return
    end

    self.dialogueText.text = text
end

function ComponentHUD:SetHpPercent(percent, noTween)
    if not self.m_IsInit then
        return
    end

    if not self.m_EnableHpBar then
        return
    end
    
    self.m_CurrentHpPercent = percent
    if noTween then
        self.m_LastHpPercent = percent
        self.m_StartHpLerping = false
    else
        self.m_StartHpLerping = true
    end
    self.hpSlider.value = percent
end

function ComponentHUD:SetName(name)
    if not self.m_IsInit then
        return
    end
    
    if not self.m_UIBinder then
        return
    end
    self.txtName.text = name
    self.m_HUDObj.name = name
end

function ComponentHUD:Update(deltaTime)
    if self.m_EnableHpBar then
        self:UpdateHp(deltaTime)
    end
end

function ComponentHUD:UpdateHp(deltaTime)
    if not self.m_StartHpLerping then
        return
    end

    local slider = self.hpSlider
    if not slider then
        return
    end
    local bgSlider = self.hpBgSlider
    if not bgSlider then
        return
    end
    local lastHpPercent = self.m_LastHpPercent
    if not lastHpPercent then
        return
    end

    local currentHpPercent = self.m_CurrentHpPercent
    if lastHpPercent == currentHpPercent then
        self.m_StartHpLerping = false
        self.bgSlider.value = currentHpPercent
        return
    end

    local newValue = math.lerp(currentHpPercent, lastHpPercent, 0.9)
    bgSlider.value = newValue
    self.m_LastHpPercent = newValue
end

function ComponentHUD.OnHpChange(owner, oldValue, newValue)
    local hudComponent = owner.m_HUDComponent
    local attrComponent = owner.m_AttrComponent
    if not hudComponent or not attrComponent then
        return
    end

    local maxHp = attrComponent:GetAttribute(ComponentDefine.AttributeDefine.k_MaxHp)
    --Logger.LogInfo("OnHpChange, old:%f, new:%f, maxHp:%s",oldValue, newValue, maxHp)
    local oldPercentage = oldValue / maxHp
    local newPercentage = newValue / maxHp
    local noTween = newPercentage >= oldPercentage
    --Logger.LogInfo("OnHpChange1, old:%f, new:%f, notween:%s",oldPercentage, newPercentage, noTween)
    hudComponent:SetHpPercent(newPercentage, noTween)
end

return ComponentHUD