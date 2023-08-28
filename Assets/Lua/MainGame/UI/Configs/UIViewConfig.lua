local UILayerTypeEnum = require("MainGame/UI/Common/Const/UILayerTypeEnum")

local UIViewConfig = 
{
    ['JoyStick'] = 
    {
        id = 'JoyStick',
        classPath = 'MainGame/UI/Module/JoyStick/View/JoyStickView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.JoyStickLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        isFullScreen = false,
    },
    ['SkillView'] = 
    {
        id = 'SkillView',
        classPath = 'MainGame/UI/Module/Action/View/SkillView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.JoyStickLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        isFullScreen = false,
    },
    ['OpView'] = 
    {
        id = 'OpView',
        classPath = 'MainGame/UI/Module/Operate/View/OpView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.MainLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        isFullScreen = false,
    },
    ['GMView'] = 
    {
        id = 'GMView',
        classPath = 'MainGame/UI/Module/GM/View/GMView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['SettingView'] = 
    {
        id = 'SettingView',
        classPath = 'MainGame/UI/Module/Setting/View/SettingView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['ScenesSwitchView'] =
    {
        id = 'ScenesSwitchView',
        classPath = 'MainGame/UI/Module/ScenesSwitch/View/ScenesSwitchView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['LoadingView'] = 
    {
        id = 'LoadingView',
        classPath = 'MainGame/UI/Module/Loading/View/LoadingView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.LoadingLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.Login, SceneTypeEnum.Loading, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = true,
    },
    ['SRPBatcherProfilerView'] = 
    {
        id = 'SRPBatcherProfilerView',
        classPath = 'MainGame/UI/Module/SRPBatcherProfiler/View/SRPBatcherProfilerView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['WardrobeView'] = 
    {
        id = 'WardrobeView',
        classPath = 'MainGame/UI/Module/Wardrobe/View/WardrobeView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['LoginView'] = 
    {
        id = 'LoginView',
        classPath = 'MainGame/UI/Module/Login/View/LoginView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.MainLayer,
        activeSceneType = {SceneTypeEnum.Login, SceneTypeEnum.None, SceneTypeEnum.Loading, SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.Login},
        isFullScreen = true,
    },
    ['CreateRoleView'] = 
    {
        id = 'CreateRoleView',
        classPath = 'MainGame/UI/Module/CreateRole/View/CreateRoleView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.MainLayer,
        activeSceneType = {SceneTypeEnum.Login},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['SelectRoleView'] = 
    {
        id = 'SelectRoleView',
        classPath = 'MainGame/UI/Module/CreateRole/View/SelectRoleView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.MainLayer,
        activeSceneType = {SceneTypeEnum.Login},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['AlertView'] = 
    {
        id = 'AlertView',
        classPath = 'MainGame/UI/Module/Alert/View/AlertView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.TipLayer,
        activeSceneType = {SceneTypeEnum.None},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false
    },
    ['TipsView'] = 
    {
        id = 'TipsView',
        classPath = 'MainGame/UI/Module/Alert/View/TipsView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.TipLayer,
        activeSceneType = {SceneTypeEnum.None},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['WaitingView'] = 
    {
        id = 'WaitingView',
        classPath = 'MainGame/UI/Module/Waiting/View/WaitingView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.TipLayer,
        activeSceneType = {SceneTypeEnum.Login, SceneTypeEnum.None, SceneTypeEnum.Loading, SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false
    },
    ['TestWebView'] =
    {
        id = 'TestWebView',
        classPath = 'MainGame/UI/Module/TestWeb/View/TestWebView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.None},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['MakeupView'] = 
    {
        id = 'MakeupView',
        classPath = 'MainGame/UI/Module/Makeup/View/MakeupView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Login},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['TurnStrategyView'] =
    {
        id = 'TurnStrategyView',
        classPath = 'MainGame/UI/Module/TurnStrategy/View/TurnStrategyView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Battle},
        defaultShowSceneType = {SceneTypeEnum.Battle},
        isFullScreen = false,
    },
	['MODView'] =
    {
        id = 'MODView',
        classPath = 'MainGame/UI/Module/Makeup/View/MODView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.None},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = true,
    },
    ['CinemaView'] =
    {
        id = 'CinemaView',
        classPath = 'MainGame/UI/Module/Cinema/View/CinemaView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.None},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },    
    ['CinemaSwitchView'] =
    {
        id = 'CinemaSwitchView',
        classPath = 'MainGame/UI/Module/CinemaSwitch/View/CinemaSwitchView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
    ['TestUIMoldeClipView'] =
    {
        id = 'TestUIMoldeClipView',
        classPath = 'MainGame/UI/Module/TestUIMoldeClip/View/TestUIMoldeClipView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.Town, SceneTypeEnum.Battle, SceneTypeEnum.SLG},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = true,
    },
	['PlaceTriggerView'] =
    {
        id = 'PlaceTriggerView',
        classPath = 'MainGame/UI/Module/PlaceTrigger/View/PlaceTriggerView',
        camera = Core_CameraType.UICamera,
        layer = UILayerTypeEnum.FunctionLayer,
        activeSceneType = {SceneTypeEnum.None},
        defaultShowSceneType = {SceneTypeEnum.None},
        isFullScreen = false,
    },
	--UIEditor insert Tag
}

return UIViewConfig
