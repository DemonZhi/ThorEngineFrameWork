local SkillView = class('SkillView', BaseView)
local SkillButton = require("MainGame/UI/Module/Action/View/SkillButton")
local BattleMessage = require("MainGame/Message/BattleMessage")
local SkillConfigData = require("MainGame/ConfigData/SkillConfigData")
local TouchButton = require("Engine/UI/Base/TouchButton")
local EventDefine = require("Engine/UI/Event/EventDefine")
local uIEventTriggerListener = System.Type.GetType("SGEngine.UI.UIEventTriggerListener")
local GmMessage = require("MainGame/Message/GmMessage")

local TestModelMap = {
    [29] = { resourceId = 29, skillId1 = 204104, skillId2 = 204101, skillId3 = 204103, skillId4 = 204103, hasMount = false, hasDodge = true, hasSprint = true },
    [17] = { resourceId = 17, skillId1 = 40101, skillId2 = 40105, skillId3 = 40108, skillId4 = 40105, hasMount = false, hasDodge = false, hasSprint = true },
    [16] = { resourceId = 16, skillId1 = 202001, skillId2 = 2020021, skillId3 = 2020021, skillId4 = 202003, hasMount = true, hasDodge = true, hasSprint = true },
    [23] = { resourceId = 23, skillId1 = 500101, skillId2 = 500201, skillId3 = 500301, skillId4 = 500401, hasMount = false, hasDodge = false, hasSprint = true },
    [24] = { resourceId = 24, skillId1 = 201001, skillId2 = 201004, skillId3 = 201002, skillId4 = 211011, jumpSprintSkillID = 201013, sprintSkillID = 201010, hasMount = true, hasDodge = true, hasSprint = true, hasSprintAttack = true },
    [31] = { resourceId = 31, skillId1 = nil, skillId2 = nil, skillId3 = nil, skillId4 = nil, hasMount = true, hasDodge = false, hasSprint = true },
    [30] = { resourceId = 30, skillId1 = nil, skillId2 = nil, skillId3 = nil, skillId4 = nil, hasMount = true, hasDodge = false, hasSprint = true },
    [34] = { resourceId = 34, skillId1 = 206001, skillId2 = 206002, skillId3 = 206017, skillId4 = 206013, skillId5 = 206003, hasMount = false, hasDodge = true, hasSprint = true },
}
-- 206003 206001
local k_HideInBattleUIAngle = Vector3.New(0, 0, -180)
local StateDefine = SGEngine.Core.StateDefine
local SkillType = SGEngine.Core.SkillDefines

--子类重写
function SkillView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self.m_ModelName = 'pre_SM001'
    self.m_AvatarID = 3

    self.skillButton0 = SkillButton.New(self.btnAttack.transform)
    self.skillButton1 = SkillButton.New(self.btnSkill1.transform)
    self.skillButton2 = SkillButton.New(self.btnSkill2.transform)
    self.skillButton3 = SkillButton.New(self.btnSkill3.transform)
    self.skillButton4 = SkillButton.New(self.btnSkill4.transform)

    self.m_SkillButtonList = {}
    table.insert(self.m_SkillButtonList, self.skillButton0)
    table.insert(self.m_SkillButtonList, self.skillButton1)
    table.insert(self.m_SkillButtonList, self.skillButton2)
    table.insert(self.m_SkillButtonList, self.skillButton3)
    table.insert(self.m_SkillButtonList, self.skillButton4)

    self.btnSprint.gameObject:SetActive(false)
    self:AddButtonListener(self.btnSprint, function()
        local hero = ObjectManager.GetHero()
        if hero == nil then
            return
        end

        if hero:IsState(StateDefine.k_StateSwim) then
            hero:SwimSprint()
        else
            hero:Move(nil, true)
        end
    end)

    self:AddButtonListener(self.btnSwimSprint, function()
        local hero = ObjectManager.GetHero()
        if hero then
            hero:SwimDive()
        end
    end)

    self:AddButtonListener(self.btnJump, function()
        local hero = ObjectManager.GetHero()
        if hero then
            hero:ChangeToJump()
        end
    end)

    self:AddButtonListener(self.btnOpenObstacleMask, function ()
        PlaceTriggerController.OpenPlaceTriggerView()
    end)

    self:AddButtonListener(self.btnLookHero, function()
        local hero = ObjectManager.GetHero()
        hero:AllowDisconnect(false)
        hero:CameraControllerResetZoomScale(false)
        TimerManager:AddFrameTimer(nil, function()
            hero:AllowDisconnect(true)
        end, 10, 1)
    end)

    self:AddButtonListener(self.btnDodge, function()
        local hero = ObjectManager.GetHero()
        if hero then
            hero:ChangeToDodge()
        end
    end)

    --self:AddButtonListener(self.btnChangeFace, function ()
    --    local hero = ObjectManager.GetHero()
    --
    --    if hero then
    --        if self.faceID == nil then
    --            self.faceID = 0
    --        end
    --        hero:ChangeFaceMakeup("Face", self.faceID)
    --        self.faceID = (self.faceID + 1) % 3
    --    end
    --end)

    self.isShowContent = true
    self:AddButtonListener(self.btnShow, function()
        self.isShowContent = not self.isShowContent
        self.content.gameObject:SetActive(self.isShowContent)
    end)

    self.btnOnRide.gameObject:SetActive(true)
    self.btnOffRide.gameObject:SetActive(false)
    self:AddButtonListener(self.btnOnRide, function()
        local hero = ObjectManager.GetHero()
        if hero then
            hero.m_RideComponent:GetOnRide(1)
        end
    end)
    self:AddButtonListener(self.btnOffRide, function()
        local hero = ObjectManager.GetHero()
        if hero and hero:IsState(StateDefine.k_StateJump) == false then
            hero.m_RideComponent:GetOffRide()
        end
    end)
    self:AddButtonListener(self.btnShowInFight, function()
        if not self.m_IsInBattleUIActive then
            self:ActiveInBattleUI(true, true)
        end
    end)
    self:AddButtonListener(self.btnWardrobe, function()
        WardrobeController.OpenView()
    end)
    self:AddButtonListener(self.btnRevive, function()
        BattleMessage.SendRevive()
    end)
    self:AddButtonListener(self.btnSprintAttack, function()
        local hero = ObjectManager.GetHero()
        if not hero then
            return
        end

        local modelID = hero:GetModelID()
        local info = TestModelMap[modelID]
        if not info then
            Logger.LogErrorFormat("[SkillView](btnSprintAttack) None ModelID:" .. tostring(modelID))
            return
        end

        local jumpSprintSkillID = info.jumpSprintSkillID
        local sprintSkillID = info.sprintSkillID
        if jumpSprintSkillID and hero:CanUseJumpSkill(jumpSprintSkillID) then
            hero:UseJumpSkill(jumpSprintSkillID)
        elseif sprintSkillID then
            hero:UseSkill(sprintSkillID)
        end
    end)

    self.m_OnSearchAndLockHandle = function()
        local hero = ObjectManager.GetHero()
        if not hero or not hero.m_SkillTargetComponent then
            return
        end

        if not hero.m_SkillTargetComponent:TrySearchTarget(true) then
            AlertController.ShowTips("没有找到有效目标")
        end
    end
    self:AddButtonListener(self.btnSearchAndLock, self.m_OnSearchAndLockHandle)
    if UNITY_EDITOR then
        TimerManager:AddFrameTimer(nil, function()
            if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Tab) then
                self.m_OnSearchAndLockHandle()
            end
        end, 1, 0)
    end
    self:RefreshRole()
end

function SkillView:ShowSkillCD(skillId, coolDown)
    for i, button in ipairs(self.m_SkillButtonList) do
        button:RefreshCD(skillId)
    end
end

function SkillView:OnOpen()
    Dispatcher.AddEventListener(
            UICommandConfig.Skill.ADD_SKILL_CD,
            function(data)
                self:ShowSkillCD(data)
            end
    )
    local hero = ObjectManager.GetHero()
    if hero == nil then
        return
    end
    local dispatcher = hero.m_EventDispatcherComponent
    if dispatcher then
        self.m_OnBattleCallBack = function()
            if self.m_CheckHideInFightUITimerID then
                TimerManager:RemoveTimer(self.m_CheckHideInFightUITimerID)
                self.m_CheckHideInFightUITimerID = nil
            end
        end
        --self.m_OnOffBattleCallBack = function()
        --    self:ActiveInBattleUI(false, true)
        --end
        dispatcher:AddEventListener(EventDefine.k_OnBattle, self.m_OnBattleCallBack)
        --dispatcher:AddEventListener(EventDefine.k_OffBattle, self.m_OnOffBattleCallBack)
    end
    self:ActiveInBattleUI(false)
end

function SkillView:OnClose()
    Dispatcher.RemoveEventListener(UICommandConfig.Skill.ADD_SKILL_CD)
    local dispatcher = ObjectManager.GetHero().m_EventDispatcherComponent
    if dispatcher then
        dispatcher:RemoveEventListener(EventDefine.k_OnBattle, self.m_OnBattleCallBack)
        dispatcher:RemoveEventListener(EventDefine.k_OffBattle, self.m_OnOffBattleCallBack)
    end
    self.m_OnBattleCallBack = nil
    self.m_OnOffBattleCallBack = nil
end

function SkillView:OnDestroy()
    if self.m_CheckHideInFightUITimerID then
        TimerManager:RemoveTimer(self.m_CheckHideInFightUITimerID)
        self.m_CheckHideInFightUITimerID = nil
    end
end

function SkillView:SetSprintBtnActive(active)
    if not active then
        self.btnSprint.gameObject:SetActive(active)
    else
        local hero = ObjectManager.GetHero()
        if not hero then
            return
        end
        local modelID = hero:GetModelID()
        local info = TestModelMap[modelID]
        if not info then
            Logger.LogErrorFormat("[SkillView](RefreshRole) None ModelID:" .. tostring(modelID))
            return
        end

        if not info.hasSprint then
            return
        end
        self.btnSprint.gameObject:SetActive(active)
    end
end


function SkillView:SetStoryBtnActive(active)
    -- self.btnStory0.gameObject:SetActive(active)
    -- self.btnStory1.gameObject:SetActive(active)
    -- self.btnStory2.gameObject:SetActive(active)
end

function SkillView:SetSwimDiveBtnActive(active)
    self.btnSwimSprint.gameObject:SetActive(active)
end

function SkillView:GetSprintBtnActive()
    return self.btnSprint.gameObject.activeSelf
end

function SkillView:SetOnRideBtnActive(active)
    self.btnOnRide.gameObject:SetActive(active)
end

function SkillView:GetOnRideBtnActive()
    return self.btnOnRide.gameObject.activeSelf
end

function SkillView:SetOffRideBtnActive(active)
    self.btnOffRide.gameObject:SetActive(active)
end

function SkillView:SetSwimBtnActive(active)
    self.btnSwimSprint.gameObject:SetActive(active)
end

function SkillView:SetLoadModelActive(active)
    self.btnLoadModel.gameObject:SetActive(active)
end

function SkillView:RefreshSkill(info)
    if info then
        self:RefreshSkillButton(self.skillButton0, info.skillId1)
        self:RefreshSkillButton(self.skillButton1, info.skillId2)
        self:RefreshSkillButton(self.skillButton2, info.skillId3)
        self:RefreshSkillButton(self.skillButton3, info.skillId4)
        self:RefreshSkillButton(self.skillButton4, info.skillId5)
    end
end

function SkillView:RefreshSkillButton(button, skillId)
    if not skillId then 
        return
    end

    local config = SkillConfigData:Get(skillId)
    if not config then
        return
    end

    local hasCharge = config.SkillModule == SkillType.k_SkillTypeCharge
    local type = TouchButton.TouchButtonModeEnum.Continuous
    if hasCharge then
        type = TouchButton.TouchButtonModeEnum.OneTime
    end
    button:RefreshData(skillId, type)
end

function SkillView:RefreshMountByResourceId(resourceId)
    local LogInfo = nil
    for i, v in ipairs(TestModelMap) do
        if v.resourceId == resourceId then
            LogInfo = v
        end
    end

    if LogInfo then
        self:RefreshMount(LogInfo.hasMount)
    else
        self:RefreshMount(false)
    end
end

function SkillView:RefreshMount(hasMount)
    self.btnOffRide.gameObject:SetActive(false)
    if hasMount == true then
        self.btnOnRide.gameObject:SetActive(true)
    else
        self.btnOnRide.gameObject:SetActive(false)
    end
end

function SkillView:RefreshDodgeBtn(hasDodge)
    self.btnDodge.gameObject:SetActive(false)
    if hasDodge == true then
        self.btnDodge.gameObject:SetActive(true)
    else
        self.btnDodge.gameObject:SetActive(false)
    end
end

function SkillView:RefreshSprintBtn(hasSprint)
    self.btnSprint.gameObject:SetActive(false)
    if hasSprint == true then
        self.btnSprint.gameObject:SetActive(true)
    else
        self.btnSprint.gameObject:SetActive(false)
    end
end

function SkillView:ActiveInBattleUI(enable, tween)
    if self.m_IsInBattleUIActive == enable then
        return
    end

    self.m_IsInBattleUIActive = enable
    if enable then
        if tween then
            self.skillSet1:DOLocalRotate(Vector3.zero, 0.2)
        else
            self.skillSet1.localEulerAngles = Vector3.zero
        end
    else
        if tween then
            self.skillSet1:DOLocalRotate(k_HideInBattleUIAngle, 0.2)
        else
            self.skillSet1.localEulerAngles = k_HideInBattleUIAngle
        end
    end

    self.btnAttack.gameObject:SetActive(enable)
    self.btnShowInFight.gameObject:SetActive(not enable)
    if self.m_CheckHideInFightUITimerID then
        TimerManager:RemoveTimer(self.m_CheckHideInFightUITimerID)
        self.m_CheckHideInFightUITimerID = nil
    end
    self.m_CheckHideInFightUITimerID = TimerManager:AddTimer(nil, function()
        self:ActiveInBattleUI(false, true)
    end, 20)
end

function SkillView:RefreshReviveBtn()
    local hero = ObjectManager.GetHero()
    if not hero then
        self:SetReviveBtnActive(false)
        return
    end

    local needShow = false
    if hero:IsState(StateDefine.k_StateDead) then
        needShow = true
    end
    self:SetReviveBtnActive(needShow)
end

function SkillView:SetReviveBtnActive(active)
    self.btnRevive.gameObject:SetActive(active)
end

function SkillView:SetSprintAttackBtnActive(active)
    local modelID = ObjectManager.GetHero():GetModelID()
    local info = TestModelMap[modelID]
    if info and info.hasSprintAttack then
        self.btnSprintAttack.gameObject:SetActive(active)
    else
        self.btnSprintAttack.gameObject:SetActive(false)
    end
end

function SkillView:RefreshRole()
    local modelID = ObjectManager.GetHero():GetModelID()
    local info = TestModelMap[modelID]
    if not info then
        Logger.LogErrorFormat("[SkillView](RefreshRole) None ModelID:" .. tostring(modelID))
        return
    end
    self:RefreshSkill(info)
    self:RefreshMount(info.hasMount)
    self:RefreshDodgeBtn(info.hasDodge)
    self:RefreshSprintBtn(info.hasSprint)
    self:RefreshReviveBtn()
    self:SetSprintAttackBtnActive(false)
end

return SkillView
