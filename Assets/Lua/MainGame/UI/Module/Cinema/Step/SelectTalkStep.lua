local BaseStep = require("MainGame/UI/Module/Cinema/Step/BaseStep")
local SelectTalkStep = class("SelectTalkStep", BaseStep)

function SelectTalkStep:OnInit()
   self.m_BtnList = {}
end

function SelectTalkStep:OnShow(cinemaConfig)
	self:DestoryAllBtn()
	local selectTitleList = cinemaConfig.SelectTitleList
	for k, title in pairs(selectTitleList) do
		local go = UnityEngine.GameObject.Instantiate(self.itemClone.gameObject);
        local rect = go:GetComponent("RectTransform")
        go.transform:SetParent(self.itemClone.transform.parent)
        rect.localPosition = Vector3.New(0, 0, 0)
        rect.localScale = Vector3.one
        rect.gameObject:SetActive(true)
        local btn = go:GetComponent("Button")
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function ()
           self:Finish(k)
        end)
        local tx = btn.transform:Find("text"):GetComponent("Text")
        tx.text = title
        table.insert(self.m_BtnList, btn)
	end
	self.operationDialogueText.text = cinemaConfig.Dialogue
end


function SelectTalkStep:DestoryAllBtn()
	for k,v in pairs(self.m_BtnList) do
		GameObject.Destroy(v.gameObject)
	end
	self.m_BtnList = {}
end

function SelectTalkStep:OnHide()
   self:DestoryAllBtn()
end

function SelectTalkStep:OnDestroy()
   self:DestoryAllBtn()
end

return SelectTalkStep
