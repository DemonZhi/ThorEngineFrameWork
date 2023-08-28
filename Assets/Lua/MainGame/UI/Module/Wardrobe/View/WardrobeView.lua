local WardrobeView = class('WardrobeView', BaseView)
local SubpartItem = require('MainGame/UI/Module/Wardrobe/View/Item/SubpartItem')
local AvatarMessage = require('MainGame/Message/AvatarMessage')
local AvatarSubpartTypeEnum = AvatarSubpartTypeEnum

--子类重写
function WardrobeView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)
    self.m_List = ScrollList.New(self.itemsScrollList, SubpartItem)

    self:AddButtonListener(self.closeBtn, function ()
        local tween = self.tweenTransform:DOLocalMoveX(274, 0.5)
        tween.onComplete = function()
            WardrobeController.CloseView()
        end
    end)

    self.tabToggles = {}
    for i = 1, self.tabsTransform.childCount do
        local tabTransform = self.tabsTransform:GetChild(i - 1)
        local tabToggle = tabTransform:GetComponent("Toggle")
        self:AddToggleOrSliderListener(tabToggle, function (isOn)
            if isOn then 
                self:ShowSubpart(i)
            end
        end)
        table.insert(self.tabToggles, tabToggle)
    end
end

function WardrobeView:OnOpen()
    self.tweenTransform:DOLocalMoveX(-274, 0.5)
    self.itemChecked.gameObject:SetActive(false)
    self.equipmentName.gameObject:SetActive(false)

    if self.tabToggles[AvatarSubpartTypeEnum.Hair].isOn == true then
        self:ShowSubpart(AvatarSubpartTypeEnum.Hair)
    else
        self.tabToggles[AvatarSubpartTypeEnum.Hair].isOn = true
    end
end

function WardrobeView:ShowSubpart(subpartType)
    self.itemChecked.gameObject:SetActive(false)
    self.equipmentName.gameObject:SetActive(false)
    local subpartList = {}
    local AvatarSubpartConfig = AvatarSubpartConfig
    local hero = ObjectManager.m_Hero
    for k, v in pairs(AvatarSubpartConfig) do
        if v.SubpartType == subpartType and self:IsValidSubpartForPlayer(v, hero) then
            table.insert(subpartList, {m_OwnerView = self, m_ConfigItem = v})
        end
    end
    self.m_SubpartList = subpartList
    self.m_List:SetLuaData(subpartList)
end

local function IsValueInList(list, value)
    if list == nil then
        return false
    end

    for i, v in ipairs( list ) do
        if value == v then
            return true
        end
    end
    return false
end

function WardrobeView:IsValidSubpartForPlayer(config, player)
    local jobId = player.m_AttrComponent:GetJobID()
    if not IsValueInList(config.JobArray, jobId) then
        return false
    end

    local gender = player.m_AttrComponent:GetGender()
    if not IsValueInList(config.GenderArray, gender) then
        return false
    end

    return true
end

function WardrobeView:OnClickSubpartItem(subpartItem)
    local subpartConfigItem = subpartItem.m_ItemData.m_ConfigItem
    self.itemChecked.gameObject:SetActive(true)
    self.equipmentName.gameObject:SetActive(true)
    self.itemChecked:SetParent(subpartItem.m_Transform, false)
    self.equipmentName.text = subpartConfigItem.Name
    AvatarMessage.SendSetAvatarSubpart(true, subpartConfigItem.SubpartType, subpartConfigItem.Id)
    -- local heroAvatarComponent = ObjectManager.m_Hero.m_AvatarComponent
    -- if heroAvatarComponent then
    --     heroAvatarComponent:ChangeSubpartByID(subpartConfigItem.Id)
    -- end
end

return WardrobeView