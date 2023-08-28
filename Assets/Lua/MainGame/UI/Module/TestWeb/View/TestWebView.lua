local TestWebView = class('TestWebView', BaseView)
local type_UniWebView = typeof(UniWebView)
local ServerTypeEnum = require('MainGame/Common/Const/ServerTypeEnum')

local function GetUniWebViewObjSafe(go)
    local webViewObj = go:GetComponent(type_UniWebView)
    if webViewObj == nil then
        webViewObj = go:AddComponent(type_UniWebView)
    end
    return webViewObj
end

--子类重写
function TestWebView:InitUI()
    self:AddButtonListener(self.btnClose, function ()
        self:Close()
    end)
    
    self.m_OnDisconnectCallback = function()  
        Logger.LogInfoFormat("[TestWebView](m_OnDisconnectCallback)OnDisconnect")
        self:Close()
    end

    --TODO
    self.m_Transform.localPosition = Vector3.New(0, -160, 0)
    end

function TestWebView:OnOpen()
    local uniWebView = GetUniWebViewObjSafe(self.m_GameObject)
    uniWebView:SetBackButtonEnabled(false)
    self.m_UniWebView = uniWebView
    
    ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.GameServer, self.m_OnDisconnectCallback)
    --ClientNetManager.RegisterDisconnectCallBack(ServerTypeEnum.BfServer, OnDisconnectCallback)
end

function TestWebView:OnClose()
    ClientNetManager.UnRegisterDisconnectCallBack(ServerTypeEnum.GameServer, self.m_OnDisconnectCallback)
    --local uniWebView = self.m_UniWebView
    --if uniWebView ~= nil then
    --    GameObject.Destroy(uniWebView)
    --    self.m_UniWebView = nil
    --end
end

function TestWebView:LoadURL(url)
    local uniWebView = self.m_UniWebView
    local OnPageProgressChanged = function(webViewObj, progress)
        self.sliProgress.value = progress
        if progress >= 1 then
            self.rectLoading.gameObject:SetActive(false)
            uniWebView:Show()
            self.m_UniWebView:ScrollTo(0, 0, false)
        end
    end
    
    local OnPageStarted = function(webViewObj, url)
        self.m_UniWebView.ReferenceRectTransform = self.rectWebContent
    end
    
    
    self.rectLoading.gameObject:SetActive(true)
    self.sliProgress.value = 0 
    
    uniWebView.OnPageProgressChanged = uniWebView.OnPageProgressChanged + OnPageProgressChanged
    uniWebView.OnPageStarted = uniWebView.OnPageStarted + OnPageStarted

    uniWebView:Load(url)
end

return TestWebView
