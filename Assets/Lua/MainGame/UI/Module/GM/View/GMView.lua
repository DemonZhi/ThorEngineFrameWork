local GMView = class('GMView', BaseView)
local GMItem = require('MainGame/UI/Module/GM/View/Item/GMItem')
local StringUtil = require('Engine/Common/Utilities/StringUtil')
local k_ModelId = 1

local k_LoginIP = SGEngine.Core.Main.GameConfig.remoteIP
local k_DefaultOuterURL = "www.yellowurl.cn"
local k_DefaultInnerURL = "http://gitlab.polar.local:9090/users/sign_in"
local k_HttpURLPrefix = "https://"

local k_SupportUniWebViewPlatform = 
{
    [RuntimePlatform.Android] = true,
    [RuntimePlatform.IPhonePlayer] = true,
    [RuntimePlatform.OSXEditor] = true,
    --[RuntimePlatform.WindowsEditor] = true,-- test
}
local function IsStartsWithHttp(url)
    return string.sub(url, 1, 4) == "http"
end

local function IsInnerNet()
    if string.sub(k_LoginIP, 1, 3) == "10." then
        return true
    elseif string.sub(k_LoginIP, 1, 8) == "192.168." then
        return true
    elseif string.sub(k_LoginIP, 1, 4) == "172." then
        return true
    end
    return false
end

--子类重写
function GMView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)
    self.m_list = ScrollList.New(self.scrollList, GMItem)
    self.m_GMData = {
        {
            name = '相机FOV',
            func = function(str)
                local fov = tonumber(str)
                ObjectManager.GetHero():SetCameraFov(fov)
            end,
            OpenCallBack = function(item)
                item.m_inputField.text = ObjectManager.GetHero():GetCameraFov()
            end
        },
        {
            name = '相机偏移',
            func = function(str)
                local strList = StringUtil.Split(str, ',')
                local x = tonumber(strList[1])
                local y = tonumber(strList[2])
                local z = tonumber(strList[3])
                local vector = Vector3.New()
                vector.x = x
                vector.y = y
                vector.z = z
                ObjectManager.GetHero():SetAnchorOffset(vector)
            end,
            OpenCallBack = function(item)
                local vector = ObjectManager.GetHero():GetAnchorOffset()
                item.m_inputField.text = string.format('%.1f,%.1f,%.1f', vector.x, vector.y, vector.z)
            end
        },
        {
            name = '相机旋转',
            func = function(str)
                local strList = StringUtil.Split(str, ',')
                local x = tonumber(strList[1])
                local y = tonumber(strList[2])
                local z = tonumber(strList[3])
                local vector = Vector3.New()
                vector.x = x
                vector.y = y
                vector.z = z
                ObjectManager.GetHero():SetCameraRotation(vector)
            end,
            OpenCallBack = function(item)
                local vector = ObjectManager.GetHero():GetCameraRotation()
                item.m_inputField.text = string.format('%.1f,%.1f,%.1f', vector.x, vector.y, vector.z)
            end
        },
        {
            name = '相机半径',
            func = function(str)
                local radius = tonumber(str)
                ObjectManager.GetHero():SetCameraOrbitRadius(radius)
            end,
            OpenCallBack = function(item)
                item.m_inputField.text = ObjectManager.GetHero():GetCameraOrbitRadius()
            end
        },
        {
            name = '相机距离',
            func = function(str)
                local distance = tonumber(str)
                ObjectManager.GetHero():SetCameraDistance(distance)
            end,
            OpenCallBack = function(item)
                item.m_inputField.text = ObjectManager.GetHero():GetCameraDistance()
            end
        },
        {
            name = '打开黄页',
            func = function(str)
                    local currentPlatform = Application.platform
                    if not k_SupportUniWebViewPlatform[currentPlatform] then
                        AlertController.ShowTips(string.format("Not Support Platform:[%s]", currentPlatform))
                        return
                    end
                    local url = str
                    if not IsStartsWithHttp(str) then
                        url = k_HttpURLPrefix .. str
                    end
                    TestWebController.OpenViewAndLoadURL(url)
                end,
            OpenCallBack = function(item)
                local defaultURL = k_DefaultOuterURL
                if IsInnerNet() then 
                    defaultURL = k_DefaultInnerURL
                end
                item.m_inputField.text =defaultURL 
            end
        }
    }
end

function GMView:OnOpen()
    self.m_list:SetLuaData(self.m_GMData)
end

return GMView
