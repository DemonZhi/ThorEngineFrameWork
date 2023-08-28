local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local StateConsts = require("Engine/Systems/ObjectSystem/State/StateConsts")
local StateDefine = SGEngine.Core.StateDefine
local Core_EntityUtility = SGEngine.Core.EntityUtility
local ComponentIK = class("ComponentIK", ComponentBase)
ComponentIK.m_ComponentId = ComponentDefine.ComponentType.k_ComponentIK
-- 开启地面IK的动画
local EnableGrounderIKAnimationNames = {
    [StateConsts.k_SprintStopAnimationName] = true,
    [StateConsts.k_RunStopAnimationName] = true,
}
-- 特殊的模型(盆骨与脊椎分离)
local SpecialModelIDs = {
    [17] = true,
    [23] = true,
    [29] = true,
}
-- 特殊模型的地面IK盆骨名
local k_SpecialModelGrounderIKPelvisName = "Bip001"
-- 看向目标精灵的骨骼名
local k_LookAtSpriteBoneName = "Bip001 Head"
-- 注视目标的距离
local k_LookAtTargetDistance = 5
-- 检测注视目标时间
local k_CheckLookAtTargetTime = 0.1

function ComponentIK:Init(object)
    ComponentIK.__super.Init(self, object)
    self.m_IsInit = false
end

function ComponentIK:OnModelLoadComplete()
    local GameSettings = GameSettings
    k_LookAtTargetDistance = tonumber(GameSettings["LookAtTargetDistance"].Value)
    local lookAtSpeed = tonumber(GameSettings["LookAtTargetSpeed"].Value)
    local lookBackSpeed = tonumber(GameSettings["LookForwardSpeed"].Value)
    self.m_Owner.m_Core:SetIKLookAtSpeed(lookAtSpeed)
    self.m_Owner.m_Core:SetIKLookBackSpeed(lookBackSpeed)
    self.m_IsLookingAtCamera = false
    self:InitIK()
end

function ComponentIK:Update(deltaTime)
    ---这里多加一个Init是因为OnModelLoadComplete前 IsModelLoadFinish会置true，但是那个是异步回调调回来的，此时这里就可能会跑到Update
    if self.m_Owner:IsModelLoadFinish() == false or self.m_IsInit == false then
        return
    end
    self:CheckGroundIKEnable()
    self:UpdateLookAtIK(deltaTime)
end

function ComponentIK:Destroy()
    ComponentIK.__super.Destroy(self)
    self.m_IsLookingAtCamera = false
    self.m_IsInit = false
end

function ComponentIK:Reset()
    self:InitIK()
end

function ComponentIK:InitIK()
    self.m_LastGrounderIKEnable = false
    self.m_IsInit = true
    local owner = self.m_Owner
    if SpecialModelIDs[owner.m_ResourceId] == true then
        owner.m_Core:SetGrounderIKPelvisByName(k_SpecialModelGrounderIKPelvisName)
    end

    self.m_LookAtTransform = nil
    self.m_IsNotCheckTargetInvalid = false
    self.m_CheckLookAtTargetDeltaTime = 0
end

function ComponentIK:CheckGroundIKEnable()
    local owner = self.m_Owner
    local currentAnimName = owner.m_Core:GetCurrentAnimationName()
    local isEnable = (EnableGrounderIKAnimationNames[currentAnimName] == true)

    if isEnable ~= self.m_LastGrounderIKEnable then
        self.m_LastGrounderIKEnable = isEnable
        owner.m_Core:SetGrounderIKEnable(isEnable)
    end
end

--region LookAtIK
function ComponentIK:LookAtSGSprite(sprite, notCheckInvalid)
    local targetTransform
    if sprite ~= nil then
        targetTransform = sprite:GetBodyPartTransform(k_LookAtSpriteBoneName)
    end
    self.m_IsLookingAtCamera = false
    self.m_LookAtTransform = targetTransform
    self.m_Owner.m_Core:SetLookAtTarget(targetTransform)
    self.m_IsNotCheckTargetInvalid = notCheckInvalid or false
end

function ComponentIK:LookAtTransform(transform, notCheckInvalid)
    if self.m_LookAtTransform == transform then
        return
    end
    self.m_IsLookingAtCamera = false
    self.m_LookAtTransform = transform
    self.m_Owner.m_Core:SetLookAtTarget(transform)
    self.m_IsNotCheckTargetInvalid = notCheckInvalid or false
end

function ComponentIK:LookAtCamera(notCheckInvalid)
    if self.m_IsLookingAtCamera == true then
        return
    end
    self.m_IsLookingAtCamera = true
    self.m_Owner.m_Core:SetLookAtCamera()
    self.m_IsNotCheckTargetInvalid = notCheckInvalid or false
end

function ComponentIK:CancelLookAt()
    self.m_LookAtTransform = nil
    self.m_IsLookingAtCamera = false
    self.m_Owner.m_Core:CancelLookAt()
    self.m_IsNotCheckTargetInvalid = false
end

function ComponentIK:UpdateLookAtIK(deltaTime)
    if self.m_LookAtTransform ~= nil or self.m_IsLookingAtCamera then
        local isKeepLook = true
        repeat
            if self.m_IsNotCheckTargetInvalid == true then
                break
            end

            if self.m_IsLookingAtCamera == true then
                isKeepLook = (self.m_Owner:IsState(StateDefine.k_StateIdle) and self:IsCameraInLookAtRange())
                break
            end

            isKeepLook = self:IsInLookAtRangeByTarget(self.m_LookAtTransform)
        until true

        if not isKeepLook then
            self:CancelLookAt()
        end
    else
        self.m_CheckLookAtTargetDeltaTime = self.m_CheckLookAtTargetDeltaTime + deltaTime
        if self.m_CheckLookAtTargetDeltaTime > k_CheckLookAtTargetTime then
            self.m_CheckLookAtTargetDeltaTime = 0
            -- idle状态时相机是否在视野内
            if self.m_Owner:IsState(StateDefine.k_StateIdle) == false then
                return
            end

            if not self.m_IsLookingAtCamera and self:IsCameraInLookAtRange() then
                self:LookAtCamera()
            elseif self.m_IsLookingAtCamera == false and self:IsInLookAtRange(self.m_LookAtTransform) then
                self:LookAtTransform(self.m_LookAtTransform)
            end
        end
    end
end

-- 目标是否在视野范围内
function ComponentIK:IsInLookAtRangeByTarget(targetTransform)
    if targetTransform == nil then
        return false
    end

    return self:IsInLookAtRange(targetTransform)
end

function ComponentIK:IsInLookAtRange(targetTransform)
    local myObjID = self.m_Owner:GetObjectID()
    local distance = Core_EntityUtility.GetDistanceBetweenObjectAndTransform(myObjID, targetTransform)
    local isInFront = Core_EntityUtility.IsTransformInFrontOfObj(myObjID, targetTransform)
    local isInLookAtRange = true
    if distance > k_LookAtTargetDistance then
        isInLookAtRange = false
    else
        if isInFront == false then
            isInLookAtRange = false
        end
    end
    return isInLookAtRange
end

function ComponentIK:IsCameraInLookAtRange()
    local myObjID = self.m_Owner:GetObjectID()
    local distance = Core_EntityUtility.GetDistanceBetweenObjectAndObjCamera(myObjID)
    local isInFront = Core_EntityUtility.IsObjCameraInFrontOfObj(myObjID)
    local isInLookAtRange = true
    if distance > k_LookAtTargetDistance then
        isInLookAtRange = false
    else
        if isInFront == false then
            isInLookAtRange = false
        end
    end
    return isInLookAtRange
end
--endregion

return ComponentIK