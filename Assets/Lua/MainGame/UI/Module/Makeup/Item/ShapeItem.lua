---塑型item
local ShapeItem = class("ShapeItem", SuperBaseItem)

--界面初始化
function ShapeItem:InitUI()
end

function ShapeItem:SetInfoItem(date, tabIndex)
    self.img_select.gameObject:SetActive(false)
    local keyNormal = "shapeNormal_" .. date.FacialID
    self:SetImageSprite(self.img_icon, "MODAtlas", keyNormal, function()
        if self.img_icon.enabled == false then
            self.img_icon.enabled = true
        end
        self.img_icon:SetNativeSize()
    end)
    local keySelect = "shapeSelect_" .. date.FacialID
    self:SetImageSprite(self.img_select, "MODAtlas", keySelect)
end

function ShapeItem:OnSelect(bValue)
    self.img_select.gameObject:SetActive(bValue)
end

return ShapeItem