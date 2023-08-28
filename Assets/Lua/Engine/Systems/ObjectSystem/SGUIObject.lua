--外观实体
local SGUIObject = class("SGUIObject", SGObject)
SGUIObject.m_ObjectType = ObjectTypeEnum.OutLook
function SGUIObject:Ctor()
    SGUIObject.__super.Ctor(self)
end

function SGUIObject:SetModel(go, animationType)
    SGUIObject.__super.SetModel(self, go, animationType)
end

--模型加载完成
function SGUIObject:OnModelLoadComplete()
    SGUIObject.__super.OnModelLoadComplete(self)
end

--注册事件的地方
--触发时机是模型加载完成
function SGUIObject:RegisterModelEvents()
    SGUIObject.__super.RegisterModelEvents(self)
end

--换装 - 异步
--changeSkinPartName:部位名称
--@skinModelName    :换装的资源addressable地址
--@callback         :换装成功回调
function SGUIObject:ChangeSkinAsync(changeSkinPartName, skinModelName, callBack, boneConfigAddress, newModelSkinPartNameMask)
    return self.m_Core:ChangeSkinAsync(changeSkinPartName, skinModelName, callBack, boneConfigAddress, newModelSkinPartNameMask)
end

--换装 - 同步
--changeSkinPartName:部位名称
--@skinModelName    :换装的资源addressable地址
--@callback         :换装成功回调
function SGUIObject:ChangeSkin(changeSkinPartName, skinModelName, boneConfigAddress, newModelSkinPartNameMask)
    return self.m_Core:ChangeSkin(changeSkinPartName, skinModelName, boneConfigAddress, newModelSkinPartNameMask)
end

--装备挂件
--@equipPartName:装备部位
--@equipName    :挂件addressable地址
--@callBack     :装备成功回调
function SGUIObject:EquipGameObject(equipPartName,equipName,callBack)
    self.m_Core:EquipGameObject(equipPartName,equipName,callBack)
end

--卸下挂件
--@equipPartName:卸下部位
function SGUIObject:UnEquipGameObject(equipPartName)
    self.m_Core:UnEquipGameObject(equipPartName)
end

--获取部位上装备挂件
--@equipPartName:获取部位
function SGUIObject:GetEquipGameobject(equipPartName)
    return self.m_Core:GetEquipGameobject(equipPartName)
end

--播放部位装备的动画
--@equipPartName:装备部位
--@animName     :动画名称
--@crossFade    :过渡时间
function SGUIObject:PlayEquipAnimation(equipPartName,animName,crossFade)
    self.m_Core:PlayEquipAnimation(equipPartName,animName,crossFade)
end
return SGUIObject