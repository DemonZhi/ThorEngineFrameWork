local MakeupModel = class('MakeupModel')
local FaceMakeupData = SGEngine.Core.FaceMakeupData
local GenderTypeEnum = require("MainGame/Common/Const/GenderTypeEnum")
local MakeupConfig = require("MainGame/UI/Module/Makeup/Model/MakeupConfig")
local FaceConfig = require("MainGame/UI/Module/Makeup/Model/Face")
local MakeupConfigNew = require("MainGame/UI/Module/Makeup/Model/Makeup")
local MakeUpDefine = require("MainGame/UI/Module/Makeup/Model/Define/MakeUpDefine")

local MALE_ENTER_MAKEUP_HEIGHT = 1.75
local FEMALE_ENTER_MAKEUP_HEIGHT = 1.65
local LEAVE_MAKEUP_HEIGHT = 1 

--todo 这个目前非常乱。需要整理一波
local GateGoryEnum = {
    pinch = 1,
    makeup = 2,
}

-- 妆容调节维度枚举
---@class MakeUpDefine.DressLatitudeEnum
local DressLatitudeEnum = 
{
    gudingsezhi = 1, --固定色值
    ziyousezhi = 2, --自由换色
    guangze = 3, --光泽
    zhouwenqiangdu = 4, --皱纹强度
    toumingdu = 5, --透明度
    shumi = 6, --疏密
    chunwenshenqian = 7, --唇纹深浅
    liangpianqiangdu = 8, --亮片强度
    kelidaxiao = 9, --颗粒大小
    yanbu = 10, --左眼-右眼-双眼
    tongkongdaxiao = 11, --瞳孔大小
    tongmodaxiao = 12, --瞳膜大小
    fanguangqiangdu = 13, --反光强度
    daxiao = 14, --大小
    xuanzhuan = 15, --旋转
    shangxiapianyi = 16, --上下偏移
    zuoyoupianyi = 17, --左右偏移
    zhufengudingsezhi = 18,--珠粉--固定色值
    zhufenziyousezhi = 19, --珠粉--自由换色
    dyeColorIntensity = 20, -- 染色强度 原色-染色过渡控制
    hairTailRange = 21, -- 发尾范围
    hairAnisoGloss = 22, -- 头发光泽
    dyeColorEnable = 23, -- 染色开关
}

---妆容 珠粉枚举
local DressZhuFenEnum = 
{
    [1] = {DressLatitudeEnum.liangpianqiangdu,"亮片强度"}, --亮片强度
    [2] = {DressLatitudeEnum.kelidaxiao, "颗粒大小"}, --颗粒大小
}

---妆容 美瞳枚举
local DressMeiTongEnum = 
{
    [1] = {DressLatitudeEnum.tongkongdaxiao, "瞳孔大小"}, --瞳孔大小
    [2] = {DressLatitudeEnum.tongmodaxiao, "瞳膜大小"}, --瞳膜大小
    [3] = {DressLatitudeEnum.fanguangqiangdu, "反光强度"}, --反光强度
}

---妆容 花细枚举
local DressHuaXiEnum = 
{
    [1] = {DressLatitudeEnum.daxiao, "大小"}, --大小
    [2] = {DressLatitudeEnum.xuanzhuan, "旋转"}, --旋转
    [3] = {DressLatitudeEnum.shangxiapianyi, "上下偏移"}, --上下偏移
    [4] = {DressLatitudeEnum.zuoyoupianyi, "左右偏移"}, --左右偏移
}

--妆容 眉底枚举
local DressEyebrowBGEnum = 
{
    [1] = {DressLatitudeEnum.toumingdu, "透明度"}, -- 透明度
}


---妆容维度名字
local DressLatitude = 
{
    guangze = "光泽",
    zhouwen = "皱纹",
    toumingdu = "透明度",
    shumi = "疏密",
    chunwen = "唇纹",
    liangpian = "亮片",
    keli = "颗粒",
    tongkong = "瞳孔",
    tongmo = "瞳膜",
    fanguang = "泛光",
    daxiao = "大小",
    xuanzhuan = "旋转",
    shangxia = "上下",
    zuoyou = "左右",
}

----------------------- 古风捏脸 -----------------------
local function InitShapeDataSubList(shapeData)
    local iSex = 2
    local tempDic = {}
    shapeData.subList = {}
    local data = shapeData.data
    for index, value in ipairs(FaceConfig) do
        if value.Sex == iSex and value.FacialID == data.FacialID then
            local AreaID = value.AreaID 
            local areaData = tempDic[AreaID]
            if areaData == nil then 
                tempDic[AreaID] = {}
                table.insert(shapeData.subList, {data = value})
            end
        end
    end
end

local function InitAreaDataSubList(areaData)
    local iSex = 2
    local tempDic = {}
    areaData.subList = {}
    local data = areaData.data
    for index, value in ipairs(FaceConfig) do
        if value.Sex == iSex and value.FacialID == data.FacialID and value.AreaID == data.AreaID then
            local LatitudeID = value.LatitudeID 
            local latitudeData = tempDic[LatitudeID]
            if latitudeData == nil then 
                tempDic[LatitudeID] = {}
                table.insert(areaData.subList, {data = value})
            end
        end
    end
end 

local function InitLatitudeDataSubList(latitudeData)
    local iSex = 2
    local tempDic = {}
    latitudeData.subList = {}
    local data = latitudeData.data
    for index, value in ipairs(FaceConfig) do
        if value.Sex == iSex and value.FacialID == data.FacialID and value.AreaID == data.AreaID and value.LatitudeID == data.LatitudeID then
            table.insert(latitudeData.subList, {data = value})
        end
    end
end

local function InitAllFaceDatas(self)
    self.shapeTypesList = {}
    local iSex = 2
    local tempDic = {}
    for index, value in ipairs(FaceConfig) do
        if value.Sex == iSex then
            local facialID = value.FacialID 
            local shapeData = tempDic[facialID]
            if shapeData == nil then 
                tempDic[facialID] = {}
                table.insert(self.shapeTypesList, {data = value})
            end
        end
    end
    table.remove(self.shapeTypesList, #self.shapeTypesList)
end
---------------------- end ----------------------------

function MakeupModel:Init()
    self.category = 'pinch'
    self.gender = GenderTypeEnum.Male
    self.roleJobID = 1
    self:InitData()
    self.m_CacheShapeValueDic = {}
    self.tabSliderRange = {}
    self.tabConfig = {}
    InitAllFaceDatas(self)
end

function MakeupModel:InitData()
    self.makeupData = {}
    for _, gender in pairs(GenderTypeEnum) do 
        self.makeupData[gender] = {}
        local data = MakeupConfig.MakeupData[gender]
        local pinchData = data[GateGoryEnum.pinch]
        local makeupData = data[GateGoryEnum.makeup]

        local categoryData = {}
        for k, v in pairs(data) do 
            categoryData[k] = {}
            categoryData[k].type = v.type
            categoryData[k].desc = v.desc          
        end
        self.makeupData[gender].categoryData = categoryData

        local pinchList = {}
        local styleData = {}
        for k, v in pairs(pinchData.data) do
            pinchList[k] = {}
            pinchList[k].desc = v.desc
            pinchList[k].index = k
            styleData[k] = v.data
        end
        self.makeupData[gender].pinchList = pinchList
        self.makeupData[gender].styleData = styleData

        local makeupList = {}
        local gridData = {}
        for k, v in pairs(makeupData.data) do
            makeupList[k] = {}
            makeupList[k].desc = v.desc
            makeupList[k].index = k

            gridData[k] = {}
            gridData[k].image = v.image
            gridData[k].data = v.data
        end
        self.makeupData[gender].makeupList = makeupList
        self.makeupData[gender].gridData = gridData
    end
end

function MakeupModel:GetCategoryData()
    return self.makeupData[self.gender].categoryData
end

function MakeupModel:GetPinchList()
    return self.makeupData[self.gender].pinchList
end

function MakeupModel:GetMakeupList()
    return self.makeupData[self.gender].makeupList
end

function MakeupModel:GetStyleData(index)
    index = index or 1
    return self.makeupData[self.gender].styleData[index]
end

function MakeupModel:GetGridData(index)
    index = index or 1
    return self.makeupData[self.gender].gridData[index]
end

function MakeupModel:GetCategory()
    return self.category
end

function MakeupModel:SetCategory(category)
    self.category = category
end

function MakeupModel:SetGender(gender)
    self.gender = gender
end

function MakeupModel:GetGender()
    return self.gender
end

function MakeupModel:SetRoleJobID(id)
    self.roleJobID = id
end

function MakeupModel:GetRoleJobID()
    return self.roleJobID
end

function MakeupModel:GetEnterCameraOffset()
    if self.gender == GenderTypeEnum.Male then
        return MALE_ENTER_MAKEUP_HEIGHT 
    elseif self.gender == GenderTypeEnum.Female then
        return FEMALE_ENTER_MAKEUP_HEIGHT
    else
        return LEAVE_MAKEUP_HEIGHT
    end   
end

function MakeupModel:GetLeaveCameraOffset()
    return LEAVE_MAKEUP_HEIGHT
end

----------------------- 古风捏脸 -----------------------
function MakeupModel:GetShapeTypeList()
    if self.shapeTypesList == nil then 
        InitAllFaceDatas(self)
    end
    return self.shapeTypesList
end

function MakeupModel:GetShapeDataSubList(shapeData)
    if shapeData.subList == nil then 
        InitShapeDataSubList(shapeData)
    end
    return shapeData.subList
end

function MakeupModel:GetAreaDataSubList(areaData)
    if areaData.subList == nil then 
        InitAreaDataSubList(areaData)
    end
    return areaData.subList
end 

function MakeupModel:GetLatitudeDataSubList(latitudeData)
    if latitudeData.subList == nil then 
        InitLatitudeDataSubList(latitudeData)
    end
    return latitudeData.subList
end

function MakeupModel:CacheShapeValue(shapeID, value)
    self.m_CacheShapeValueDic[shapeID] = value
end

function MakeupModel:GetCacheShapeValue(shapeID, value)
    return self.m_CacheShapeValueDic[shapeID] or 0.5
end

---获取妆容数据
function MakeupModel:GetMakeUpDic()
    if not self.bDress then
        local iSex = 2
        self.dressDic = {}
        self.subDressDic = {}
        self.bigDressDic = {}
        for index, value in ipairs(MakeupConfigNew) do
            if value.Sex == iSex then
                if self.dressDic[value.PrimaryID] == nil then
                    local dressDic = {}
                    local Latitudelst = {}
                    --维度数据组合
                    local data = self:CompareLatitudelst(value)
                    table.insert(Latitudelst,data)
                    local mixData = self:MixDressData(value,Latitudelst)
                    dressDic[value.SecondaryID] = mixData
                    self.dressDic[value.PrimaryID] = dressDic

                    if self.subDressDic[value.PrimaryID] == nil then
                        local infoList = {}
                        table.insert(infoList,value)
                        self.subDressDic[value.PrimaryID] = infoList 
                    end
                else
                    local dressDic = self.dressDic[value.PrimaryID]

                    local mixData = dressDic[value.SecondaryID]
                    if mixData then
                        local data = self:CompareLatitudelst(value)
                        table.insert(mixData.latitudelst,data)
                    else
                        local Latitudelst = {}
                        local data = self:CompareLatitudelst(value)
                        table.insert(Latitudelst,data)
                        local mixData = self:MixDressData(value,Latitudelst)
                        dressDic[value.SecondaryID] = mixData
                    end

                    local infoList = self.subDressDic[value.PrimaryID]
                    table.insert(infoList,value)
                end

                if self.bigDressDic[value.PrimaryID] == nil then
                    self.bigDressDic[value.PrimaryID] = value
                end
            end
        end

        --double分割数据
        self:DoubleSubData()
        self.bDress = true
    end
    
    return self.bigDressDic, self.subDressDic, self.dressDic
end

---组合维度数据
function MakeupModel:CompareLatitudelst(value)
    local data = self:OnDressData(value)
    local arrays = string.split(value.Switch,",")
    data.iPopColor = tonumber(arrays[1])
    data.iFreeColor = tonumber(arrays[2])

    if tonumber(arrays[3]) == 1 then
        local sliderData = self:DressSliderData(DressLatitude.guangze, DressLatitudeEnum.guangze)
        table.insert(data.Latitude,sliderData)
    end
    if tonumber(arrays[4]) == 1 then
        local sliderData = self:DressSliderData(DressLatitude.zhouwen, DressLatitudeEnum.zhouwenqiangdu)
        table.insert(data.Latitude,sliderData)
    end
    if tonumber(arrays[5]) == 1 then
        local sliderData = self:DressSliderData(DressLatitude.toumingdu, DressLatitudeEnum.toumingdu)
        table.insert(data.Latitude,sliderData)
    end
    if tonumber(arrays[6]) == 1 then
        local sliderData = self:DressSliderData(DressLatitude.shumi, DressLatitudeEnum.shumi)
        table.insert(data.Latitude,sliderData)
    end
    if tonumber(arrays[7]) == 1 then
        local sliderData = self:DressSliderData(DressLatitude.chunwen, DressLatitudeEnum.chunwenshenqian)
        table.insert(data.Latitude,sliderData)
    end
    --珠粉页签
    if tonumber(arrays[8]) == 1 then
        data.iToggle = 1
        data.iPopColor = 1
        data.iFreeColor = 1
        data.zhuFenLatitude = {}
        for index, value in ipairs(DressZhuFenEnum) do
            local sliderData = self:DressSliderData(value[2],value[1])
            table.insert(data.zhuFenLatitude,sliderData)
        end
    end
    --美瞳页签
    if tonumber(arrays[9]) == 1 then
        data.iEyeToggle = 1
        self:SetToggleSlider(data,DressMeiTongEnum)
    end
    --花细页签
    if tonumber(arrays[10]) == 1 then
        self:SetToggleSlider(data,DressHuaXiEnum)
    end
    --眉毛页签
    if tonumber(arrays[11]) == 1 then
        data.iEyebrowToggle = 1
        data.eyebrowBGLatitude = {}
        for index, value in ipairs(DressEyebrowBGEnum) do
            local sliderData = self:DressSliderData(value[2], value[1])
            table.insert(data.eyebrowBGLatitude, sliderData)
        end
    end
    return data
end

---妆容数据类
function MakeupModel:OnDressData(value)
    local initdata = 
    {
        dressConfig = value, 
        iToggle = 0, --珠粉页签
        iEyeToggle = 0, --眼页签
        iEyebrowToggle = 0, --眉毛页签
        iPopColor = 0,  --流行色盘
        iFreeColor = 0, --自由色盘
        Latitude = {},  --slider维度
        zhuFenLatitude = nil, --珠粉slider维度
        eyebrowBGLatitude = nil, --眉底slider维度
        sGroupName = ""
    }

    return initdata
end

---妆容维度数据
function MakeupModel:DressSliderData(name, type)
    local initdata =
    {
        iName = name,
        iLatitudeType = type,--调节类型
        iSliderNum = 50,
    }

    return initdata
end

function MakeupModel:MixDressData(Config, Latitudelst)
    local initdata =
    {
        config = Config,
        latitudelst = Latitudelst,
        doubleLatitudelst = nil,
    }

    return initdata
end

---设置开启页签的维度
function MakeupModel:SetToggleSlider(data, dressEnum)
    for index, value in ipairs(dressEnum) do
        local sliderData = self:DressSliderData(value[2],value[1])
        table.insert(data.Latitude,sliderData)
    end
end

---三级页签下面的double的item
function MakeupModel:DoubleSubData()
    for index, value in ipairs(self.dressDic) do
        if value[0] then
            local sublst = value[0].latitudelst
            self:Spiltlst(sublst, value[0], "DoubleItem")
        else
             for keyIndex, mixData in ipairs(value) do
                local sublst = mixData.latitudelst
                self:Spiltlst(sublst, mixData, "DoubleItem2")
             end   
        end
    end
end

---分割三级子数据
function MakeupModel:Spiltlst(sublst, mixData, groupName)
    local totalDic = {}
    local dressData = self:OnDressData(nil)
    dressData.sGroupName = groupName
    --table.insert(sublst,1,dressData)
    for index, value in ipairs(sublst) do
        local newIndex = math.floor((index - 1) / 2) + 1
        if totalDic[newIndex] == nil then
            local infolst = {}
            value.sGroupName = groupName
            table.insert(infolst,value)
            totalDic[newIndex] = infolst
        else
            local infolst = totalDic[newIndex]
            value.sGroupName = groupName
            table.insert(infolst,value)
        end
    end
    mixData.doubleLatitudelst = totalDic
end

---记录妆容的操作数据
function MakeupModel:RecordDressMinData(iBigIndex, iThreeIndex, iItemIndex, iSubIndex, threeName)
    if self.m_DressSelectDic == nil then 
        self.m_DressSelectDic = {}
    end 

    if self.m_DressSelectDic.MakeUpSelectDic[iBigIndex] == nil then
        local nameDic = nil
        local data = nil
        if iThreeIndex > 0 then
            nameDic = {}
            nameDic[threeName] = {iThreeIndex = iThreeIndex,iItemIndex = iItemIndex, iSubIndex = iSubIndex}
            data = self:DressData(iBigIndex,nameDic,0,0)
        else
            data = self:DressData(iBigIndex,nil,iItemIndex,iSubIndex)    
        end
        
        self.m_DressSelectDic.MakeUpSelectDic[iBigIndex] = data
    else
        local mixData = self.m_DressSelectDic.MakeUpSelectDic[iBigIndex]
        mixData.iBigIndex = iBigIndex
        if  iThreeIndex > 0 then
            if mixData.iThreeIndexDic then
                if mixData.iThreeIndexDic[threeName] then
                    mixData.iThreeIndexDic[threeName] = {iThreeIndex = iThreeIndex,iItemIndex = iItemIndex, iSubIndex = iSubIndex}
                else
                    mixData.iThreeIndexDic[threeName] = {iThreeIndex = iThreeIndex,iItemIndex = iItemIndex, iSubIndex = iSubIndex}
                end
            end
        else
            mixData.iItemIndex = iItemIndex
            mixData.iSubIndex = iSubIndex
        end
    end
end

function MakeupModel:DressData(BigIndex, ThreeIndexDic, ItemIndex, SubIndex)
    local initdata =
    {
        iBigIndex = BigIndex,
        iThreeIndexDic = ThreeIndexDic,
        iItemIndex = ItemIndex,
        iSubIndex = SubIndex,
    }

    return initdata
end

function MakeupModel:GetRecordMixData(iBigIndex)
    if self.m_DressSelectDic == nil then 
        self.m_DressSelectDic = {}
    end

    if self.m_DressSelectDic.MakeUpSelectDic == nil then
        self.m_DressSelectDic.MakeUpSelectDic = {}
    end
    return self.m_DressSelectDic.MakeUpSelectDic[iBigIndex]
end

function MakeupModel:GetConfig(strID)
    if self.tabConfig[strID] == nil then
        for k, v in pairs(MakeupConfigNew) do
            if v.FaceID == strID then
                self.tabConfig[strID] = v
            end
        end
    end

    return self.tabConfig[strID]
end

function MakeupModel:GetSilderRange(strID)
    local config = self:GetConfig(strID)
    if self.tabSliderRange[strID] == nil then
        local tabRange = {min = 0, max = 1}
        if config then
            local tabSplit = string.split(config.SwitchRange, "_")
            tabRange.min = tonumber(tabSplit[1])
            tabRange.max = tonumber(tabSplit[2])
        end
        self.tabSliderRange[strID] = tabRange
    end

    return self.tabSliderRange[strID]
end

function MakeupModel:GetLuminance(strID)
    local config = self:GetConfig(strID)
    local fLuminance = 1
    if config then
        fLuminance = tonumber(config.ResourcesLuminance)
    end

    return fLuminance
end

---获取妆容数值
function MakeupModel:GetFaceMakeupValue(makeupType, componentFcaeMakeUp)
    if componentFcaeMakeUp == nil then 
        return 0.5
    end

    local makeUpValue
    local bColour = false
    local tabSliderRange = nil
    local faceMakeupData = componentFcaeMakeUp:GetFaceMakeupData()

    local getValueConfig = MakeUpDefine.GetValueType[makeupType]
    if getValueConfig then  
        local firstKey = getValueConfig[1]
        return faceMakeupData[firstKey]
    end

    --------------------------------------- 皮肤 -----------------------------------------
    if makeupType   == MakeUpDefine.MakeupEditType.Skin_Specular then               -- 皮肤 光泽 
        makeUpValue = 2 - (faceMakeupData.faceSpecular or 1.5)         -- 范围 2 ~ 1-- 2 最粗糙 1 最光滑
        makeUpValue = (makeUpValue)
    --------------------------------------- 修容 ----------------------------------------- 
    elseif makeupType   == MakeUpDefine.MakeupEditType.Spot_Density then                -- 斑 疏密
        local spotBias = faceMakeupData.spotBias                   
        if spotBias then
            if self.spotBiasBase == nil then
                self.spotBiasBase = componentFcaeMakeUp.spotBiasBase
            end
            makeUpValue = (spotBias.x / self.spotBiasBase.x) - 1
        else
            makeUpValue = 0.5     
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Spot_DyeColorIntensity then      -- 斑 染色强度
        makeUpValue = faceMakeupData.spotColorParam.x or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Spot_DyeColorEnable then         -- 斑 染色开关
        makeUpValue = faceMakeupData.spotColorParam.y or 0   
        makeUpValue = faceMakeupData.spotColorParam.z or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_Alpha then                  -- 痣 透明度
        makeUpValue = faceMakeupData.moleAlpha or 0.5   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_Scale then                -- 痣 疏密
        if self.moleBiasBase == nil then
            self.moleBiasBase = componentFcaeMakeUp.moleBiasBase
        end
        local curMoleBias = faceMakeupData.moleBias
        -- value 范围0~1 对应调整花钿缩放范围 0~2
        if curMoleBias then
            makeUpValue = curMoleBias.x / (self.moleBiasBase.x * 2)
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_Rot then            -- 痣 痣旋转
        if faceMakeupData.moleAngle then
            makeUpValue = faceMakeupData.moleAngle / 2 + 0.5
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_PosY then           -- 痣 位移上下
        local curMoleBias                         = faceMakeupData.moleBias
        if curMoleBias then
            makeUpValue = curMoleBias.w / 1024
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_PosX then           -- 痣 位移左右
        local curMoleBias                         = faceMakeupData.moleBias
        if curMoleBias then
            makeUpValue = curMoleBias.z / 1024
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_DyeColorIntensity then      -- 痣 染色强度
        makeUpValue = faceMakeupData.moleColorParam.x or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_DyeColorEnable then      -- 痣 染色开关
        makeUpValue = faceMakeupData.moleColorParam.y or 0   
        makeUpValue = faceMakeupData.moleColorParam.z or 1   
    --------------------------------------- 眉毛 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eyebrow_RecommendColor           -- 眉毛 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.Eyebrow_Color then               -- 眉毛 自定义色
        makeUpValue = faceMakeupData.eyebrowColor  
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eyebrow_Alpha then               -- 眉毛 透明度
        makeUpValue = faceMakeupData.eyebrowAlpha
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eyebrow_DyeColorIntensity then   -- 眉毛 染色强度
        makeUpValue = faceMakeupData.eyebrowColorParam.x or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eyebrow_DyeColorEnable then    -- 眉毛 染色范围最小值
        makeUpValue = faceMakeupData.eyebrowColorParam.y or 0   
        makeUpValue = faceMakeupData.eyebrowColorParam.z or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyebrowBG_RecommendColor       -- 眉底 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.EyebrowBG_Color then           -- 眉底 自定义色
        makeUpValue = faceMakeupData.eyebrowbgColor
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyebrowBG_Alpha then           -- 眉底 透明度
        makeUpValue = faceMakeupData.eyebrowbgAlpha
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyebrowBG_DyeColorIntensity then   -- 眉毛 染色强度
        makeUpValue = faceMakeupData.eyebrowbgColorParam.x or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eyebrow_DyeColorEnable then    -- 眉毛 染色范围最小值
        makeUpValue = faceMakeupData.eyebrowbgColorParam.y or 0   
        makeUpValue = faceMakeupData.eyebrowbgColorParam.z or 1   
    --------------------------------------- 睫毛 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.Cornea_Alpha then                -- 睫毛 透明度
        makeUpValue = faceMakeupData.corneaAlpha or 0.5 

    --------------------------------------- 眼影 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeShadow_RecommendColor         -- 眼影 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.EyeShadow_Color then             -- 眼影 自定义色
        makeUpValue = faceMakeupData.eyeshadowColor  
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeShadow_Alpha then             -- 眼影 透明度
        makeUpValue = faceMakeupData.eyeshadowAlpha or 0.5
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeShadow_CrystalRecommendColor  -- 眼影 珠粉 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.EyeShadow_CrystalColor then      -- 眼影 珠粉 自定义色
        makeUpValue = faceMakeupData.eyeShadowCrystalColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeShadow_CrystalIntensity then  -- 眼影 珠粉 强度
        if faceMakeupData.eyeShadowCrystalIntensity then
            makeUpValue = faceMakeupData.eyeShadowCrystalIntensity / 10
        else
            makeUpValue = 0.5
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeShadow_CrystalUVTiling then   -- 眼影 珠粉 密度
        if faceMakeupData.eyeShadowCrystalUVTiling then
            makeUpValue = (faceMakeupData.eyeShadowCrystalUVTiling - 2.6) / 12.4
        else
            makeUpValue = 0.5
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeShadow_DyeColorIntensity then   -- 眼影 染色强度
        makeUpValue = faceMakeupData.eyeShadowColorParam.x or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeShadow_DyeColorEnable then    -- 眼影 染色开关
        makeUpValue = faceMakeupData.eyeShadowColorParam.y or 0   
        makeUpValue = faceMakeupData.eyeShadowColorParam.z or 1   
    --------------------------------------- 眼线 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeLinear_RecommendColor         -- 眼线 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.EyeLinear_Color then             -- 眼线 自定义色
        makeUpValue = faceMakeupData.eyeLinearColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeLinear_Alpha then             -- 眼线 透明度
        makeUpValue = faceMakeupData.eyeLinearAlpha  or 0.5

    --------------------------------------- 眼睛 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_RecommendColor_L               -- 眼睛 左 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.Eye_Color_L then                   -- 眼睛 左 自定义色
        makeUpValue = faceMakeupData.irisColor          
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_PupilSize_L then               -- 眼睛 左 瞳孔大小
        if faceMakeupData.pupilSize then
            makeUpValue = faceMakeupData.pupilSize
        else
            makeUpValue = 0.5
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_IrisScale_L then               -- 眼睛 左 虹膜大小
        if faceMakeupData.irisScale then
            makeUpValue = (2.57 - faceMakeupData.irisScale) / 0.86
        else
            makeUpValue = 0.5 
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_EyeSpecular_L then             -- 眼睛 左 高光强度
        makeUpValue = 1.0 - (faceMakeupData.eyeSpecular or 0.5 )   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_RecommendColor_R               -- 眼睛 右 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.Eye_Color_R then                   -- 眼睛 右 自定义色
        makeUpValue = faceMakeupData.irisRColor     
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_PupilSize_R then               -- 眼睛 右 瞳孔大小
        makeUpValue = faceMakeupData.pupilRSize
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_IrisScale_R then               -- 眼睛 右 虹膜大小
        if faceMakeupData.irisRScale then
            makeUpValue = (2.57 - faceMakeupData.irisRScale) / 0.86
        else
            makeUpValue = 0.5
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Eye_EyeSpecular_R then             -- 眼睛 右 高光强度
        makeUpValue = 1.0 - faceMakeupData.eyeRSpecular  or 0.5

        --------------------------------------- 眼皮 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.EyeWrinkle_Alpha then                -- 眼皮 透明度
        makeUpValue = faceMakeupData.eyeWrinkleAlpha or 0.5

    --------------------------------------- 唇妆 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_RecommendColor              -- 唇妆 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.Lips_Color then                  -- 唇妆 自定义色
        makeUpValue = faceMakeupData.lipsColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_Specular then               -- 唇妆 光泽
        makeUpValue = (faceMakeupData.lipsSpecular / 4) or 0.5
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_Alpha then                  -- 唇妆 透明度
        makeUpValue = faceMakeupData.lipsAlpha or 0.5
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_WrinkleAlpha then           -- 唇妆 唇纹深浅
        makeUpValue = faceMakeupData.lipsWrinkleAlpha or 0.5
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_CrystalRecommendColor       -- 唇妆 珠粉 推荐色
    or makeupType == MakeUpDefine.MakeupEditType.Lips_CrystalColor then                 -- 唇妆 珠粉 自定义色
        makeUpValue = faceMakeupData.lipsCrystalColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_CrystalIntensity then       -- 唇妆 珠粉 强度
        if faceMakeupData.lipsCrystalIntensity then
            makeUpValue = (faceMakeupData.lipsCrystalIntensity - 1) / 2.12
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_CrystalUVTiling then        -- 唇妆 珠粉 密度
        if faceMakeupData.lipsCrystalUVTiling then
            makeUpValue = (faceMakeupData.lipsCrystalUVTiling - 1.7) / 29.3
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_DyeColorIntensity then   -- 唇妆 染色强度
        makeUpValue = faceMakeupData.lipsColorParam.x or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Lips_DyeColorEnable then    -- 唇妆 染色开关
        makeUpValue = faceMakeupData.lipsColorParam.y or 0   
        makeUpValue = faceMakeupData.lipsColorParam.z or 1   
    --------------------------------------- 腮红 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.Blush_RecommendColor             -- 腮红 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.Blush_Color then                 -- 腮红 自定义色
        makeUpValue = faceMakeupData.blushColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.Blush_Alpha then                 -- 腮红 透明度
        makeUpValue = faceMakeupData.blushAlpha or 0.5
    elseif makeupType   == MakeUpDefine.MakeupEditType.Blush_CrystalRecommendColor      -- 腮红 珠粉 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.Blush_CrystalColor then          -- 腮红 珠粉 自定义色
        makeUpValue = faceMakeupData.blushCrystalColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.Blush_CrystalIntensity then      -- 腮红 珠粉 强度
        if faceMakeupData.blushCrystalIntensity then
            makeUpValue = faceMakeupData.blushCrystalIntensity / 10
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Blush_CrystalUVTiling then       -- 腮红 珠粉 密度
        if faceMakeupData.blushCrystalUVTiling then
            makeUpValue = (faceMakeupData.blushCrystalUVTiling - 1.7) / 16.3
        else
            makeUpValue = 0.5    
        end

    --------------------------------------- 花钿 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_RecommendColor            -- 花钿 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.Tattoo_Color then                -- 花钿 自定义色
        makeUpValue = faceMakeupData.tattooColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_Alpha then                -- 花钿 透明度
        makeUpValue = faceMakeupData.tattooAlpha  or 0.5
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_TattooScale then          -- 花钿 花钿缩放
        if self.tattooBiasBase == nil then
            self.tattooBiasBase = componentFcaeMakeUp.tattooBiasBase
        end
        local curTattooBias = faceMakeupData.tattooBias
        -- value 范围0~1 对应调整花钿缩放范围 0~2
        if curTattooBias then
            makeUpValue = curTattooBias.x / (self.tattooBiasBase.x * 2)
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_TattooRot then            -- 花钿 花钿旋转
        if faceMakeupData.tattooAngle then
            makeUpValue = faceMakeupData.tattooAngle / 2 + 0.5
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_TattooPosY then           -- 花钿 花钿位移上下
        local curTattooBias                         = faceMakeupData.tattooBias
        if curTattooBias then
            makeUpValue = curTattooBias.w / 1024
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_TattooPosX then           -- 花钿 花钿位移左右
        local curTattooBias                         = faceMakeupData.tattooBias
        if curTattooBias then
            makeUpValue = curTattooBias.z / 1024
        else
            makeUpValue = 0.5    
        end
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_DyeColorIntensity then   -- 花钿 染色强度
        makeUpValue = faceMakeupData.tattooColorParam.x or 1   
    elseif makeupType   == MakeUpDefine.MakeupEditType.Tattoo_DyeColorEnable then    -- 花钿 染色开关
        makeUpValue = faceMakeupData.tattooColorParam.y or 0   
        makeUpValue = faceMakeupData.tattooColorParam.z or 1   
    --------------------------------------- 皱纹 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.Wrinkle_Alpha then               -- 皱纹 透明度
        makeUpValue = faceMakeupData.wrinkleAlpha   or 0.5  

    --------------------------------------- 唇纹 -----------------------------------------

    --------------------------------------- 染发 -----------------------------------------
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairColor1_RecommendColor            -- 染发 整体 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.HairColor1_Color then                -- 染发 整体 自定义色
        makeUpValue = faceMakeupData.hairSecondaryColor    
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairColor1_DyeColorEnable then
        makeUpValue = faceMakeupData.hairSecondaryColorToggle or 1
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairColor2_RecommendColor            -- 染发 挑染 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.HairColor2_Color then                -- 染发 挑染 自定义色
        makeUpValue = faceMakeupData.hairThirdColor   
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairColor2_DyeColorEnable then
        makeUpValue = faceMakeupData.hairThirdColorToggle or 0
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairColorTail_RecommendColor         -- 染发 挑染 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.HairColorTail_Color then             -- 染发 挑染 自定义色
        makeUpValue = faceMakeupData.hairTailColor 
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairColorTail_TailRange then         -- 染发 发尾 发尾范围
        local rangeValue = faceMakeupData.hairTailRange
        if rangeValue > 6 then
            makeUpValue = (30 - rangeValue) / 240
        elseif rangeValue >= 2 then
            makeUpValue = (6 - rangeValue) / 10 + 0.1
        else
            makeUpValue = (2 - rangeValue) / 3.8 + 0.5
        end
        -- makeUpValue = faceMakeupData.hairTailRange   or 0.5  
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairColorTail_DyeColorEnable then
        makeUpValue = faceMakeupData.hairTailColorToggle
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairSpecColor1_RecommendColor        -- 染发 高光1 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.HairSpecColor1_Color then            -- 染发 高光1 自定义色
        makeUpValue = faceMakeupData.hairAnisoSpecColor1 
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairSpecColor1_AnisoGloss then       -- 染发 高光1 头发光泽
        makeUpValue = faceMakeupData.hairAnisoGloss1   or 0.5  
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairSpecColor2_RecommendColor        -- 染发 高光2 推荐色
    or makeupType       == MakeUpDefine.MakeupEditType.HairSpecColor2_Color then            -- 染发 高光2 自定义色
        makeUpValue = faceMakeupData.hairAnisoSpecColor2 
    elseif makeupType   == MakeUpDefine.MakeupEditType.HairSpecColor2_AnisoGloss then       -- 染发 高光2 头发光泽
        makeUpValue = faceMakeupData.hairAnisoGloss2   or 0.5  
    elseif makeupType   == MakeUpDefine.MakeupEditType.Mole_Color then       -- 痣 自定义色
        makeUpValue = faceMakeupData.moleColor
    elseif makeupType   == MakeUpDefine.MakeupEditType.Spot_Color then       -- 斑 自定义色
        makeUpValue = faceMakeupData.spotColor
    end

    return makeUpValue
end

return MakeupModel