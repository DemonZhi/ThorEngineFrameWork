local CreateRoleItem = require('MainGame/UI/Module/CreateRole/View/CreateRoleItem')
local ProcedureCreateRole = require("MainGame/Game/Procedure/ProcedureCreateRole")
local CreateRoleMessage = require("MainGame/Message/CreateRoleMessage")
local JobIDEnum = require("MainGame/Common/Const/JobIDEnum")
local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local CreateRoleView = class('CreateRoleView', BaseView)
 

--子类重写
function CreateRoleView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self.m_List = ScrollList.New(self.roleList, CreateRoleItem)
    self:AddButtonListener(self.btnEnterGame, function ()
        local name = self.inputFieldName.text
        if self:CheckPlayerName(name) then
            local accountData = AccountManager.GetAccountData()
            local slot = CreateRoleController.model:GetFirstEmptyCreateSlot()
            local faceBlendshapeList = MakeupController.GetFaceBlendShapeList()
            local faceTextureIndexList = MakeupController.GetFaceTextureIndexList()

            CreateRoleMessage.SendCreatePlayer(accountData.accountId, self.m_SelectedItemData.jobID, name, slot, self.m_SelectedGender, faceBlendshapeList, faceTextureIndexList)
        end
    end)

    self:AddButtonListener(self.btnBack, function ()
        if self.m_HadSendRandomName then
            CreateRoleMessage.SendUnlockRandomName()
        end

        CreateRoleController.CloseCreateRoleView()
        CreateRoleController.OpenSelectRoleView()
    end)

    self:AddButtonListener(self.btnForward, function ()
        if self.m_HadSendRandomName then
            CreateRoleMessage.SendUnlockRandomName()
        end

        CreateRoleController.CloseCreateRoleView()
        MakeupController.SetGender(self.m_SelectedGender)
        MakeupController.SetRoleJobID(self.m_SelectedItemData.jobID)
        MakeupController.OpenView()
    end)

    self:AddButtonListener(self.btnRandom, function ()
        self.m_HadSendRandomName = true
        CreateRoleMessage.SendGetRandomName(self.m_SelectedGender)
    end)
end

function CreateRoleView:OnOpen()
    self.m_HadSendRandomName = false
    self.inputFieldName.text = string.Empty
    self.m_SelectedGender = GenderTypeEnum.Male
    local createRoleModel = CreateRoleController.model
    local itemDataList = {}
    local jobConfig = JobConfig
    for i = JobIDEnum.Min, JobIDEnum.Max do
        local jobCfgItem = jobConfig[i]
        local itemData = 
        {
            jobID = jobCfgItem.Id, 
            name = jobCfgItem.Name,
            maleModelID = jobCfgItem.MaleModelID, 
            femaleModelID = jobCfgItem.FemaleModelID, 
            ownerView = self, 
            index = i,
        }
        table.insert(itemDataList, itemData)
    end
    self.m_List:SetLuaData(itemDataList)
    self.m_SelectedItemData = itemDataList[1]
    self.btnBack.gameObject:SetActive(createRoleModel:GetPlayerCount() > 0)
    ProcedureCreateRole.ChangeModel(self.m_SelectedItemData.maleModelID, self.m_SelectedGender)
    self.m_List:DoRefresh()
end

function CreateRoleView:OnItemSelected(itemData)
    if self.m_SelectedItemData == itemData then
        return
    end

    self.m_SelectedGender = GenderTypeEnum.Male
    self.m_SelectedItemData = itemData
    self.m_List:DoRefresh()
    ProcedureCreateRole.ChangeModel(itemData.maleModelID, self.m_SelectedGender)
end

function CreateRoleView:GetSelectedItemIndex()
    return self.m_SelectedItemData and self.m_SelectedItemData.index or 1
end

function CreateRoleView:OnGenderSelected(gender)
    if self.m_SelectedGender ~= gender then
        self.m_SelectedGender = gender
        local modelID = (gender == GenderTypeEnum.Male and self.m_SelectedItemData.maleModelID or self.m_SelectedItemData.femaleModelID)
        ProcedureCreateRole.ChangeModel(modelID, gender)
    end
end

function CreateRoleView:GetSelectedGender()
    return self.m_SelectedGender
end

function CreateRoleView:SetRandomName(name)
    self.inputFieldName.text = name
end

function CreateRoleView:CheckPlayerName(name)
    if string.IsNullOrEmpty(name) then
        AlertController.ShowTips("名字不能为空")
        return false
    end

    local k = 1
    local len = #name
    local haveSpecialChar = false
    local allAreNumbers = true
    while true do
        if k > len then
            break
        end

        local c = string.byte(name, k)
        if c < 48 or c > 57 then
            allAreNumbers = false
        end

        if c < 192 then
            if c < 48 or (c > 57 and c < 65) or (c > 90 and c < 97) or c > 122 then
                haveSpecialChar = true
                break
            end
            k = k + 1
        elseif c >= 224 and c < 240 then
            local c1 = string.byte(name, k + 1)
            local c2 = string.byte(name, k + 2)
            local unic = (c % 0xe0) * 2 ^ 12 + (c1 % 0x80) * 2 ^ 6 + (c2 % 0x80)
            if unic < 0x4e00 and unic > 0x9FA5 then
                haveSpecialChar = true
                break
            end
            k = k + 3
        else
            haveSpecialChar = true
            break
        end
    end

    if haveSpecialChar then
        AlertController.ShowTips("名字不允许有特殊字符")
        return false
    end

    if allAreNumbers then
        AlertController.ShowTips("名字不能全部为数字")
        return false
    end

    return true
end

return CreateRoleView

