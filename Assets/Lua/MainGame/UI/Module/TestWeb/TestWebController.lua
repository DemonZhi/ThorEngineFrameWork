TestWebController = TestWebController or {}
local k_TestWebView = 'TestWebView'

local m_URL
local function LoadURL(url)
    local view = UIManager.GetUI(k_TestWebView)
    view:LoadURL(url)
end

--子类重新写
function TestWebController.Init()
end

function TestWebController.RegisterCommand()
	-- body
end

function TestWebController.OpenViewAndLoadURL(url)
    if UIManager.IsActive(k_TestWebView) then
        LoadURL(url)
    else
        UIManager.OpenUI(k_TestWebView, nil, nil, function() 
            LoadURL(url)  
        end)
    end
end

return TestWebController
