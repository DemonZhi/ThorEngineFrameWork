local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentAvatar = class("ComponentAvatar", ComponentBase)
ComponentAvatar.m_ComponentId = ComponentDefine.ComponentType.k_ComponentAvatar
local AvatarSubpartTypeEnum = AvatarSubpartTypeEnum

local AvatarSubpartType2Name = 
{
    [AvatarSubpartTypeEnum.Body] = "Body",
    [AvatarSubpartTypeEnum.Weapon] = "MainWeapon",
}

local AvatarSubpartIsAttach = 
{
    [AvatarSubpartTypeEnum.Hair] = true,
    [AvatarSubpartTypeEnum.Body] = false,
    [AvatarSubpartTypeEnum.Weapon] = false,
}

function ComponentAvatar:Init(object)
    ComponentAvatar.__super.Init(self, object)
    self.m_DefaultSubpart = {}
    self.m_CustomSubpartDict = {}
    self.m_EquipSubpartDict = {}
    self.m_WearSubpartDict = {}


    self.m_DefaultSubpartCount = 0
    self.m_DefaultLoadSucessCount = 0
end

function ComponentAvatar:IsCompletedDefaultAvatar()
    if self.m_DefaultLoadSucessCount >= self.m_DefaultSubpartCount then
        return true
    end
    return false
end

function ComponentAvatar:OnModelLoadComplete()
    self:InitDefaultSubpart()
end

function ComponentAvatar:Deserialize(netBuffer)
    self.m_CustomSubpartDict = {}
    local num = netBuffer:ReadInt()
    for i = 1, num do
        local subpartType = netBuffer:ReadUByte()
        local configID = netBuffer:ReadInt()
        self.m_CustomSubpartDict[subpartType] = configID
    end
    
    self.m_WearSubpartDict = {}
    num = netBuffer:ReadInt()
    for i = 1, num do
        local subpartType = netBuffer:ReadUByte()
        local configID = netBuffer:ReadInt()
        self.m_WearSubpartDict[subpartType] = configID
    end
end

function ComponentAvatar:DeserializeEquip(netBuffer)
    local num = netBuffer:ReadUByte()
    for i = 1, num do
        local equip_id = netBuffer:ReadInt()
        -- 等有装备再加上
    end
end

function ComponentAvatar:Update(deltaTime)
end

function ComponentAvatar:Destroy()
    ComponentAvatar.__super.Destroy(self)
end

function ComponentAvatar:Reset()
    self:InitDefaultSubpart()
end

function ComponentAvatar:InitDefaultSubpart()
    self.m_DefaultSubpart = {}
    self.m_DefaultSubpartCount = 0
    self.m_DefaultLoadSucessCount = 0

    local modelConfigItem = ModelConfig[self.m_Owner.m_ResourceId]
    local avatarSubpartConfig = AvatarSubpartConfig

    if modelConfigItem.DefaultSubpartList then
        for _, v in pairs(modelConfigItem.DefaultSubpartList) do
            local subpartConfigItem = avatarSubpartConfig[v]
            if subpartConfigItem then
                self.m_DefaultSubpart[subpartConfigItem.SubpartType] = subpartConfigItem.Id
                self.m_DefaultSubpartCount = self.m_DefaultSubpartCount + 1
            end
        end
    end

    if self.m_DefaultSubpartCount > 0 then
       self.m_Owner:SetAllMeshRenderActive(false)
    else
        self.m_Owner:SetAllMeshRenderActive(true)
    end
    self:RefreshSubpart(defaultCallBack)
end

function ComponentAvatar:RefreshSubpart(callBack)
    for k, v in pairs(AvatarSubpartTypeEnum) do
        local configID = self:GetPrioritySubpartID(v)
        if configID ~= nil then
            self:ChangeSubpartByID(configID, callBack)
        end
    end
end

function ComponentAvatar:ChangeSubpart(subpartType, resName, attachPointPath, callBack, boneConfigAddress)
    local loadCompletedCallBack = function (go, isSucess)
        if callBack ~= nil then
            callBack(go, isSucess)
        end
        if not self:IsCompletedDefaultAvatar() then
            if go ~= nil then
                go:SetActive(false)
            end
            self.m_DefaultLoadSucessCount = self.m_DefaultLoadSucessCount + 1
            if self:IsCompletedDefaultAvatar() then
                if self.m_Owner ~= nil then
                   self.m_Owner:SetAllMeshRenderActive(true)
                end
            end
        end
    end

    if AvatarSubpartIsAttach[subpartType] == true then
        if resName == nil or attachPointPath == nil then
            loadCompletedCallBack(nil, false)
        else
            self.m_Owner:EquipGameObject(attachPointPath, resName, loadCompletedCallBack)
        end
    else
        if self.m_IsLoadResourceSync then
            self.m_Owner:ChangeSkin(AvatarSubpartType2Name[subpartType], resName, boneConfigAddress)
            loadCompletedCallBack(nil, true)
        else
            self.m_Owner:ChangeSkinAsync(AvatarSubpartType2Name[subpartType], resName, loadCompletedCallBack, boneConfigAddress)
        end
    end
end

function ComponentAvatar:ChangeSubpartByID(id, callBack)
    if not id then
        return
    end
    local subpartConfigItem = AvatarSubpartConfig[id]
    if subpartConfigItem then
        self:ChangeSubpart(subpartConfigItem.SubpartType, subpartConfigItem.PrefabAddress, 
            subpartConfigItem.MountPointPath, nil , subpartConfigItem.BoneConfigAddress)
    else
        Logger.LogErrorFormat("[ComponentAvatar](ChangeSubpartByID) not found subpartConfigItem by ID -> %s", id)
    end
end

function ComponentAvatar:GetPrioritySubpartID(subpartType)
    -- 时装
    local subpartID = self.m_WearSubpartDict[subpartType]
    if subpartID and subpartID > 0 then
        return subpartID
    end

    -- 装备
    subpartID = self.m_EquipSubpartDict[subpartType]
    if subpartID and subpartID > 0 then
        return subpartID
    end

    -- 自定义
    subpartID = self.m_CustomSubpartDict[subpartType]
    if subpartID and subpartID > 0 then
        return subpartID
    end

    -- 默认
    subpartID = self.m_DefaultSubpart[subpartType]
    if subpartID and subpartID > 0 then
        return subpartID
    end
end

function ComponentAvatar:SetCustomSubpart(subpartType, configID, isOn, isNoApply)
    self:SetSubpartInner(self.m_CustomSubpartDict, subpartType, configID, isOn, isNoApply)
end

function ComponentAvatar:ClearCustomSubpart(isNoApply)
    self.m_CustomSubpartDict = {}
    if isNoApply then
        return
    end
    self:RefreshSubpart()
end

function ComponentAvatar:SetWearSubpart(subpartType, configID, isOn, isNoApply)
    self:SetSubpartInner(self.m_WearSubpartDict, subpartType, configID, isOn, isNoApply)
end

function ComponentAvatar:ClearWearSubpart(isNoApply)
    self.m_WearSubpartDict = {}
    if isNoApply then
        return
    end
    self:RefreshSubpart()
end

function ComponentAvatar:SetEquipSubpart(subpartType, configID, isOn, isNoApply)
    self:SetSubpartInner(self.m_EquipSubpartDict, subpartType, configID, isOn, isNoApply)
end

function ComponentAvatar:ClearEquipSubpart(isNoApply)
    self.m_EquipSubpartDict = {}
    if isNoApply then
        return
    end
    self:RefreshSubpart()
end

function ComponentAvatar:SetSubpartInner(subpartDict, subpartType, configID, isOn, isNoApply)
    local preConfigID = self:GetPrioritySubpartID(subpartType)
    if isOn then
        subpartDict[subpartType] = configID
    else
        subpartDict[subpartType] = nil
    end

    if isNoApply then
        return
    end

    local afterConfigID = self:GetPrioritySubpartID(subpartType)
    if preConfigID ~= afterConfigID then
        self:ChangeSubpartByID(afterConfigID)
    end
end

-- 慎用！慎之又慎！如果要用同步加载、一定要保证基础模型存在资源池中！不然会造成在基础模型的异步回调中等待其他部件同步的错误！
function ComponentAvatar:SetIsLoadResourceSync(isSync)
    self.m_IsLoadResourceSync = isSync
end



return ComponentAvatar
