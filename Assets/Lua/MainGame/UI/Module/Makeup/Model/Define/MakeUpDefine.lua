local MakeUpDefine = {}

MakeUpDefine.MakeupEditType =
{
    -- // 0 眼线 eyeLinear
    -- // 1 花钿 tattoo
    -- // 2 鼻子修容 nosecontour
    -- // 3 颧骨修容 cheekcontour
    -- // 4 下颌修容 jawcontour
    -- // 5 腮红 blush
    -- // 6 嘴唇 lips
    -- // 7 眼皮 eyeWrinkle
    -- // 8 眼影 eyeshadow
    -- // 9 眉底 eyebrowbg
    -- // 10 眉毛 eyebrow
    -- // 11 斑点 spot
    -- // 12 痣 mole
    -- // 13 眼睛 左（虹膜）iris - L
    -- // 14 睫毛（角膜）cornea
    -- // 15 皱纹 wrinkle
    -- // 16 唇纹 lipsWrinkle
    -- // 17 眼睛 右（虹膜）iris - R
    -- 皮肤 1_1
    Skin_RecommendColor             = "1_1_1",       -- 皮肤 推荐色
    Skin_Specular                   = "1_1_3",       -- 皮肤 光泽
    Skin_Wrinkle                    = "1_1_4",       -- 皮肤 皱纹
    -- 下颌修容 2_1
    JawContour_Tex                  = "2_1_0",       -- 下颌修容 纹理
    JawContour_RecommendColor       = "2_1_1",       -- 下颌修容 推荐色
    JawContour_Color                = "2_1_2",       -- 下颌修容 自定义色
    JawContour_Alpha                = "2_1_5",       -- 下颌修容 透明度
    -- 鼻子修容 2_2
    NoseContour_Tex                 = "2_2_0",       -- 鼻子修容 纹理
    NoseContour_RecommendColor      = "2_2_1",       -- 鼻子修容 推荐色
    NoseContour_Color               = "2_2_2",       -- 鼻子修容 自定义色
    NoseContour_Alpha               = "2_2_5",       -- 鼻子修容 透明度
    -- 颧骨修容 2_3
    CheekContour_Tex                = "2_3_0",       -- 颧骨修容 纹理
    CheekContour_RecommendColor     = "2_3_1",       -- 颧骨修容 推荐色
    CheekContour_Color              = "2_3_2",       -- 颧骨修容 自定义色
    CheekContour_Alpha              = "2_3_5",       -- 颧骨修容 透明度
    -- 斑 2_4
    Spot_Tex                        = "2_4_0",       -- 斑 纹理
    Spot_RecommendColor             = "2_4_1",       -- 斑 推荐色
    Spot_Color                      = "2_4_2",       -- 斑 自定义色
    Spot_Alpha                      = "2_4_5",       -- 斑 透明度
    Spot_Density                    = "2_4_6",       -- 斑 疏密
    Spot_DyeColorIntensity          = "2_4_20",      -- 斑 染色系数
    Spot_DyeColorEnable             = "2_4_23",      -- 斑 染色开关
    -- 痣 2_5
    Mole_Tex                        = "2_5_0",       -- 痣 纹理
    Mole_RecommendColor             = "2_5_1",       -- 痣 推荐色
    Mole_Color                      = "2_5_2",       -- 痣 推荐色
    Mole_Alpha                      = "2_5_5",       -- 痣 透明度
    Mole_Density                    = "2_5_6",       -- 痣 疏密
    Mole_Scale                      = "2_5_14",      -- 痣 大小
    Mole_Rot                        = "2_5_15",      -- 痣 旋转
    Mole_PosY                       = "2_5_16",      -- 痣 位移上下
    Mole_PosX                       = "2_5_17",      -- 痣 位移左右
    Mole_DyeColorIntensity          = "2_5_20",      -- 痣 染色系数
    Mole_DyeColorEnable             = "2_5_23",      -- 痣 染色开关
    -- 眉妆 3_1
    Eyebrow_Tex                     = "3_1_0",       -- 眉毛 纹理
    Eyebrow_RecommendColor          = "3_1_1",       -- 眉毛 推荐色
    Eyebrow_Color                   = "3_1_2",       -- 眉毛 自定义色
    Eyebrow_Alpha                   = "3_1_5",       -- 眉毛 透明度
    Eyebrow_DyeColorIntensity       = "3_1_20",      -- 眉毛 染色系数
    Eyebrow_DyeColorEnable          = "3_1_23",      -- 眉毛 染色开关
    -- 眉底 3_2
    EyebrowBG_RecommendColor        = "3_2_1",       -- 眉底 推荐色
    EyebrowBG_Color                 = "3_2_2",       -- 眉底 自定义色
    EyebrowBG_Alpha                 = "3_2_5",       -- 眉底 透明度
    EyebrowBG_DyeColorIntensity     = "3_2_20",      -- 眉底 染色系数
    EyebrowBG_DyeColorEnable        = "3_2_23",      -- 眉底 染色开关
    -- 睫毛 4_1
    Cornea_Tex                      = "4_1_0",       -- 睫毛 纹理
    Cornea_Alpha                    = "4_1_5",       -- 睫毛 透明度
    -- 眼影 5_1
    EyeShadow_Tex                   = "5_1_0",       -- 眼影 纹理
    EyeShadow_RecommendColor        = "5_1_1",       -- 眼影 底妆 推荐色
    EyeShadow_Color                 = "5_1_2",       -- 眼影 底妆 自定义色
    EyeShadow_Alpha                 = "5_1_5",       -- 眼影 底妆 透明度
    EyeShadow_CrystalRecommendColor = "5_1_18",      -- 眼影 珠粉 推荐色
    EyeShadow_CrystalColor          = "5_1_19",      -- 眼影 珠粉 自定义色
    EyeShadow_CrystalIntensity      = "5_1_8",      -- 眼影 珠粉 强度
    EyeShadow_CrystalUVTiling       = "5_1_9",      -- 眼影 珠粉 疏密
    EyeShadow_DyeColorIntensity     = "5_1_20",     -- 眼影 染色系数
    EyeShadow_DyeColorEnable        = "5_1_23",     -- 眼影 染色开关
    -- 眼线 5_2
    EyeLinear_Tex                   = "5_2_0",       -- 眼线 纹理
    EyeLinear_RecommendColor        = "5_2_1",       -- 眼线 纹理
    EyeLinear_Color                 = "5_2_2",       -- 眼线 纹理
    EyeLinear_Alpha                 = "5_2_5",       -- 眼线 纹理
    -- 美瞳 5_3
    Eye_Tex_L                         = "5_3_0_1",       -- 眼睛 左 纹理
    Eye_RecommendColor_L              = "5_3_1_1",       -- 眼睛 左 推荐色
    Eye_Color_L                       = "5_3_2_1",       -- 眼睛 左 自定义色
    Eye_Alpha_L                       = "5_3_5_1",       -- 眼睛 左 透明度
    Eye_PupilSize_L                   = "5_3_11_1",      -- 眼睛 左 瞳孔大小
    Eye_IrisScale_L                   = "5_3_12_1",      -- 眼睛 左 虹膜大小
    Eye_EyeSpecular_L                 = "5_3_13_1",      -- 眼睛 左 眼睛高光
    Eye_Tex_R                         = "5_3_0_2",       -- 眼睛 右 纹理
    Eye_RecommendColor_R              = "5_3_1_2",       -- 眼睛 右 推荐色
    Eye_Color_R                       = "5_3_2_2",       -- 眼睛 右 自定义色
    Eye_Alpha_R                       = "5_3_5_2",       -- 眼睛 右 透明度
    Eye_PupilSize_R                   = "5_3_11_2",      -- 眼睛 右 瞳孔大小
    Eye_IrisScale_R                   = "5_3_12_2",      -- 眼睛 右 虹膜大小
    Eye_EyeSpecular_R                 = "5_3_13_2",      -- 眼睛 右 眼睛高光
    -- 眼皮 5_4
    EyeWrinkle_Tex                    = "5_4_0",       -- 眼皮 纹理
    EyeWrinkle_Alpha                  = "5_4_5",       -- 眼皮 透明度
    -- 唇妆 6_1
    Lips_Tex                        = "6_1_0",       -- 唇妆 纹理
    Lips_RecommendColor             = "6_1_1",       -- 唇妆 推荐色
    Lips_Color                      = "6_1_2",       -- 唇妆 自定义色
    Lips_Specular                   = "6_1_3",       -- 唇妆 光泽
    Lips_Alpha                      = "6_1_5",       -- 唇妆 透明度
    Lips_WrinkleAlpha               = "6_1_7",       -- 唇妆 唇纹深浅
    Lips_CrystalRecommendColor      = "6_1_18",      -- 唇妆 珠粉 推荐色
    Lips_CrystalColor               = "6_1_19",      -- 唇妆 珠粉 自定义色
    Lips_CrystalIntensity           = "6_1_8",      -- 唇妆 珠粉 亮片强度
    Lips_CrystalUVTiling            = "6_1_9",      -- 唇妆 珠粉 颗粒大小
    Lips_DyeColorIntensity          = "6_1_20",     -- 唇妆 染色系数
    Lips_DyeColorEnable             = "6_1_23",     -- 唇妆 染色开关
    -- 腮红 7_1
    Blush_Tex                       = "7_1_0",       -- 腮红 纹理
    Blush_RecommendColor            = "7_1_1",       -- 腮红 推荐色
    Blush_Color                     = "7_1_2",       -- 腮红 自定义色
    Blush_Alpha                     = "7_1_5",       -- 腮红 透明度
    Blush_CrystalRecommendColor     = "7_1_18",      -- 腮红 珠粉 推荐色
    Blush_CrystalColor              = "7_1_19",      -- 腮红 珠粉 自定义色
    Blush_CrystalIntensity          = "7_1_8",       -- 腮红 珠粉 强度
    Blush_CrystalUVTiling           = "7_1_9",       -- 腮红 珠粉 疏密
    -- 花钿 8_1
    Tattoo_Tex                      = "8_1_0",       -- 花钿 纹理
    Tattoo_RecommendColor           = "8_1_1",       -- 花钿 推荐色
    Tattoo_Color                    = "8_1_2",       -- 花钿 自定义色
    Tattoo_Alpha                    = "8_1_5",       -- 花钿 透明度
    Tattoo_TattooScale              = "8_1_14",      -- 花钿 花钿缩放
    Tattoo_TattooRot                = "8_1_15",      -- 花钿 花钿旋转
    Tattoo_TattooPosY               = "8_1_16",      -- 花钿 花钿位移上下
    Tattoo_TattooPosX               = "8_1_17",      -- 花钿 花钿位移左右
    Tattoo_DyeColorIntensity        = "8_1_20",      -- 花钿 染色系数
    Tattoo_DyeColorEnable           = "8_1_23",      -- 花钿 染色开关
    -- 皱纹 9_1
    Wrinkle_Tex                      = "9_1_0",       -- 皱纹 纹理
    Wrinkle_Alpha                    = "9_1_5",       -- 皱纹 透明度
    -- 唇纹 10_1
    LipsWrinkle_Tex                  = "10_1_0",       -- 唇纹 纹理
    
    -- 染发 整体 20_1
    HairColor1_RecommendColor        = "20_1_1",       -- 染发 整体 推荐色
    HairColor1_Color                 = "20_1_2",       -- 染发 整体 自定义色
    HairColor1_DyeColorEnable        = "20_1_23",       -- 染发 整体 染色开关
    -- 染发 发尾 20_2
    HairColorTail_RecommendColor     = "20_2_1",       -- 染发 发尾 推荐色
    HairColorTail_Color              = "20_2_2",       -- 染发 发尾 自定义色
    HairColorTail_TailRange          = "20_2_21",      -- 染发 发尾 发尾范围
    HairColorTail_DyeColorEnable     = "20_2_23",      -- 染发 发尾 染色开关
    -- 染发 挑染 20_3
    HairColor2_RecommendColor        = "20_3_1",       -- 染发 挑染 推荐色
    HairColor2_Color                 = "20_3_2",       -- 染发 挑染 自定义色
    HairColor2_DyeColorEnable        = "20_3_23",      -- 染发 挑染 染色开关
    -- 染发 高光1 20_4
    HairSpecColor1_RecommendColor    = "20_4_1",       -- 染发 高光1 推荐色
    HairSpecColor1_Color             = "20_4_2",       -- 染发 高光1 自定义色
    HairSpecColor1_AnisoGloss        = "20_4_22",       -- 染发 高光1 头发光泽
    -- 染发 高光2 20_5
    HairSpecColor2_RecommendColor    = "20_5_1",       -- 染发 高光2 推荐色
    HairSpecColor2_Color             = "20_5_2",       -- 染发 高光2 自定义色
    HairSpecColor2_AnisoGloss        = "20_5_22",       -- 染发 高光2 头发光泽
}

-- 捏脸妆容初始化数据
MakeUpDefine.FaceMakeupInitData = 
{
    eyeLinearBias = Vector4.New(640, 176, 512, 383),
    tattooBias = Vector4.New(256, 215, 512, 301),
    tattooColorParam = Vector4.New(1, 1, 1, 0),
    nosecontourBias = Vector4.New(858, 608, 512, 564),
    nosecontourColor = Color.New(0.737, 0.3, 0.3),
    cheekcontourBias = Vector4.New(858, 608, 512, 564),
    cheekcontourColor = Color.New(0.737, 0.3, 0.3),
    jawcontourBias = Vector4.New(858, 608, 512, 564),
    jawcontourColor = Color.New(0.737, 0.3, 0.3),
    blushBias = Vector4.New(839.2, 709, 508.1, 478),
    blushColor = Color.New(255/255, 30/255, 57/255),
    lipsBias = Vector4.New(448.1, 198.4, 508.6, 554.9),
    lipsColor = Color.New(255/255, 32/255, 0/255),
    lipsColorParam = Vector4.New(1, 1, 1, 0),
    eyeWrinkleBias = Vector4.New(540, 195, 512.3, 363.5),
    eyeshadowBias = Vector4.New(640, 176, 512, 376),
    eyeshadowColor = Color.New(149/255, 0/255, 11/255),
    eyeshadowColorParam = Vector4.New(1, 1, 1, 0),
    eyebrowbgBias = Vector4.New(567, 91, 512, 279.9),
    eyebrowbgColor = Color.New(0/255, 0/255, 0/255),
    eyebrowbgColorParam = Vector4.New(6.37, 1, 1, 0),
    eyebrowBias = Vector4.New(567, 91, 512, 279.9),
    eyebrowColor = Color.New(0/255, 0/255, 0/255),
    eyebrowColorParam = Vector4.New(1.91, 1, 1, 0),
    spotBias = Vector4.New(756, 270, 512, 470),
    spotColor = Color.New(255/255, 117/255, 117/255),
    spotColorParam = Vector4.New(1, 1, 1, 0),
    moleBias = Vector4.New(22, 22, 690, 470),
    moleColorParam = Vector4.New(1, 1, 1, 0),
    wrinkleBias = Vector4.New(512, 512, 256, 256),
    lipsWrinkleBias = Vector4.New(103, 67, 256, 307),
}

MakeUpDefine.FaceCustomizeMaskType = {
    ["1_7"] = 17, -- 面部 下巴两侧
    ["1_6"] = 16, -- 面部 下巴整体
    ["1_5"] = 15, -- 面部 下巴
    ["1_9"] = 19, -- 面部 下颌角
    ["1_3"] = 13, -- 面部 脸颊
    ["1_4"] = 14, -- 面部 苹果肌
    ["1_1"] = 11, -- 面部 额头
    ["2_1"] = 21, -- 眼 眼睛整体
    ["2_5"] = 25, -- 眼 内眼角
    ["2_6"] = 26, -- 眼 外眼角
    ["2_7"] = 27, -- 眼 瞳孔
    ["2_2"] = 22, -- 眼 上眼皮
    ["2_4"] = 24, -- 眼 下眼皮
    ["3_1"] = 31, -- 眉 眉毛整体
    ["3_5"] = 35, -- 眉 印堂
    ["3_2"] = 32, -- 眉 眉头
    ["3_3"] = 33, -- 眉 眉中
    ["3_4"] = 34, -- 眉 眉尾
    ["4_1"] = 41, -- 鼻 鼻子整体
    ["4_2"] = 42, -- 鼻 鼻梁
    ["4_3"] = 43, -- 鼻 鼻头
    ["4_4"] = 44, -- 鼻 鼻底
    ["5_1"] = 51, -- 唇 嘴整体
    ["5_2"] = 52, -- 唇 嘴角
    ["5_5"] = 55, -- 唇 上唇两侧
    ["5_6"] = 56, -- 唇 下唇两侧
    ["5_3"] = 53, -- 唇 上唇中
    ["5_4"] = 54, -- 唇 下唇中
    ["6_1"] = 61, -- 耳 耳整体
    ["6_2"] = 62, -- 耳 耳垂
}

-- 对属性进行赋值
MakeUpDefine.SetOriginalValueType = {
    [MakeUpDefine.MakeupEditType.Skin_RecommendColor] = {[1] = "faceColor"},                          -- 皮肤 固定色
    [MakeUpDefine.MakeupEditType.Skin_Wrinkle] = {[1] = "wrinkleAlpha"},                              -- 皮肤 皱纹
    [MakeUpDefine.MakeupEditType.NoseContour_Alpha] = {[1] = "nosecontourAlpha"},                     -- 鼻子修容 透明度
    [MakeUpDefine.MakeupEditType.NoseContour_RecommendColor] = {[1] = "nosecontourColor"},            -- 鼻子修容 推荐色
    [MakeUpDefine.MakeupEditType.NoseContour_Color] = {[1] = "nosecontourColor"},                     -- 鼻子修容 自定义色
    [MakeUpDefine.MakeupEditType.CheekContour_Alpha] = {[1] = "cheekcontourAlpha"},                   -- 颧骨修容 透明度
    [MakeUpDefine.MakeupEditType.CheekContour_RecommendColor] = {[1] = "cheekcontourColor"},          -- 颧骨修容 推荐色
    [MakeUpDefine.MakeupEditType.CheekContour_Color] = {[1] = "cheekcontourColor"},                   -- 颧骨修容 自定义色
    [MakeUpDefine.MakeupEditType.JawContour_Alpha] = {[1] = "jawcontourAlpha"},                       -- 下巴修容 透明度
    [MakeUpDefine.MakeupEditType.JawContour_RecommendColor] = {[1] = "jawcontourColor"},              -- 下巴修容 推荐色
    [MakeUpDefine.MakeupEditType.JawContour_Color] = {[1] = "jawcontourColor"},                       -- 下巴修容 自定义色
    [MakeUpDefine.MakeupEditType.Spot_Alpha] = {[1] = "spotAlpha"},                                   -- 斑 透明度
    [MakeUpDefine.MakeupEditType.Mole_Alpha] = {[1] = "moleAlpha"},                                   -- 痣 透明度
    [MakeUpDefine.MakeupEditType.Eyebrow_RecommendColor] = {[1] = "eyebrowColor"},                    -- 眉毛 推荐色
    [MakeUpDefine.MakeupEditType.Eyebrow_Color] = {[1] = "eyebrowColor"},                             -- 眉毛 自定义色
    [MakeUpDefine.MakeupEditType.EyebrowBG_RecommendColor] = {[1] = "eyebrowbgColor"},                -- 眉底 推荐色
    [MakeUpDefine.MakeupEditType.EyebrowBG_Color] = {[1] = "eyebrowbgColor"},                         -- 眉底 自定义色
    [MakeUpDefine.MakeupEditType.EyebrowBG_Alpha] = {[1] = "eyebrowbgAlpha"},                         -- 眉底 透明度
    [MakeUpDefine.MakeupEditType.Eyebrow_Alpha] = {[1] = "eyebrowAlpha"},                             -- 眉毛 透明度
    [MakeUpDefine.MakeupEditType.Cornea_Alpha] = {[1] = "corneaAlpha"},                               -- 睫毛 透明度
    [MakeUpDefine.MakeupEditType.EyeShadow_Alpha] = {[1] = "eyeshadowAlpha"},                         -- 眼影 透明度
    [MakeUpDefine.MakeupEditType.EyeShadow_CrystalRecommendColor] = {[1] = "eyeShadowCrystalColor"},  -- 眼影 珠粉 推荐色
    [MakeUpDefine.MakeupEditType.EyeShadow_CrystalColor] = {[1] = "eyeShadowCrystalColor"},           -- 眼影 珠粉 自定义色
    [MakeUpDefine.MakeupEditType.EyeLinear_RecommendColor] = {[1] = "eyeLinearColor"},                -- 眼线 推荐色
    [MakeUpDefine.MakeupEditType.EyeLinear_Color] = {[1] = "eyeLinearColor"},                         -- 眼线 自定义色
    [MakeUpDefine.MakeupEditType.EyeLinear_Alpha] = {[1] = "eyeLinearAlpha"},                         -- 眼线 透明度
    [MakeUpDefine.MakeupEditType.Eye_RecommendColor_L] = {[1] = "irisColor"},                         -- 眼睛 左 推荐色
    [MakeUpDefine.MakeupEditType.Eye_Color_L] = {[1] = "irisColor"},                                  -- 眼睛 左 自定义色
    [MakeUpDefine.MakeupEditType.Eye_PupilSize_L] = {[1] = "pupilSize"},                              -- 眼睛 左 瞳孔大小
    [MakeUpDefine.MakeupEditType.Eye_RecommendColor_R] = {[1] = "irisRColor"},                        -- 眼睛 右 推荐色
    [MakeUpDefine.MakeupEditType.Eye_Color_R] = {[1] = "irisRColor"},                                 -- 眼睛 右 自定义色
    [MakeUpDefine.MakeupEditType.Eye_PupilSize_R] = {[1] = "pupilRSize"},                             -- 眼睛 右 瞳孔大小
    [MakeUpDefine.MakeupEditType.EyeWrinkle_Alpha] = {[1] = "eyeWrinkleAlpha"},                       -- 眼皮 透明度
    [MakeUpDefine.MakeupEditType.Lips_Alpha] = {[1] = "lipsAlpha"},                                   -- 唇妆 透明度
    [MakeUpDefine.MakeupEditType.Lips_WrinkleAlpha] = {[1] = "lipsWrinkleAlpha"},                     -- 唇妆 唇纹深浅
    [MakeUpDefine.MakeupEditType.Lips_CrystalRecommendColor] = {[1] = "lipsCrystalColor"},            -- 唇妆 珠粉 推荐色
    [MakeUpDefine.MakeupEditType.Lips_CrystalColor] = {[1] = "lipsCrystalColor"},                     -- 唇妆 珠粉 自定义色
    [MakeUpDefine.MakeupEditType.Blush_RecommendColor] = {[1] = "blushColor"},                        -- 腮红 推荐色
    [MakeUpDefine.MakeupEditType.Blush_Color] = {[1] = "blushColor"},                                 -- 腮红 自定义色
    [MakeUpDefine.MakeupEditType.Blush_Alpha] = {[1] = "blushAlpha"},                                 -- 腮红 透明度
    [MakeUpDefine.MakeupEditType.Blush_CrystalRecommendColor] = {[1] = "blushCrystalColor"},          -- 腮红 珠粉 推荐色
    [MakeUpDefine.MakeupEditType.Blush_CrystalColor] = {[1] = "blushCrystalColor"},                   -- 腮红 珠粉 自定义色
    [MakeUpDefine.MakeupEditType.Tattoo_Alpha] = {[1] = "tattooAlpha"},                               -- 花钿 透明度
    [MakeUpDefine.MakeupEditType.Wrinkle_Alpha] = {[1] = "wrinkleAlpha"},                             -- 皱纹 透明度
    [MakeUpDefine.MakeupEditType.Skin_Specular] = {[1] = "faceSpecular", [2] = function (value) return 2 - value end,},-- 皮肤 光泽 
    [MakeUpDefine.MakeupEditType.Mole_Rot] = {[1] = "moleAngle", [2] = function (value) return (value - 0.5) * 2 end,},-- 痣 痣旋转 
    [MakeUpDefine.MakeupEditType.EyeShadow_CrystalIntensity] = {[1] = "eyeShadowCrystalIntensity", [2] = function (value) return value * 10 end,},--眼影 珠粉 强度 
    [MakeUpDefine.MakeupEditType.EyeShadow_CrystalUVTiling] = {[1] = "eyeShadowCrystalUVTiling", [2] = function (value) return 2.6 + value * 12.4 end,},--眼影 珠粉 密度 
    [MakeUpDefine.MakeupEditType.Eye_IrisScale_L] = {[1] = "irisScale", [2] = function (value) return 2.57 - 0.86 * value end,},--眼睛 左 虹膜大小
    [MakeUpDefine.MakeupEditType.Eye_EyeSpecular_L] = {[1] = "eyeSpecular", [2] = function (value) return 1.0 - value end,},--眼睛 左 高光强度
    [MakeUpDefine.MakeupEditType.Eye_IrisScale_R] = {[1] = "irisRScale", [2] = function (value) return 2.57 - 0.86 * value end,},--眼睛 右 虹膜大小
    [MakeUpDefine.MakeupEditType.Eye_EyeSpecular_R] = {[1] = "eyeRSpecular", [2] = function (value) return 1.0 - value end,},-- 眼睛 右 高光强度
    [MakeUpDefine.MakeupEditType.Lips_Specular] = {[1] = "lipsSpecular", [2] = function (value) return value * 4 end,},-- 唇妆 光泽
    [MakeUpDefine.MakeupEditType.Lips_CrystalIntensity] = {[1] = "lipsCrystalIntensity", [2] = function (value) return value * 10 end,},-- 唇妆 珠粉 强度
    [MakeUpDefine.MakeupEditType.Lips_CrystalUVTiling] = {[1] = "lipsCrystalUVTiling", [2] = function (value) return 1.7 + value * 29.3 end,},-- 唇妆 珠粉 密度
    [MakeUpDefine.MakeupEditType.Blush_CrystalIntensity] = {[1] = "blushCrystalIntensity", [2] = function (value) return value * 10 end,},-- 腮红 珠粉 强度
    [MakeUpDefine.MakeupEditType.Blush_CrystalUVTiling] = {[1] = "blushCrystalUVTiling", [2] = function (value) return 1.7 + value * 16.3 end,},-- 腮红 珠粉 密度
    [MakeUpDefine.MakeupEditType.Tattoo_TattooRot] = {[1] = "tattooAngle", [2] = function (value) return (value - 0.5) * 2 end,},-- 花钿 花钿旋转
}

-- 对贴图进行赋值
-- {[1] = 贴图下标， [2] = 贴图前缀， [3] = 贴图后缀， [4] = 明度属性名}
MakeUpDefine.SetTextureType = {
    [MakeUpDefine.MakeupEditType.NoseContour_Tex] = {[1] = 2, [2] = "tex_role_contour_nose_", [3] = "_d"},-- 鼻子修容 纹理  
    [MakeUpDefine.MakeupEditType.CheekContour_Tex] = {[1] = 3, [2] = "tex_role_contour_cheek_", [3] = "_d"},-- 颧骨修容 纹理
    [MakeUpDefine.MakeupEditType.JawContour_Tex] = {[1] = 4, [2] = "tex_role_contour_jaw_", [3] = "_d"},-- 下巴修容 纹理
    [MakeUpDefine.MakeupEditType.Spot_Tex] = {[1] = 11, [2] = "tex_role_spot_", [3] = "_d", [4] = "spotColorParam" },-- 斑 纹理
    [MakeUpDefine.MakeupEditType.Mole_Tex] = {[1] = 12, [2] = "tex_role_mole_", [3] = "_d", [4] = "moleColorParam"},-- 痣 纹理
    [MakeUpDefine.MakeupEditType.LipsWrinkle_Tex] = {[1] = 14, [2] = "tex_role_chunwen_1001_n", [3] = "_d"},-- 唇纹 纹理
    [MakeUpDefine.MakeupEditType.Wrinkle_Tex] = {[1] = 13, [2] = "tex_role_zhouwen_1001_n", [3] = "_d"},-- 皱纹 纹理
    [MakeUpDefine.MakeupEditType.Tattoo_Tex] = {[1] = 1, [2] = "tex_role_ornaments_", [3] = "_d", [4] = "tattooColorParam"},-- 花钿 纹理
    [MakeUpDefine.MakeupEditType.Blush_Tex] = {[1] = 5, [2] = "tex_role_blush_", [3] = "_d"},-- 腮红 纹理
    [MakeUpDefine.MakeupEditType.Lips_Tex] = {[1] = 6, [2] = "tex_role_lip_", [3] = "_d", [4] = "lipsColorParam"},-- 唇妆 纹理
    [MakeUpDefine.MakeupEditType.EyeWrinkle_Tex] = {[1] = 7, [2] = "tex_role_eyewrinkle_", [3] = "_n"},-- 眼皮 纹理
    [MakeUpDefine.MakeupEditType.Eye_Tex_R] = {[1] = 17, [2] = "tex_role_iris_", [3] = "_d"},-- 眼睛 右 纹理
    [MakeUpDefine.MakeupEditType.Eye_Tex_L] = {[1] = 15, [2] = "tex_role_iris_", [3] = "_d"},-- 眼睛 左 纹理
    [MakeUpDefine.MakeupEditType.EyeLinear_Tex] = {[1] = 0, [2] = "tex_role_eyelinear_", [3] = "_d"},-- 眼线 纹理
    [MakeUpDefine.MakeupEditType.EyeShadow_Tex] = {[1] = 8, [2] = "tex_role_eyeshadow_", [3] = "_d", [4] = "eyeshadowColorParam"},-- 眼影 纹理
    [MakeUpDefine.MakeupEditType.Eyebrow_Tex] = {[1] = 10, [2] = "tex_role_eyebrow_", [3] = "_d", [4] = "eyebrowbgColorParam"},-- 眉毛 纹理
    [MakeUpDefine.MakeupEditType.Cornea_Tex] = {[1] = 16, [2] = "tex_role_eyelash_", [3] = "_d",},-- 睫毛 纹理
}

-- 设置染色颜色
MakeUpDefine.SetDyeColorType = {
    [MakeUpDefine.MakeupEditType.Tattoo_RecommendColor] = {[1] = "tattooColor", [2] = "tattooColorParam"},-- 花钿 推荐色
    [MakeUpDefine.MakeupEditType.Tattoo_Color] = {[1] = "tattooColor", [2] = "tattooColorParam"},-- 花钿 自定义色
    [MakeUpDefine.MakeupEditType.EyeShadow_RecommendColor] = {[1] = "eyeshadowColor", [2] = "eyeshadowColorParam"},-- 眼影 推荐色
    [MakeUpDefine.MakeupEditType.EyeShadow_Color] = {[1] = "eyeshadowColor", [2] = "eyeshadowColorParam"},-- 眼影 自定义色
    [MakeUpDefine.MakeupEditType.Lips_RecommendColor] = {[1] = "lipsColor", [2] = "lipsColorParam"},-- 唇妆 推荐色
    [MakeUpDefine.MakeupEditType.Lips_Color] = {[1] = "lipsColor", [2] = "lipsColorParam"},-- 唇妆 自定义色
    [MakeUpDefine.MakeupEditType.Mole_RecommendColor] = {[1] = "moleColor", [2] = "moleColorParam"},-- 痣 推荐色
    [MakeUpDefine.MakeupEditType.Mole_Color] = {[1] = "moleColor", [2] = "moleColorParam"},-- 痣 自定义色
    [MakeUpDefine.MakeupEditType.Spot_RecommendColor] = {[1] = "spotColor", [2] = "spotColorParam"},-- 斑 推荐色
    [MakeUpDefine.MakeupEditType.Spot_Color] = {[1] = "spotColor", [2] = "spotColorParam"},-- 斑 自定义色
}

MakeUpDefine.SetDyeColorIntensityType = {
    [MakeUpDefine.MakeupEditType.Spot_DyeColorIntensity] = {[1] = "spotColorParam",},-- 斑 染色强度
    [MakeUpDefine.MakeupEditType.Mole_DyeColorIntensity] = {[1] = "moleColorParam",},-- 痣 染色强度
    [MakeUpDefine.MakeupEditType.Eyebrow_DyeColorIntensity] = {[1] = "eyebrowColorParam",},-- 眉毛 染色强度
    [MakeUpDefine.MakeupEditType.EyebrowBG_DyeColorIntensity] = {[1] = "eyebrowbgColorParam",},-- 眉底 染色强度
    [MakeUpDefine.MakeupEditType.EyeShadow_DyeColorIntensity] = {[1] = "eyeshadowColorParam",},-- 眼影 染色强度
    [MakeUpDefine.MakeupEditType.Lips_DyeColorIntensity] = {[1] = "lipsColorParam",},-- 唇妆 染色强度
    [MakeUpDefine.MakeupEditType.Tattoo_DyeColorIntensity] = {[1] = "tattooColorParam",},-- 花钿 染色强度
}

MakeUpDefine.SetDyeColorEnabledType = {
    [MakeUpDefine.MakeupEditType.Spot_DyeColorEnable] = {[1] = "spotColorParam",},-- 斑 染色开关
    [MakeUpDefine.MakeupEditType.Mole_DyeColorEnable] = {[1] = "moleColorParam",},-- 痣 染色开关
    [MakeUpDefine.MakeupEditType.Eyebrow_DyeColorEnable] = {[1] = "eyebrowColorParam",},-- 眉毛 染色范围最小值
    [MakeUpDefine.MakeupEditType.EyebrowBG_DyeColorEnable] = {[1] = "eyebrowbgColorParam",},-- 眉毛 染色范围最小值
    [MakeUpDefine.MakeupEditType.EyeShadow_DyeColorEnable] = {[1] = "eyeshadowColorParam",},-- 眼影 染色范围最小值
    [MakeUpDefine.MakeupEditType.Lips_DyeColorEnable] = {[1] = "lipsColorParam",},-- 唇妆 染色最小范围
    [MakeUpDefine.MakeupEditType.Tattoo_DyeColorEnable] = {[1] = "tattooColorParam",},--  花钿 染色开关
}

MakeUpDefine.SetBiasType = {
    [MakeUpDefine.MakeupEditType.Mole_PosY] = {[1] = "moleBias", [2] = "w"},-- 痣 位移上下
    [MakeUpDefine.MakeupEditType.Mole_PosX] = {[1] = "moleBias", [2] = "z"},-- 痣 位移左右
    [MakeUpDefine.MakeupEditType.Tattoo_TattooPosY] = {[1] = "tattooBias", [2] = "w"},-- 花钿 花钿位移上下
    [MakeUpDefine.MakeupEditType.Tattoo_TattooPosX] = {[1] = "tattooBias", [2] = "z"},-- 花钿 花钿位移左右
}

MakeUpDefine.GetValueType = {
    [MakeUpDefine.MakeupEditType.Skin_RecommendColor] = {[1] = "faceColor",},-- 皮肤 固定色
    [MakeUpDefine.MakeupEditType.Skin_Wrinkle] = {[1] = "wrinkleAlpha",},-- 皮肤 皱纹
    [MakeUpDefine.MakeupEditType.NoseContour_Alpha] = {[1] = "nosecontourAlpha",},-- 鼻子修容 透明度
    [MakeUpDefine.MakeupEditType.NoseContour_RecommendColor] = {[1] = "nosecontourColor",},-- 鼻子修容 推荐色
    [MakeUpDefine.MakeupEditType.NoseContour_Color] = {[1] = "nosecontourColor",},-- 鼻子修容 推荐色
    [MakeUpDefine.MakeupEditType.CheekContour_Alpha] = {[1] = "cheekcontourAlpha",},-- 颧骨修容 透明度
    [MakeUpDefine.MakeupEditType.CheekContour_RecommendColor] = {[1] = "cheekcontourColor",},-- 颧骨修容 推荐色
    [MakeUpDefine.MakeupEditType.CheekContour_Color] = {[1] = "cheekcontourColor",},-- 颧骨修容 自定义色
    [MakeUpDefine.MakeupEditType.JawContour_Alpha] = {[1] = "jawcontourAlpha",},--下巴修容 透明度
    [MakeUpDefine.MakeupEditType.JawContour_RecommendColor] = {[1] = "jawcontourColor",},--下巴修容 推荐色
    [MakeUpDefine.MakeupEditType.JawContour_Color] = {[1] = "jawcontourColor",},--下巴修容 自定义色
    [MakeUpDefine.MakeupEditType.Spot_RecommendColor] = {[1] = "spotColor",},--
    [MakeUpDefine.MakeupEditType.Spot_Alpha] = {[1] = "spotAlpha",},-- 斑 透明度
    [MakeUpDefine.MakeupEditType.Mole_RecommendColor] = {[1] = "moleColor",},-- 
}

return MakeUpDefine