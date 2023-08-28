
---妆容item
local DoubleItem = class("DoubleItem", SuperBaseItem)

--界面初始化
function DoubleItem:InitUI()
    self.img_selectlst = {}
    self.m_Select = nil
    self.m_rootView = nil
    self.m_DoubleData = nil
end

function DoubleItem:SetInfoItem(date, rootView)
    self.m_DoubleData = date
    self.m_rootView = rootView
    for i = 1, 2 do
        local img_icon = self["img_icon"..i]
        local btn_icon = self["btn_icon"..i]
        local img_select = self["img_select"..i]
        self.img_selectlst[i] = img_select
        img_select.gameObject:SetActive(false)
        local mixData = date[i]
        if mixData then
            img_icon.gameObject:SetActive(true)
            local nilState =  mixData.dressConfig.MakeID % 10 
            local Atlas,Photo
            if nilState ~= 0 then
                Atlas = "MODAtlas"
                Photo = tostring(mixData.dressConfig.MakeID)
            else
                Atlas = "MODAtlas"
                Photo = "img_nl_0021"
            end
            self:SetImageSprite(img_icon, Atlas,Photo,function()
                if img_icon.enabled == false then
                    img_icon.enabled = true
                end
            end)
            btn_icon.onClick:RemoveAllListeners()
            self:AddButtonListener(btn_icon, function ()
                self:OnDressBtn(mixData, i)
            end)
        else
            img_icon.gameObject:SetActive(false)  
        end
    end
end

function DoubleItem:OnIndexSelect(keyIndex, bIsHistory)
    self:RecordSelect(keyIndex,self.m_DoubleData[keyIndex], bIsHistory)
    for index, img_select in ipairs(self.img_selectlst) do
        img_select.gameObject:SetActive(keyIndex == index)  
    end
end

function DoubleItem:OnDressBtn(mixData,index)
    self:RecordSelect(index,mixData)
    self.m_Select = self.img_selectlst[index]
    self.m_Select.gameObject:SetActive(true) 
end

---记录选中的索引
function DoubleItem:RecordSelect(index,mixData, bIsHistory)
    self.m_rootView:ClickSubItem(self.itemIndex,index,mixData, bIsHistory)
end

function DoubleItem:CustomSelect(index,state)
    self.m_Select = self.img_selectlst[index]
    self.m_Select.gameObject:SetActive(state) 
end

function DoubleItem:OnDestroy()
    self.img_selectlst = nil
    self.m_Select = nil
    self.m_rootView = nil
    self.m_DoubleData = nil
end

function DoubleItem:OnClose()
end

return DoubleItem