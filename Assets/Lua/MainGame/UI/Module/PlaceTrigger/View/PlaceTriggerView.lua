
---@class PlaceTriggerView:BaseView
local PlaceTriggerView = class("PlaceTriggerView", BaseView)
local RectTransformUtility = UnityEngine.RectTransformUtility
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local k_TriggerAreaAssetKey = "pre_trigger_test01_area"

local function CleanTimer(self)
end

--界面初始化
function PlaceTriggerView:InitUI()
	self.m_TriggerAreaGo = nil
    self.m_SLGTriggerArea = nil

	self:AddButtonListener(self.btnCancel, function ()
        self:Close()
    end)

    self:AddButtonListener(self.btnPlaceTrigger, function ()
        if not self.m_SLGTriggerArea:IsCanPlace() then 
            AlertController.ShowTips("当前位置不可放置")
            return
        end

        local position = self.m_TriggerAreaGo.transform.position
        local angle = self.m_SLGTriggerArea.triggerCollider.transform.eulerAngles.y
        PlaceTriggerController.PlaceTrgger(position.x, position.y, position.z, angle, 60)
    end)
end

--打开界面回调
function PlaceTriggerView:OnOpen()
	if self.m_TimeId == nil then 
        CleanTimer(self)
    end

    if self.m_TriggerAreaGo == nil then 
    	ResourceManager.InstantiateAsync(
	        k_TriggerAreaAssetKey,
	        function(go)
	        	self.m_TriggerAreaGo = go
                local slgTriggerArea = System.Type.GetType("SGEngine.Core.SLGTriggerArea")
                self.m_SLGTriggerArea = Core_ForLuaUtility.GetOrAddComponent(self.m_TriggerAreaGo, slgTriggerArea)
	        end,
	        PoolingStrategyTypeEnum.Default
	    )
    else
    	self.m_TriggerAreaGo:SetActive(true)
        self.m_SLGTriggerArea:UpdateGoPosition()
    end
end

function PlaceTriggerView:UpdatePerFrame()
end

--关闭界面回调
function PlaceTriggerView:OnClose()
	CleanTimer(self)
	self.m_TriggerAreaGo:SetActive(false)
end

--销毁界面回调
function PlaceTriggerView:OnDestroy()
	CleanTimer(self)
	ResourceManager.ReleaseInstance(self.m_TriggerAreaGo)
	self.m_TriggerAreaGo = nil
    self.m_SLGTriggerArea = nil
end

return PlaceTriggerView