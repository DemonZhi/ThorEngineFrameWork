local BaseStep = require("MainGame/UI/Module/Cinema/Step/BaseStep")
local NormalTalkStep = class("NormalTalkStep", BaseStep)

function NormalTalkStep:OnInit()
   
end

function NormalTalkStep:OnShow(cinemaConfig)
	self.normalDialogueText.text = cinemaConfig.Dialogue or ""
	self.normalName.text = "cwz"
	self.normalSkipBtn.onClick:RemoveAllListeners()
	self.normalSkipBtn.onClick:AddListener(function ()
    	self:Finish()     
    end)
end

function NormalTalkStep:OnHide()
   
end

function NormalTalkStep:OnDestroy()

end

return NormalTalkStep
