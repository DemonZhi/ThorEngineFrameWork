
---妆容item
local GroupItem = class("GroupItem", SuperBaseItem)
local upV = Vector3.zero
local downV = Vector3.New(0,0,180)

--界面初始化
function GroupItem:InitUI()
end

function GroupItem:SetInfoItem(date)
	self.img_select.gameObject:SetActive(false)
    self.txt_tab.text = date.config[7]
    self.img_arrow.transform.rotation = Quaternion.Euler(upV)
end

function GroupItem:OnSelect(bValue)
    self.img_select.gameObject:SetActive(bValue)
end

function GroupItem:SetArrowRotate(type)
    if type == "up" then
    	self.img_arrow.transform.rotation = Quaternion.Euler(upV)
    else
        self.img_arrow.transform.rotation = Quaternion.Euler(downV)
    end
    
end

return GroupItem