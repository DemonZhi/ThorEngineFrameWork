local SliderItem = class('SliderItem', BaseItem)

function SliderItem:InitUI()
    self:AddToggleOrSliderListener(self.sliderItem, function (value)
        if not self.finish then return end           
        if MakeupController.model:GetCategory() == 'pinch' then
            --hero.m_Core:SetPinchValue(self.type, self.id, value, "Face")
            MakeupController.SetFaceBlendShapeValue(self.id, value)
        elseif MakeupController.model:GetCategory() == 'makeup' then
            -- MakeupController.model:SetMakeupData(self.type, value)
            -- MakeupController.RefreshFace()
            MakeupController.SetFaceMakeupData(self.type, value)   
        end
    end)
end

function SliderItem:OnGUI(itemData)
    --todo ： self.finish是为了解决上面时间先注册，然后下面设置slider得值会提前回调引起的参数问题，先这个解决，后面流程有优化再改
    self.finish = false
    self.txtSlider.text = itemData.desc or ""
    self.type = itemData.type or 0
    self.id  = itemData.id or 1
    
    
    self.sliderItem.minValue = itemData.min or 0
    self.sliderItem.maxValue = itemData.max or 1
    self.sliderItem.value = MakeupController.GetFaceBlendShapeByIndex(self.id)--ProcedureCreateRole.m_ShowObj.m_Core:GetBlendShapeByIndex(self.id, 'Face')
    self.finish = true  
end

return SliderItem