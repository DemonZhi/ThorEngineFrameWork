-- package.cpath = package.cpath .. ';C:/Users/Administrator/AppData/Roaming/JetBrains/IdeaIC2020.2/plugins/intellij-emmylua/classes/debugger/emmy/windows/x64/?.dll'
-- local dbg = require('emmy_core')
-- dbg.tcpConnect('localhost', 9966)
Transform = UnityEngine.Transform
GameObject = UnityEngine.GameObject
Input = UnityEngine.Input
Light = UnityEngine.Light
LightType = UnityEngine.LightType
Camera = UnityEngine.Camera
Physics = UnityEngine.Physics
PlayerPrefs = UnityEngine.PlayerPrefs
Application = UnityEngine.Application
RuntimePlatform = UnityEngine.RuntimePlatform

Core_CameraType = SGEngine.UI.UIManager.CameraType
Core_NetProtocolType = NetProtocolType
UIModLightSetting = SGEngine.UI.UIModLightSetting
--Logger = SGEngine.Core.Logger
Core_ForLuaUtility = SGEngine.Core.ForLuaUtility

--tup用到的基本类型
Int = System.Int32
Short = System.Int16
Long = System.Int64
Byte = System.Byte
String = System.String
Bool = System.Boolean
 
DOTween = DG.Tweening.DOTween
--AudioManager = SGEngine.Core.AudioManager.Instance
AndroidMessageManager = SGEngine.Core.AndroidMessageManager.Instance

--基础
class = require("Engine/Common/Base/Class")
require("Engine/Common/Utilities/Function")
require("Engine/Common/Utilities/CommonUtil")
require("Engine/Common/Utilities/AndroidUtil")
require("Engine/Common/Utilities/DeviceUtil")
require("Engine/Common/Utilities/Logger")
require("Engine/UI/Event/Dispatcher")
require("Engine/Game/Managers/ResourceManager")
require("Engine/Game/Managers/TimerManager")

--枚举
Message = require("MainGame/Message/MessageOpcodeEnum")
ObjectTypeEnum = require("Engine/Common/Const/ObjectTypeEnum")
SceneTypeEnum = require("Engine/Common/Const/SceneTypeEnum")
StateTypeEnum = require("Engine/Common/Const/StateTypeEnum")
KeyFrameEnum = require("Engine/Common/Const/KeyFrameEnum")
AvatarSubpartTypeEnum = require("Engine/Common/Const/AvatarSubpartTypeEnum")
NetErrorCodeEnum = require("Engine/Common/Const/NetErrorCodeEnum")
ProcedureTypeEnum = require("MainGame/Game/Procedure/ProcedureTypeEnum")

--配置
require("MainGame/Configs/ConfigLoader")
UIControllerConfig = require("MainGame/UI/Configs/UIControllerConfig")
UIViewConfig = require("MainGame/UI/Configs/UIViewConfig")
UICommandConfig = require("MainGame/UI/Configs/UICommandConfig")

--UI
BaseUI = require("Engine/UI/Base/BaseUI")
BaseView = require("Engine/UI/Base/BaseView")
BaseCtrl = require("Engine/UI/Base/BaseCtrl")
BaseTabPanel = require("Engine/UI/Base/BaseTabPanel")
BaseItem = require("Engine/UI/Base/BaseItem")
BaseImage = require("Engine/UI/Base/BaseImage")
ScrollList = require("Engine/UI/Base/ScrollList")
LoopListView2 = require("Engine/UI/Base/LoopListView2")
LoopGridView = require("Engine/UI/Base/LoopGridView")
SuperBaseItem = require("Engine/UI/Base/SuperBaseItem")
require("Engine/Game/Managers/UIManager")

--技能
SkillBase = require("Engine/Systems/ObjectSystem/Skill/SkillBase")
SkillMove = require("Engine/Systems/ObjectSystem/Skill/SkillMove")
SkillMove3rd = require("Engine/Systems/ObjectSystem/Skill/SkillMove3rd")
SkillMovePro = require("Engine/Systems/ObjectSystem/Skill/SkillMovePro")
SkillMovePro3rd = require("Engine/Systems/ObjectSystem/Skill/SkillMovePro3rd")
SkillRootMotion = require("Engine/Systems/ObjectSystem/Skill/SkillRootMotion")
SkillCharge = require("Engine/Systems/ObjectSystem/Skill/SkillCharge")
SkillCharge3rd = require("Engine/Systems/ObjectSystem/Skill/SkillCharge3rd")
SkillP2P = require("Engine/Systems/ObjectSystem/Skill/SkillP2P")
SkillP2P3rd = require("Engine/Systems/ObjectSystem/Skill/SkillP2P3rd")
SkillJump = require("Engine/Systems/ObjectSystem/Skill/SkillJump")

--状态
StateBase = require("Engine/Systems/ObjectSystem/State/StateBase")
StateIdle = require("Engine/Systems/ObjectSystem/State/StateIdle")
StateDead = require("Engine/Systems/ObjectSystem/State/StateDead")
StateHit = require("Engine/Systems/ObjectSystem/State/StateHit")
StateHitFloat = require("Engine/Systems/ObjectSystem/State/StateHitFloat")
StateIdleMonster = require("Engine/Systems/ObjectSystem/State/StateIdleMonster")
StateJump = require("Engine/Systems/ObjectSystem/State/StateJump")
StateSwimHero = require("Engine/Systems/ObjectSystem/State/StateSwimHero")
StateSwim3rd = require("Engine/Systems/ObjectSystem/State/StateSwim3rd")
StateMove = require("Engine/Systems/ObjectSystem/State/StateMove")
StateMove3rd = require("Engine/Systems/ObjectSystem/State/StateMove3rd")
StateMoveHero = require("Engine/Systems/ObjectSystem/State/StateMoveHero")
StateMoveMonster = require("Engine/Systems/ObjectSystem/State/StateMoveMonster")
StateRide = require("Engine/Systems/ObjectSystem/State/StateRide")
StateSkill = require("Engine/Systems/ObjectSystem/State/StateSkill")
StateDodge = require("Engine/Systems/ObjectSystem/State/StateDodge")
StateDaze = require("Engine/Systems/ObjectSystem/State/StateDaze")
StateCaught = require("Engine/Systems/ObjectSystem/State/StateCaught")
StatePull = require("Engine/Systems/ObjectSystem/State/StatePull")
StateCinema = require("Engine/Systems/ObjectSystem/State/StateCinema")
StateNavigation = require("Engine/Systems/ObjectSystem/State/StateNavigation")
StateFreeze = require("Engine/Systems/ObjectSystem/State/StateFreeze")

--组件
ComponentBase = require("Engine/Systems/ObjectSystem/Components/ComponentBase")
ComponentSkill = require("Engine/Systems/ObjectSystem/Components/ComponentSkill")
ComponentEffect = require("Engine/Systems/ObjectSystem/Components/ComponentEffect")
ComponentFightResult = require("Engine/Systems/ObjectSystem/Components/ComponentFightResult")
ComponentPlaySpeedControl = require("Engine/Systems/ObjectSystem/Components/ComponentPlaySpeedControl")
ComponentState = require("Engine/Systems/ObjectSystem/Components/ComponentState")
ComponentEventDispatcher = require("Engine/Systems/ObjectSystem/Components/ComponentEventDispatcher")
ComponentEffectAmountControl = require("Engine/Systems/ObjectSystem/Components/ComponentEffectAmountControl")
ComponentAttribute = require("Engine/Systems/ObjectSystem/Components/ComponentAttribute")
ComponentFightResultRecorder = require("Engine/Systems/ObjectSystem/Components/ComponentFightResultRecorder")
ComponentDrag = require("Engine/Systems/ObjectSystem/Components/ComponentDrag")
ComponentModelPostProcess = require("Engine/Systems/ObjectSystem/Components/ComponentModelPostProcess")
ComponentLoadModelQueue = require("Engine/Systems/ObjectSystem/Components/ComponentLoadModelQueue")
ComponentSkillCombo = require("Engine/Systems/ObjectSystem/Components/ComponentSkillCombo")
ComponentMoveHero = require("Engine/Systems/ObjectSystem/Components/ComponentMoveHero")
ComponentMove3rd = require("Engine/Systems/ObjectSystem/Components/ComponentMove3rd")
ComponentRide = require("Engine/Systems/ObjectSystem/Components/ComponentRide")
ComponentStateChecker = require("Engine/Systems/ObjectSystem/Components/ComponentStateChecker")
ComponentFaceMakeUp = require("Engine/Systems/ObjectSystem/Components/ComponentFaceMakeUp")
ComponentBag = require("Engine/Systems/ObjectSystem/Components/ComponentBag")
ComponentQuest = require("Engine/Systems/ObjectSystem/Components/ComponentQuest")
ComponentIK = require("Engine/Systems/ObjectSystem/Components/ComponentIK")
ComponentSkillTarget = require("Engine/Systems/ObjectSystem/Components/ComponentSkillTarget")
ComponentAvatar = require("Engine/Systems/ObjectSystem/Components/ComponentAvatar")
ComponentHUD = require("Engine/Systems/ObjectSystem/Components/ComponentHUD")
ComponentFootPrint = require("Engine/Systems/ObjectSystem/Components/ComponentFootPrint")
ComponentMoveMonster = require("Engine/Systems/ObjectSystem/Components/ComponentMoveMonster")
ComponentTurnStrategy = require("Engine/Systems/ObjectSystem/Components/ComponentTurnStrategy")

--实体
SGObject = require("Engine/Systems/ObjectSystem/SGObject")
SGCtrl = require("Engine/Systems/ObjectSystem/SGCtrl")
SGSprite = require("Engine/Systems/ObjectSystem/SGSprite")
SGPlayer = require("Engine/Systems/ObjectSystem/SGPlayer")
SGMonster = require("Engine/Systems/ObjectSystem/SGMonster")
SGUIObject = require("Engine/Systems/ObjectSystem/SGUIObject")
SGTrigger = require("Engine/Systems/ObjectSystem/SGTrigger")
SGMissile = require("Engine/Systems/ObjectSystem/SGMissile/SGMissile")
SGMount = require("Engine/Systems/ObjectSystem/SGMount")
SGMagicArea = require("Engine/Systems/ObjectSystem/SGMagicArea")
require("Engine/Game/Managers/ObjectManager")

--Helper
PlayerPrefsHelper = require("MainGame/Common/Helper/PlayerPrefsHelper")

--网络
require("MainGame/Message/MessageManager")
require("Engine/Game/Managers/NetManager")
require("MainGame/Game/Managers/ClientNetManager")

--luaToCsharp回调注册
require("Engine/Game/Managers/CoreCallbackManager")

--剧情
require("MainGame/TimeLine/TimeLineManager")
require("MainGame/Game/Managers/CinemaManager")

--场景
require("Engine/Game/Managers/EffectManager")
require("Engine/Game/Managers/SceneManager")
require("Engine/Game/Managers/OutlineManager")
require("MainGame/Game/Managers/AccountManager")
require("Engine/Game/Managers/TurnStrategyManager")
require("MainGame/Game/Managers/BfClientManager")
require("Engine/Game/Logic/GameLoop")

--流程
require("Engine/Game/Managers/ProcedureManager")
require("MainGame/Game/Procedure/ProcedureHandler")
require("MainGame/Game/Procedure/ProcedureInit")
require("MainGame/Game/Procedure/ProcedureLogin")
require("MainGame/Game/Procedure/ProcedureCreateRole")
require("MainGame/Game/Procedure/ProcedureMain")

--重载
require("MainGame/Game/Managers/ReloadManager")

ProcedureManager.AddProcedure(ProcedureTypeEnum.Init, ProcedureInit)
ProcedureManager.AddProcedure(ProcedureTypeEnum.Login, ProcedureLogin)
ProcedureManager.AddProcedure(ProcedureTypeEnum.CreateRole, ProcedureCreateRole)
ProcedureManager.AddProcedure(ProcedureTypeEnum.Main, ProcedureMain)

function Main()
    GameLoop.Init()
    Logger.LogInfoFormat("[Main](Main)Lua Version: {0}", _VERSION)

    if IS_CINEMA_EDITOR_START then
       return
    end

    ProcedureManager.ChangeProcedure(ProcedureTypeEnum.Init)
end
