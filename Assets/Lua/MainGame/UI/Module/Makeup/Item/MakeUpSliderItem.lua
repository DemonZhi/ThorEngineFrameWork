---塑型item
local MakeUpSliderItem = class("MakeUpSliderItem", BaseUI)
--界面初始化
function MakeUpSliderItem:InitUI(sliderCallback, index) 
	self:InitUIBinder()
	self:AddToggleOrSliderListener(self.Slider, function (value)
		self.txt_num.text = math.ceil(value * 100)
		if sliderCallback then 
			sliderCallback(index, value)
		end
	end)
end

function MakeUpSliderItem:UpdateUI(data, defaultValue)
	self.data = data
	self.Slider.value = defaultValue
	self.txt_num.text = math.ceil(defaultValue * 100)
	self.txt_biaoti.text = data.iName
end

return MakeUpSliderItem