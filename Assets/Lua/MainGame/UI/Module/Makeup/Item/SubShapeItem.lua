---塑型item
local SubShapeItem = class("SubShapeItem", SuperBaseItem)
--界面初始化
function SubShapeItem:InitUI()   
end

function SubShapeItem:SetInfoItem(date)
	self.img_select.gameObject:SetActive(false)
    self.txt_tab.text = date.AreaName
end

function SubShapeItem:OnSelect(bValue)
	self.img_select.gameObject:SetActive(bValue)
end

return SubShapeItem