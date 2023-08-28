local ScenesSwitchView = class('ScenesSwitchView', BaseView)
local GmMessage = require("MainGame/Message/GmMessage")

function ScenesSwitchView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)
    self.m_GoList = {}
    for sceneID, sceneConfig in pairs(SceneConfig) do
        local go = UnityEngine.GameObject.Instantiate(self.itemClone);
        local rect = go:GetComponent("RectTransform")
        go.transform:SetParent(self.itemClone.transform.parent)
        rect.localPosition = Vector3.New(0, 0, 0)
        rect.localScale = Vector3.one
        rect.gameObject:SetActive(true)

        local btn = go:GetComponent("Button")
        self:AddButtonListener(btn, function ()
            GmMessage.SendGmCommand("replace", string.format("%d %f %f %f", sceneID, sceneConfig.BornPosition[1], sceneConfig.BornPosition[2], sceneConfig.BornPosition[3]))
        end)
        local tx = btn.transform:Find("Text"):GetComponent("Text")
        tx.text = sceneConfig.SceneName

        table.insert( self.m_GoList, go )
    end

    self:InitBfBtn()
    self:AddButtonListener(self.btnCloseBG, function ()
        ScenesSwitchController.CloseView()
    end)

    self:AddToggleOrSliderListener(self.toggleShowVoxel, function (isOn)
        if isOn then
            local sceneName = SGEngine.Core.SceneManager.Instance.currentSceneName
            SGEngine.Core.VoxelManager.Instance:LoadAndActiveVoxel(sceneName)
        end
        SGEngine.Core.VoxelManager.Instance:EnableDebug(isOn)
    end)
end

function ScenesSwitchView:InitBfBtn()
    local go = UnityEngine.GameObject.Instantiate(self.itemClone)
    local rect = go:GetComponent("RectTransform")
    go.transform:SetParent(self.itemClone.transform.parent)
    rect.localPosition = Vector3.New(0, 0, 0)
    rect.localScale = Vector3.one
    rect.gameObject:SetActive(true)

    local btn = go:GetComponent("Button")
    self:AddButtonListener(btn, function ()
        BfClientManager.SendPlayerToBf()
    end)
    local tx = btn.transform:Find("Text"):GetComponent("Text")
    tx.text = "ToBf"
    table.insert( self.m_GoList, go )

    local go = UnityEngine.GameObject.Instantiate(self.itemClone)
    local rect = go:GetComponent("RectTransform")
    go.transform:SetParent(self.itemClone.transform.parent)
    rect.localPosition = Vector3.New(0, 0, 0)
    rect.localScale = Vector3.one
    rect.gameObject:SetActive(true)

    local btn = go:GetComponent("Button")
    self:AddButtonListener(btn, function ()
        BfClientManager.SendPlayerBackToGame()
    end)
    local tx = btn.transform:Find("Text"):GetComponent("Text")
    tx.text = "ToGame"

    table.insert( self.m_GoList, go )
end

function ScenesSwitchView:OnDestroy()
    for k,v in pairs(self.m_GoList) do
        UnityEngine.GameObject.Destroy(v.gameObject);
    end
end

function ScenesSwitchView:AddEvent()
end

return ScenesSwitchView
