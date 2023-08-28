
---妆容item
local MakeUpItem = class("MakeUpItem", SuperBaseItem)

--界面初始化
function MakeUpItem:InitUI()
    
end

function MakeUpItem:SetInfoItem(date)
    self.img_select.gameObject:SetActive(false)
    local keyNormal = "makeNormal_" .. date.PrimaryID
    self:SetImageSprite(self.img_icon, "MODAtlas", keyNormal, function()
        if self.img_icon.enabled == false then
            self.img_icon.enabled = true
        end
        self.img_icon:SetNativeSize()
    end)
    local keySelect = "makeSelect_" .. date.PrimaryID
    self:SetImageSprite(self.img_select, "MODAtlas", keySelect)
end

function MakeUpItem:OnSelect(bValue)
    self.img_select.gameObject:SetActive(bValue)
end

return MakeUpItem