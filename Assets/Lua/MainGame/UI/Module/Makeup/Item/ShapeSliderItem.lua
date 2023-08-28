---塑型item
local ShapeSliderItem = class("ShapeSliderItem", BaseUI)
--界面初始化
function ShapeSliderItem:InitUI(sliderCallback, index) 
	self:InitUIBinder() 
	self:AddToggleOrSliderListener(self.Slider, function (value)
		self.txt_num.text = math.ceil(value * 100)
		local namelst = self.m_ArrayLatitudeType[self.data.ShapingName]
		MakeupController.model:CacheShapeValue(self.m_FaceID, value)
		for index, data in ipairs(namelst) do
			MakeupController.PinchFace(data.data, value)
        end
		MakeupController.BakeFace(self.data.FacialID)
		if sliderCallback then 
			sliderCallback(index, value)
		end
	end)
end

function ShapeSliderItem:UpdateUI(shapingData, arrayLatitudeType)
	local data = shapingData.data
	self.m_ArrayLatitudeType = arrayLatitudeType
	self.data = data
	self.m_FaceID = data.FaceID
	
	local cacheValue = MakeupController.model:GetCacheShapeValue(data.FaceID)
	self.Slider.value = cacheValue
	self.txt_num.text = math.ceil(cacheValue * 100)
	self.txt_biaoti.text = data.ShapingName
end

return ShapeSliderItem