ActionController = ActionController or {}
local AvatarMessage = require('MainGame/Message/AvatarMessage')
local PoolingStrategyTypeEnum = require("Engine/Systems/ResourceSystem/PoolingStrategyTypeEnum")
local BindType = SGEngine.Core.BindType
local CinemachineBrain = Cinemachine.CinemachineBrain
local k_SkillViewName = 'SkillView'

--子类重新写
function ActionController.Init()

end

function ActionController.RegisterCommand()
    -- body
end

function ActionController.ShowSkillCD(skillId, coolDown)
    --Logger.LogInfo("ActionController.ShowSkillCD(%s, %s)", skillId, coolDown)
    local skillView = UIManager.GetUI(k_SkillViewName)
    if skillView then
        skillView:ShowSkillCD(skillId, coolDown)
    end
end

function ActionController.SetSprintAttackBtnActive(active)
    local skillView = UIManager.GetUI("SkillView")
    if skillView then
        skillView:SetSprintAttackBtnActive(active)
    end
end

function ActionController.RefreshRole(active)
    local skillView = UIManager.GetUI("SkillView")
    if skillView then
        skillView:RefreshRole(active)
    end
end
return ActionController
