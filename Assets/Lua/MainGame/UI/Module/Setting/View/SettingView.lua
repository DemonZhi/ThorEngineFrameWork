local SettingView = class('SettingView', BaseView)

function SettingView:InitUI()
    self.m_Transform.offsetMin = Vector2.New(0, 0)
    self.m_Transform.offsetMax = Vector2.New(0, 0)
    self.m_UISetting = self.m_UISetting.gameObject:GetComponent('UISetting')
    self.btnCloseBG.onClick:AddListener(
        function()
            SettingController.CloseView()
        end
    )

    self.sliderTODTime.onValueChanged:AddListener(
        function(x)
            x = x - x % 0.01
            self.txtTODTime.text = '时间:' .. x
            self.m_UISetting:SetTODTime(x)
        end
    )

    self.sliderWetness.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetWetness(x)
        end
    )

    self.sliderCloudShadowRange.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetCloudShadowRange(x)
        end
    )

    self.sliderLightIntensity.onValueChanged:AddListener(
        function(x)
            self.txtPixelNum.text = '像素光:' .. x
            self.m_UISetting:SetLightIntensity(x)
        end
    )

    self.toggleShadow.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetShadowOpen(x)
        end
    )

    self.toggleSoftShadow.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetSoftShadow(x)
        end
    )
    self.toggleBloom.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetBloom(x)
        end
    )
    self.toggleGrass.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetGrass(x)
        end
    )

    self.toggleCubemapToggle.onValueChanged:AddListener(
        function(x)
            if x then
                self.m_UISetting:SetWaterReflectionType(1)
            end
        end
    )

    self.toggleRealTimeToggle.onValueChanged:AddListener(
        function(x)
            if x then
                self.m_UISetting:SetWaterReflectionType(2)
            end
        end
    )

    self.toggleSSRToggle.onValueChanged:AddListener(
        function(x)
            if x then
                self.m_UISetting:SetWaterReflectionType(3)
            end
        end
    )

    self.toggleThunder.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetThunderActive(x)
        end
    )

    self.sliderThunder.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetThunder(x)
        end
    )

    self.sliderThunderFlicker.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetThunderFlicker(x)
        end
    )

    self.toggleRain.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetRainActive(x)
        end
    )

    self.sliderRain.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetRain(x)
        end
    )

    self.sliderRainFog.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetRainFog(x)
        end
    )

    self.sliderRainRipple.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetRipple(x)
        end
    )

    self.toggleSSAO.onValueChanged:AddListener(
        function(x)
            self.m_UISetting:SetSSAO(x)
        end
    )
    self.toggleSSAO.isOn = self.m_UISetting:GetSSAOActive()
end

function SettingView:OnDestroy()
end

function SettingView:AddEvent()
end

return SettingView
