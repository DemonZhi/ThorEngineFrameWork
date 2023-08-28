local SelectRoleItem = require('MainGame/UI/Module/CreateRole/View/SelectRoleItem')
local ProcedureCreateRole = require("MainGame/Game/Procedure/ProcedureCreateRole")
local CreateRoleMessage = require("MainGame/Message/CreateRoleMessage")
local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local SelectRoleView = class('SelectRoleView', BaseView)
 

--子类重写
function SelectRoleView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self.m_List = ScrollList.New(self.roleList, SelectRoleItem)
    self:AddButtonListener(self.btnEnterGame, function ()
        local randKey = CreateRoleController.model:GetRandKey()
        CreateRoleMessage.SendJoin(self.m_SelectedItemData.m_RoleInfo.playerID, randKey)
    end)

    self:AddButtonListener(self.btnNew, function ()
       if CreateRoleController.model:CanCreateRole() then
            CreateRoleController.CloseSelectRoleView()
            CreateRoleController.OpenCreateRoleView()
        else
            AlertController.ShowTips("角色达到最大数量")
        end
    end)

    self:AddButtonListener(self.btnDelete, function ()
        local alertData =
         {
            content = '删除后无法恢复，是否继续？',
            onConfirmCallback = function ()
                local accountData = AccountManager.GetAccountData()
                CreateRoleMessage.SendDeletePlayer(accountData.accountId, self.m_SelectedItemData.m_RoleInfo.playerID)
            end,
        }
        AlertController.ShowAlert(alertData)
    end)

    self:AddButtonListener(self.btnBack, function ()
        local alertData = {
            content = '是否退出游戏，返回登录界面？',
            onConfirmCallback = function ()
                LoginController.Logout()
            end,
        }

        AlertController.ShowAlert(alertData)
    end)
end

function SelectRoleView:OnOpen()
    self:RefreshRoleList()
end

function SelectRoleView:OnItemSelected(itemData)
    if self.m_SelectedItemData == itemData then
        return
    end
    self.m_SelectedItemData = itemData
    self.m_List:DoRefresh()
    ProcedureCreateRole.ChangeRole(itemData.m_RoleInfo)
end

function SelectRoleView:RefreshRoleList()
    local createRoleModel = CreateRoleController.model
    local playerListResult =  createRoleModel:GetPlayerListResult()
    local lastJoinOrFirstPlayerInfo = createRoleModel:GetLastJoinOrFirstPlayerInfo()
    local itemDataList = {}
    local jobConfig = JobConfig
    for i, v in ipairs(playerListResult.players) do
        local itemData = 
        {
            m_OwnerView = self, 
            m_Index = i,
            m_RoleInfo = v,
        }
        table.insert(itemDataList, itemData)
        
        if lastJoinOrFirstPlayerInfo == v then
            self.m_SelectedItemData = itemData
            ProcedureCreateRole.ChangeRole(v)
        end
    end
    
    self.m_List:SetLuaData(itemDataList)
    self.m_List:DoRefresh()
end

function SelectRoleView:GetSelectedItemIndex()
    return self.m_SelectedItemData.m_Index
end

return SelectRoleView

