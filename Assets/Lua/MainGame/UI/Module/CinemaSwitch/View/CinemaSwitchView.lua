local CinemaSwitchView = class('CinemaSwitchView', BaseView)
local textName = "Text"
local buttonName = "Button"
local rectTransformName = "RectTransform"
local StateDefine = SGEngine.Core.StateDefine

CinemaSwitchView.CinemaListConfig = 
{
    "神秘的城堡"
}


function CinemaSwitchView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)

    self.m_GoList = {}

    for key, cinemaName in pairs(CinemaSwitchView.CinemaListConfig) do
        local go = UnityEngine.GameObject.Instantiate(self.itemClone);
        go.transform:SetParent(self.itemClone.transform.parent)

        local rect = go:GetComponent(rectTransformName)
        rect.localPosition = Vector3.New(0, 0, 0)
        rect.localScale = Vector3.one
        rect.gameObject:SetActive(true)

        local btn = go:GetComponent(buttonName)
        self:AddButtonListener(btn, function ()
            local hero = ObjectManager.GetHero()
            local isIdle = hero:IsState(StateDefine.k_StateIdle)
            if not isIdle then
               Logger.Print("[CinemaSwitchView](Init)need hero enter idle state!")
               return
            end
            -- CinemaManager.SendRequestPlayCinema(1)
            -- CinemaSwitchController.CloseView()


            CinemaController.CinemaStart(2, 1)
            CinemaSwitchController.CloseView()
        end)

        local tx = btn.transform:Find(textName):GetComponent(textName)
        tx.text = cinemaName

        table.insert(self.m_GoList, go)
    end

    self:AddButtonListener(self.btnCloseBG, function ()
        CinemaSwitchController.CloseView()
    end)
end

function CinemaSwitchView:OnDestroy()
    for k,v in pairs(self.m_GoList) do
        UnityEngine.GameObject.Destroy(v.gameObject)
    end
end

function CinemaSwitchView:AddEvent()
end

return CinemaSwitchView
