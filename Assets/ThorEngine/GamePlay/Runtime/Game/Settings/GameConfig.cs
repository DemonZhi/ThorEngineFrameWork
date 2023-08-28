using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Rendering.Universal;

namespace ThorEngine.Core
{
    [CreateAssetMenu(fileName = "GameConfig.asset", menuName = "SGEngine/Settings/创建Gameplay配置文件")]
    public class GameConfig : ScriptableObject
    {
        [Header("Common")]
        [SerializeField]
        public int targetFrameRate = 30;
        [HideInInspector]
        public int cameraMode = 0;
        [SerializeField]
        public bool neverSleep = true;
        [SerializeField]
        public string machineCode = "";

        [Header("Rendering")]
        //[SerializeField]
        //public RenderSetting.Quality renderQuality = RenderSetting.Quality.High;
        [SerializeField]
        public int maxResolutionHeight = 960;
        [SerializeField]
        public bool streamingMipmapsActive = true;
        [SerializeField]
        [Range(0, 512)]
        public float streamingMipmapsMemoryBudget = 128;
        [SerializeField]
        [Range(1, 7)]
        public int streamingMipmapsMaxLevelReduction = 2;
        [SerializeField]
        public bool smaa = false;
        [SerializeField]
        public AntialiasingQuality smaaQuality = AntialiasingQuality.Medium;

        [Header("Physics")]
        [SerializeField]
        public bool useUnityPhysics = true;
        public bool useMagicaPhysics = true;
        public bool autoSyncTransform = true;
        //public UpdateTimeManager.UpdateCount magicaPhysicsUpdateCount = UpdateTimeManager.UpdateCount._90_Default;
        [Range(0,1)]
        public float magicaPhysicsPredictionRate = 1.0f;

        [Header("Asset Bundle")]
        [SerializeField]
        public bool useBundleMode = false;

        [SerializeField]
        public string luaBundleLabel = "Lua";

        [Header("Log")]
        [SerializeField]
        [HideInInspector]
        public string logHelper;

        [Header("开启日志")]
        [SerializeField]
        public bool openLog = true;

        [Header("开启Bugly")]
        [SerializeField]
        public bool openBugly = false;
        [SerializeField]
        public bool openBuglyDebugMode = false;
        [SerializeField]
        public string buglyAppidIOS = "";

        [Header("Canvas配置")]
        [SerializeField]
        public Vector2 referenceResolution = new Vector2(720, 1440);
        [SerializeField]
        public CanvasScaler.ScaleMode uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        [SerializeField]
        public CanvasScaler.ScreenMatchMode screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        [SerializeField]
        public float matchWidthOrHeight = 1.0f;
        [SerializeField] 
        [Range(0, 3)]
        public float hudDynamicPixelsPerUnit = 1.3f;
        public bool bSafeAreaHorizontalOffset = true;
        public bool bSafeAreaVerticalOffset = true;


        [Header("Shader")]
        [SerializeField]
        public ShaderVariantCollection mobileShaderVariantCollection;
        public ShaderVariantCollection pcShaderVariantCollection;
        public bool warmUpShaderOnStart = true;
        public bool logWhenShaderIsCompiled = false;

        [Header("网络配置")]
        public bool useNetwork = true;
        public string remoteIP = "127.0.0.1";
        public int remotePort = 6001;
        
        /*public NetProtocolType protocolTypeIndex = NetProtocolType.TCP;
        public int protocolType
        {
            get
            {
                 return (int)protocolTypeIndex;
            }
        }
        */

        public float pingStep = 5f;
        public int pingMessageID = 0x31e8;
        public bool isEncrypt = false;
        public bool openNoDelay = true;
        public int netLoopFPS = 60;
        public string outerSdkURL = "http://203.195.151.182/inc_login.php";
        public string innerSdkURL = "http://10.11.10.114:8088/inc_login.php";

        /*
        [Header("战斗配置")]
        public bool moveByNavimesh = false;
        [SerializeField]
        public HurtHighlightConfig hurtHighlightConfig;
        [SerializeField]
        public DeadDissolveConfig deadDissolveConfig;
        [SerializeField]
        public RoleWetConfig roleWetConfig;
        [SerializeField]
        public IceFreezeConfig iceFreezeConfig;
        */
        /*
        [Header("妝容配置")]
        [SerializeField]
        public FaceMakeupConfig faceMakeupConfig;
        */
        [Header("MiniServer配置")]
        [SerializeField]
        public string bornSceneName = "10001";
        [SerializeField]
        public int playerResourceID = 29;
        [SerializeField]
        public int bornSceneID = 0;
        [SerializeField]
        public Vector3 bornPosition = new Vector3(169.88f, 30.85f, 93.35f);
        [SerializeField]
        public bool enableRVO = false;
        //[SerializeField]
        //public AStarManager.SearchType aStarSearchType = AStarManager.SearchType.UnityNavMesh;
        [SerializeField]
        public bool aStarCalculateOnMainThread = false;

#if UNITY_EDITOR
        [LuaInterface.NoToLua]
        public static GameConfig LoadGameConfigEditor()
        {
            return UnityEditor.AssetDatabase.LoadAssetAtPath<GameConfig>("Assets/SGEngine/GamePlay/Settings/GameConfig.asset");
        }
#endif
    }
}
