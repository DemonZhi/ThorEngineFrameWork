local DebugRenderFeature = SGEngine.Rendering.DebugRenderFeature
local Core_SGResourceManager = SGEngine.ResourceManagement.SGResourceManager
local ObjectPooManager = SGEngine.Core.ObjectPoolManager
local OpView = class('OpView', BaseView)
local Core_ObjectManager = SGEngine.Core.ObjectManager
local GameConfig = SGEngine.Core.Main.GameConfig

--子类重写
function OpView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self:AddButtonListener(self.btnSetting, function ()
        DebugRenderFeature.OpenOrCloseDebugUI()
    end)

    --self:AddButtonListener(self.btnChange, function ()
    --    local hero = ObjectManager.GetHero()
    --    if hero then
    --        local index = hero:GetActiveMotorIndex()
    --        hero:ActivateMotorWithIndex(1 - index)
    --    end
    --end)
    if not UNITY_EDITOR then
       self.btnChange.gameObject:SetActive(false)
    end
    
    self:AddButtonListener(self.btnChange, function ()
         ReloadManager.ReloadAll()
    end)

    self:AddButtonListener(self.btnSRP, function ()
        SRPBatcherProfilerController.OpenView()
    end)

    self:AddButtonListener(self.btnScenes, function ()
        ScenesSwitchController.OpenView()
    end)

    self.m_ObjPanelActive = true

    self:AddButtonListener(self.btnObj, function ()
        self:ChangeObjPanelActive()
    end)

    self:AddButtonListener(self.btnCinema, function ()
        CinemaSwitchController.OpenView()
    end)

    self:AddButtonListener(self.btnTestScreen, function ()
        UIManager.OpenUI("TestUIMoldeClipView")
    end)

    self.btnExit.gameObject:SetActive(true)
    self:AddButtonListener(self.btnExit, function ()
        local isInBF = BfClientManager.GetState() == BfClientManager.StageType.k_InBF
        local alertData
        if isInBF then
            alertData = {
                content = '正在跨服，返回游戏服？',
                onConfirmCallback = function ()
                    BfClientManager.SendPlayerBackToGame()
                end,
            }
        else
            alertData = {
                content = '是否退出游戏，返回登录界面？',
                onConfirmCallback = function ()
                    LoginController.Logout()
                end,
            }
        end

        AlertController.ShowAlert(alertData)
    end)

    self.lastLuaMem = 0
    self.timeid = TimerManager:AddTimer(self, function()
        local luaMem = GameLoop.GetLuaMem()
        luaMem = luaMem / 1024
        self.luaMem.text = string.format("%.1f MB", luaMem)
        if self.classPoolText ~= nil then
            self.classPoolText.text = Core_ObjectManager.Instance:GetAllObjectCount() .. "/" .. Core_ObjectManager.Instance.objectCacheCount
        end
        if self.goPoolText ~= nil then
            self.goPoolText.text = Core_SGResourceManager.GetAllPoolResourceObjectCount()
        end

        if self.playerText ~= nil then
            self.playerText.text = Core_ObjectManager.Instance:GetObjectCountByType(1) .. "/" .. Core_ObjectManager.Instance:GetCacheObjectCount(1)
        end

        if self.monsterText ~= nil then
            self.monsterText.text = Core_ObjectManager.Instance:GetObjectCountByType(2) .. "/" .. Core_ObjectManager.Instance:GetCacheObjectCount(2)
        end

        if self.uiobjectText ~= nil then
            self.uiobjectText.text = Core_ObjectManager.Instance:GetObjectCountByType(3) .. "/" .. Core_ObjectManager.Instance:GetCacheObjectCount(3)
        end

        if self.mountText ~= nil then
            self.mountText.text = Core_ObjectManager.Instance:GetObjectCountByType(4) .. "/" .. Core_ObjectManager.Instance:GetCacheObjectCount(4)
        end

        if self.missileText ~= nil then
            self.missileText.text = Core_ObjectManager.Instance:GetObjectCountByType(5) .. "/" .. Core_ObjectManager.Instance:GetCacheObjectCount(5)
        end

        if self.heroText ~= nil then
            self.heroText.text = Core_ObjectManager.Instance:GetObjectCountByType(6) .. "/" .. Core_ObjectManager.Instance:GetCacheObjectCount(6)
        end

        --资源
        if self.prefabText ~= nil then
            self.prefabText.text = Core_SGResourceManager.GetPoolResourceObjectCount(0)
        end

        if self.spriteText ~= nil then
            self.spriteText.text = Core_SGResourceManager.GetPoolResourceObjectCount(1)
        end

    end, 1, 0)
end

function OpView:ChangeObjPanelActive()
    if self.m_ProflerPanelActive then
        self.objPanel.gameObject:SetActive(false)
        self.profilerPanel.gameObject:SetActive(false)
        self.m_ProflerPanelActive = false
    else
        self.objPanel.gameObject:SetActive(true)
        self.profilerPanel.gameObject:SetActive(true)
        self.m_ProflerPanelActive = true
    end
end

function OpView:UpdateObjPanelText(clientPx, clientPy, clientPz, serverPx, serverPy, serverPz, clientHeight, serverHeight)
    local clientStr = string.format('pos:%.3f,%.3f,%.3f,Height:%.3f', clientPx, clientPy, clientPz, clientHeight)
    local serverStr = string.format('pos:%.3f,%.3f,%.3f,Height:%.3f', serverPx, serverPy, serverPz, serverHeight)
    self.clientText.text = clientStr
    self.serverText.text = serverStr
end

--子类重写
function OpView:OnDestroy()
    if self.timeid ~= nil then
        TimerManager:RemoveTimer(self.timeid)
    end
end

function OpView:SetRtt(rtt)
    self.rtt.text = rtt
end

return OpView
