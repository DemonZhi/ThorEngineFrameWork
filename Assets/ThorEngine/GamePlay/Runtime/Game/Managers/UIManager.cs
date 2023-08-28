using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
//using UnityEngine.AddressableAssets;
//using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using LuaInterface;
using ThorEngine.Core;
using Logger = ThorEngine.Core.Logger;
using UnityEngine.Rendering;
//using SGEngine.ResourceManagement;

namespace ThorEngine.UI
{
    public class UIManager : Singleton<UIManager>, IManager
    {
        #region 公有变量
        public enum CameraType
        {
            /// <summary>
            /// UI摄像机
            /// </summary>
            UICamera = 0,
            /// <summary>
            /// 模型摄像机
            /// </summary>
            UICamera3D = 1,
            /// <summary>
            /// 模型前面的摄像机
            /// </summary>
            UICamera2 = 2,
        }
        public List<Canvas> m_AllCanvas = new List<Canvas>();
        #endregion

        #region 私有变量

        private const int k_CanvasDepthUnit = 2000;
        private const int k_CanvasDepthStep = 50;
        private EventSystem m_EventSystem;
        private GameObject m_UIRoot;



        private const string k_AnimationSettingKey = "DamageTextAnimationSetting";
        private const string k_ConsoleKey = "Console";
        private const string k_ParticleShaderName = "SGEngine/URP/Particles/ParticleUnlit";        

        private Camera m_UICamera;//一般UI摄像机
        private Camera m_UICamera3D;//3D模型
        private Camera m_UICamera2;//3D前面的摄像机
        

        #region HUD相关内容
        private const string k_HUDKey = "ui_role_headui";
        private GameObject m_HUDRoot;
        //private List<UGUIFollowTransform> m_AllActiveHUD = new List<UGUIFollowTransform>();
        //private Stack<UGUIFollowTransform> m_HUDPool = new Stack<UGUIFollowTransform>();
        #endregion


        private Transform m_UIGroup3D;
        private Dictionary<int, Canvas> m_UICanvasMap = new Dictionary<int, Canvas>();
        private Dictionary<int, int> m_UICanvasSortingOrderMap = new Dictionary<int, int>();
        private Dictionary<int, Canvas> m_UICanvasMap2 = new Dictionary<int, Canvas>();
        private Dictionary<int, Canvas> m_UICanvasMap3D = new Dictionary<int, Canvas>();
        private Dictionary<int, GameObject> m_UI3DModMap = new Dictionary<int, GameObject>();
        private int m_UIModLightCount;
        private int m_UI3DModCount;
        private Vector3 m_3DUIOriPos = new Vector3(0, 500, 0);

        private UniversalAdditionalCameraData mCamera3DData = null;
        private bool m_bMouseClicked = false;

        private struct UISortingOrderData 
        {
            public string name;
            public int prevOrder;
            public int order;
            public int prevInstanceID;
            public int nextInstanceID;
        }

        private Dictionary<int, UISortingOrderData> m_UISortingDataMap = new Dictionary<int, UISortingOrderData>();
        private Dictionary<int, int> m_LastUIInstanceIDMap = new Dictionary<int, int>();
        private Dictionary<int, int> m_UISubSortingMap = new Dictionary<int, int>();

        //UIBlurBG
        private Dictionary<string, RenderTexture> m_UIRenderTexMap = new Dictionary<string, RenderTexture>();
        private Dictionary<string, int> m_UIRenderTimeIndexMap = new Dictionary<string, int>();

        #endregion

        #region 私有接口
        private UIManager() { }
        /// <summary>
        /// 设置父节点
        /// </summary>
        /// <param name="group"></param>
        /// <param name="parent"></param>
        private void SetGroupParent(GameObject group, GameObject parent)
        {
            Transform ts = group.transform;
            ts.SetParent(parent.transform);
            ts.localScale = Vector3.one;
            ts.localPosition = Vector3.zero;
            ts.localRotation = Quaternion.identity;
        }

        private Camera SetGroupCamera(GameObject group, bool is3D, string name)
        {
            GameObject cameraGO = new GameObject(name);
            SetGroupParent(cameraGO, group);

            Camera uiCamera = cameraGO.AddComponent<Camera>();
            uiCamera.orthographic = !is3D;
            uiCamera.useOcclusionCulling = false;
            uiCamera.tag = is3D ? "Untagged" : "UICamera";

            var cameraData = CameraExtensions.GetUniversalAdditionalCameraData(uiCamera);
            cameraData.renderType = CameraRenderType.Overlay;
            cameraData.renderShadows = false;
            cameraData.renderPostProcessing = is3D;

            // disable mipmaps streaming
            StreamingController streamingController = cameraGO.AddComponent<StreamingController>();
            streamingController.enabled = false;

            var mainCamera = Camera.main;
            if (mainCamera != null)
            {
                var mainCameraData = CameraExtensions.GetUniversalAdditionalCameraData(mainCamera);
                mainCameraData.cameraStack.Add(uiCamera);
            }

            uiCamera.gameObject.SetActive(false);
            return uiCamera;
        }

        /*
        private void SortHUD()
        {
            if (m_AllActiveHUD.Count <= 1)
            {
                return;
            }
            QuickSort(m_AllActiveHUD, 0, m_AllActiveHUD.Count - 1);
        }

        private void QuickSort(List<UGUIFollowTransform> list, int low, int high)
        {
            if (low >= high)
            {
                return;
            }

            int pivot = Partition(list, low, high);
            QuickSort(list, low, pivot-1);
            QuickSort(list, pivot + 1, high);
        }
        

        private int Partition(List<UGUIFollowTransform> list, int low, int high)
        {
            UGUIFollowTransform pivot = list[low];
            while (low < high)
            {
                while (low < high && list[high].CompareTo(pivot) == 1)
                {
                    --high;
                }
                list[low] = list[high];
                while (low < high && list[low].CompareTo(pivot) == 0)
                {
                    ++low;
                }
                list[high] = list[low];
            }
            list[low] = pivot;

            return low;
        }
        */
        #endregion

        #region 公有接口
        /// <summary>
        /// 获取根节点
        /// </summary>
        public GameObject UIRoot
        {
            set
            {
                m_UIRoot = value;
            }
            get
            {
                return m_UIRoot;
            }
        }


        public GameObject HUDRoot
        {
            get
            {
                if (m_HUDRoot == null)
                {
                    InitHUDRoot();
                }

                return m_HUDRoot;
            }
        }

        public void AddToHUDRoot(Transform ts)
        {
            ts.SetParent(m_HUDRoot.transform);
            ts.localPosition = Vector3.zero;
            ts.localScale = Vector3.one;
            ts.localRotation = Quaternion.identity;
        }

        /// <summary>
        /// 获取摄像机
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public Camera GetCameraByType(CameraType type)
        {
            switch (type)
            {
                case CameraType.UICamera:
                    return m_UICamera;
                case CameraType.UICamera3D:
                    return m_UICamera3D;
                case CameraType.UICamera2:
                    return m_UICamera2;
                default:
                    return m_UICamera;
            }
        }

        public Dictionary<int, string> LayerCastName = new Dictionary<int, string>();
        public void SetLayerName(int layer, string layerName) 
        {
            LayerCastName[layer] = layerName;
        }

        public string GetLayerName(int layer) 
        {
            return LayerCastName[layer] != null ? LayerCastName[layer] : layer.ToString();
        }

        public bool IsUICamera3D(Camera camera)
        {
            if(camera == null)
            {
                return false;
            }
            return m_UICamera3D == camera;
        }

        public void SetUICamera3DPos(Vector3 pos, bool isYAbs = false)
        {
            if (isYAbs == true) 
            {
                Vector3 newPos = m_3DUIOriPos + pos;
                m_UICamera3D.transform.position = new Vector3(newPos.x, Math.Abs(newPos.y), newPos.y);
            }
            else
            {
                m_UICamera3D.transform.position = m_3DUIOriPos + pos;
            }
        }

        public void SetUICamera3DQua(Quaternion quaternion)
        {
            m_UICamera3D.transform.rotation = quaternion;            
        }

        public void SetUICamera3DFieldOfView(int iValue) 
        {
            m_UICamera3D.fieldOfView = iValue;
        }

        public void SetUICamera3DFarClipPlane(float fValue) 
        {
            m_UICamera3D.farClipPlane = fValue;
        }

        public float GetUICamera3DFarClipPlane() 
        {
            return m_UICamera3D.farClipPlane;
        }

        public void SetUICamera3DOrthographic(bool bValue) 
        {
            m_UICamera3D.orthographic = bValue;
        }

        public void SetUICamera3DOrthographicSize(float size) 
        {
            m_UICamera3D.orthographicSize = size;
        }

        public void SetCanvasVisible(bool bValue, params int[] lst) 
        {
            for (int i = 0; i < lst.Length; i++)
            {
                Canvas canvas = GetCanvas(CameraType.UICamera, lst[i]);
                if (canvas != null) 
                {
                    canvas.gameObject.SetActive(bValue);
                }
            }
        }

        public Canvas GetActiveCanvas() 
        {
            foreach (Canvas canvas in m_UICanvasMap.Values)
            {
                if (canvas.gameObject.activeInHierarchy) 
                {
                    return canvas;
                }
            }
            foreach (Canvas canvas in m_UICanvasMap2.Values)
            {
                if (canvas.gameObject.activeInHierarchy)
                {
                    return canvas;
                }
            }
            foreach (Canvas canvas in m_UICanvasMap3D.Values)
            {
                if (canvas.gameObject.activeInHierarchy)
                {
                    return canvas;
                }
            }
            return null;
        }

        public Canvas GetCanvas(CameraType type, int depth) 
        {
            Dictionary<int, Canvas> canvasMap = m_UICanvasMap;
            int layer = Layers.k_UILayer;
            
            if (type == CameraType.UICamera2) 
            {
                canvasMap = m_UICanvasMap2;
                layer = Layers.k_UI2Layer;
            }
            else if (type == CameraType.UICamera3D)
            {
                canvasMap = m_UICanvasMap3D;
                layer = Layers.k_UI3DLayer;
            }

            if (canvasMap.ContainsKey(depth))
            {
                return canvasMap[depth];
            }
            else 
            {
                Camera camera = GetCameraByType(type);

                return CreatCanvas(type, depth, layer, canvasMap);
            }            
        }

        public Canvas CreatCanvas(CameraType type, int depth, int layer, Dictionary<int, Canvas> canvasMap) 
        {
            Camera camera = GetCameraByType(type);
            GameObject canvasGO = new GameObject("UICanvas_" + GetLayerName(depth));
            canvasGO.layer = layer;
            Canvas canvas = canvasGO.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceCamera;
            canvas.worldCamera = camera;
            canvas.pixelPerfect = true;
            canvas.sortingOrder = depth * k_CanvasDepthUnit;
            canvas.additionalShaderChannels = AdditionalCanvasShaderChannels.TexCoord1;
            SetGroupParent(canvasGO, camera.gameObject);
            canvasMap.Add(depth, canvas);
            canvasGO.AddComponent<GraphicRaycaster>();
            CanvasScaler canvasScaler = canvasGO.AddComponent<CanvasScaler>();
            canvasScaler.uiScaleMode = Main.GameConfig.uiScaleMode;
            canvasScaler.referenceResolution = Main.GameConfig.referenceResolution;
            canvasScaler.screenMatchMode = Main.GameConfig.screenMatchMode;

            if (m_AllCanvas == null) 
            {
                m_AllCanvas = new List<Canvas>();
            }
            m_AllCanvas.Add(canvas);
            int iSiblindIndex = 0;
            foreach (int key in canvasMap.Keys)
            {
                if (depth > key) 
                {
                    iSiblindIndex++;
                }
            }
            canvasGO.transform.SetSiblingIndex(iSiblindIndex); //深度排序

            return null;
        }

        public List<Canvas> GetAllCanvas() 
        {
            return m_AllCanvas;
        }

        public void SetPixelPerfectEnable(int iCameraType, int depth, bool bEnable) 
        {
            Canvas canvas = GetCanvas((CameraType)iCameraType, depth);
            if (canvas != null) 
            {
                canvas.pixelPerfect = bEnable;
            }
        }

        public int SetUISortingOrder(GameObject go, int canvasDepth) 
        {
            try
            {
                return InnerSetUISortingOrder(go, canvasDepth);
            }
            catch (System.Exception e) 
            {
                Core.Logger.LogError(e.ToString());
            }
            return 0;
        }

        public int GetUISortingOrder(int iInstanceId) 
        {
            if(m_UISortingDataMap.TryGetValue(iInstanceId, out UISortingOrderData orderData)) 
            {
                return orderData.order;
            }
            return -1;
        }

        private Canvas AddNewUISortingOrder(GameObject go, int canvasDepth) 
        {
            Canvas canvasGo = go.GetComponent<Canvas>();
            if (canvasGo != null)
            {
                canvasGo.overrideSorting = true;
                UISortingOrderData sortingData = new UISortingOrderData();
                sortingData.name = go.name;
                if (m_LastUIInstanceIDMap[canvasDepth] == 0) //当前CanvasDepth 下没有UI
                {
                    canvasGo.sortingOrder = canvasDepth * k_CanvasDepthUnit + k_CanvasDepthStep;
                    sortingData.prevOrder = canvasDepth * k_CanvasDepthUnit;
                    sortingData.order = canvasGo.sortingOrder;
                    sortingData.prevInstanceID = 0;
                    sortingData.nextInstanceID = 0;
                    m_UISortingDataMap[go.GetInstanceID()] = sortingData;
                    m_LastUIInstanceIDMap[canvasDepth] = go.GetInstanceID();
                }
                else
                {
                    int prevInstanceID = m_LastUIInstanceIDMap[canvasDepth];
                    UISortingOrderData prevSortingData = m_UISortingDataMap[prevInstanceID];
                    prevSortingData.nextInstanceID = go.GetInstanceID();

                    canvasGo.sortingOrder = prevSortingData.order + 10;
                    sortingData.prevOrder = prevSortingData.order;
                    sortingData.order = canvasGo.sortingOrder;
                    sortingData.prevInstanceID = prevInstanceID;
                    sortingData.nextInstanceID = 0;
                    m_UISortingDataMap[go.GetInstanceID()] = sortingData;
                    m_LastUIInstanceIDMap[canvasDepth] = go.GetInstanceID();
                }
            }
            else 
            {
                Logger.LogErrorFormat("[UIManager](AddNewUISortingOrder) GameObject:{0} UI View root must have a component", go.name);
            }
            return canvasGo;
        }

        private Canvas ReorderUISortingOrder(GameObject go, int canvasDepth, ref int iSortingOrder) 
        {
            UISortingOrderData sortingData = new UISortingOrderData();
            Canvas canvasGo = go.GetComponent<Canvas>();
            if (canvasGo != null) 
            {
                sortingData = m_UISortingDataMap[go.GetInstanceID()];
                iSortingOrder = sortingData.order;
                int prevInstanceID = sortingData.prevInstanceID;
                int nextInstanceID = sortingData.nextInstanceID;

                //当前是最上层UI 不需处理
                if (nextInstanceID == 0)
                {
                    return null;
                }
                else 
                {
                    if (prevInstanceID != 0) 
                    {
                        UISortingOrderData prevSortingData = m_UISortingDataMap[prevInstanceID];
                        prevSortingData.nextInstanceID = sortingData.nextInstanceID;
                        m_UISortingDataMap[prevInstanceID] = prevSortingData;
                    }

                    UISortingOrderData nextSortingData = m_UISortingDataMap[nextInstanceID];
                    nextSortingData.prevOrder = sortingData.prevOrder;
                    nextSortingData.prevInstanceID = sortingData.prevInstanceID;
                    m_UISortingDataMap[nextInstanceID] = nextSortingData;

                    int lastInstanceID = m_LastUIInstanceIDMap[canvasDepth];
                    UISortingOrderData lastSortingData = m_UISortingDataMap[lastInstanceID];
                    lastSortingData.nextInstanceID = go.GetInstanceID();
                    m_UISortingDataMap[lastInstanceID] = lastSortingData;

                    canvasGo.sortingOrder = lastSortingData.order + 10;
                    sortingData.prevOrder = lastSortingData.order;
                    sortingData.order = canvasGo.sortingOrder;
                    sortingData.prevInstanceID = lastInstanceID;
                    sortingData.nextInstanceID = 0;
                    m_UISortingDataMap[go.GetInstanceID()] = sortingData;
                    m_LastUIInstanceIDMap[canvasDepth] = go.GetInstanceID();
                }

            }
            return canvasGo;
        }

        private int InnerSetUISortingOrder(GameObject go, int canvasDepth) 
        {
            if (!m_UICanvasSortingOrderMap.ContainsKey(canvasDepth)) 
            {
                m_UICanvasSortingOrderMap[canvasDepth] = 0;
            }
            if (!m_LastUIInstanceIDMap.ContainsKey(canvasDepth))
            {
                m_LastUIInstanceIDMap[canvasDepth] = 0;
            }
            int iSortingOrder = 0;
            Canvas canvasGo = null;
            if (!m_UISortingDataMap.ContainsKey(go.GetInstanceID()))
            {
                canvasGo = AddNewUISortingOrder(go, canvasDepth);
            }
            else 
            {
                canvasGo = ReorderUISortingOrder(go, canvasDepth, ref iSortingOrder);
            }

            //UI子元素排序
            if (canvasGo) 
            {
                iSortingOrder = canvasGo.sortingOrder;
                Canvas[] canvases = go.GetComponentsInChildren<Canvas>(true);
                for (int i = 0; i < canvases.Length; i++)
                {
                    if (canvases[i].GetComponentInParent<Dropdown>() != null)  // ToDo: TMP_DropDown
                    {
                        continue;
                    }

                    if (canvases[i].gameObject != go) 
                    {
                        int instanceID = canvases[i].gameObject.GetInstanceID();
                        canvases[i].overrideSorting = true;
                        if (!m_UISubSortingMap.ContainsKey(instanceID)) 
                        {
                            m_UISubSortingMap[instanceID] = canvases[i].sortingOrder;
                        }
                        int originSortingOrder = m_UISubSortingMap[instanceID];
                        canvases[i].sortingOrder = originSortingOrder + canvasGo.sortingOrder;
                        
                    }
                }

                SortingGroup[] sortingGroups = go.GetComponentsInChildren<SortingGroup>(true);
                for (int i = 0; i < sortingGroups.Length; i++)
                {
                    if (sortingGroups[i].gameObject != go) 
                    {
                        int instanceID = sortingGroups[i].gameObject.GetInstanceID();
                        if (!m_UISubSortingMap.ContainsKey(instanceID)) 
                        {
                            m_UISubSortingMap[instanceID] = sortingGroups[i].sortingOrder;
                        }
                        int originSortingOrder = m_UISubSortingMap[instanceID];
                        sortingGroups[i].sortingOrder = originSortingOrder + canvasGo.sortingOrder;
                    }
                }
            }
            return iSortingOrder;
        }

        public void ReleaseUISortingOrder(GameObject go, int canvasDepth) 
        {
            try
            {
                InnerSetUISortingOrder(go, canvasDepth);
            }
            catch (System.Exception e)
            {
                Core.Logger.LogError(e.ToString());
            }
        }

        private void InnerRealeaseUISortingOrder(GameObject go, int canvasDepth) 
        {
            Canvas canvasGo = go.GetComponent<Canvas>();
            if (canvasGo != null) 
            {
                int instanceID = go.GetInstanceID();
                if (!m_UISortingDataMap.ContainsKey(instanceID)) 
                {
                    Logger.LogError("UISortingDataMap not contains key " + go.name);
                    return;
                }

                int prevInstanceID = m_UISortingDataMap[instanceID].prevInstanceID;
                int nextInstanceID = m_UISortingDataMap[instanceID].nextInstanceID;
                //上一个节点为0 自身为第一个
                if (prevInstanceID == 0)
                {
                    //下一个为0 自己也是最后一个
                    if (nextInstanceID == 0)
                    {
                        m_LastUIInstanceIDMap[canvasDepth] = 0;
                    }
                    else
                    {
                        UISortingOrderData nextSortingData = m_UISortingDataMap[nextInstanceID];
                        UISortingOrderData sortingData = m_UISortingDataMap[instanceID];
                        nextSortingData.prevOrder = sortingData.prevOrder;
                        nextSortingData.prevInstanceID = sortingData.prevInstanceID;
                        m_UISortingDataMap[nextInstanceID] = nextSortingData;
                    }
                }

                //队中
                else if (nextInstanceID != 0)
                {
                    UISortingOrderData prevSortingData = m_UISortingDataMap[prevInstanceID];
                    UISortingOrderData nextSortingdata = m_UISortingDataMap[nextInstanceID];
                    UISortingOrderData sortingData = m_UISortingDataMap[instanceID];
                    prevSortingData.nextInstanceID = sortingData.nextInstanceID;
                    nextSortingdata.prevOrder = sortingData.prevOrder;
                    nextSortingdata.prevInstanceID = sortingData.prevInstanceID;
                    m_UISortingDataMap[prevInstanceID] = prevSortingData;
                    m_UISortingDataMap[nextInstanceID] = nextSortingdata;
                }
                
                //队尾
                else 
                {
                    UISortingOrderData prevSortingData = m_UISortingDataMap[prevInstanceID];
                    prevSortingData.nextInstanceID = 0;
                    m_UISortingDataMap[prevInstanceID] = prevSortingData;
                    m_LastUIInstanceIDMap[canvasDepth] = prevInstanceID;
                }

                m_UISortingDataMap.Remove(instanceID);
            }
        }

        public void SetSubViewSortingOrder(GameObject goRoot, GameObject goSub) 
        {
            Canvas canvasRoot = goRoot.GetComponent<Canvas>();
            Canvas canvasSub = goSub.GetComponent<Canvas>();
            if (canvasRoot != null && canvasSub != null) 
            {
                canvasSub.overrideSorting = true;
                if (!m_UISubSortingMap.ContainsKey(goSub.GetInstanceID())) 
                {
                    m_UISubSortingMap[goSub.GetInstanceID()] = canvasSub.sortingOrder;
                }
                int originSortingOrder = m_UISubSortingMap[goSub.GetInstanceID()];
                canvasSub.sortingOrder = originSortingOrder + canvasRoot.sortingOrder;
                Canvas[] canvases = goSub.GetComponentsInChildren<Canvas>(true);
                for (int i = 0; i < canvases.Length; i++) 
                {
                    if (canvases[i].gameObject != goSub) 
                    {
                        int instanceID = canvases[i].gameObject.GetInstanceID();
                        canvases[i].overrideSorting = true;

                        if (!m_UISubSortingMap.ContainsKey(instanceID))
                        {
                            m_UISubSortingMap[instanceID] = canvases[i].sortingOrder;
                        }
                        int originSubCanvasSortingOrder = m_UISubSortingMap[instanceID];
                        canvases[i].sortingOrder = originSubCanvasSortingOrder + canvasSub.sortingOrder;
                    }
                }

                SortingGroup[] sortingGroups = goSub.GetComponentsInChildren<SortingGroup>(true);
                for (int i = 0; i < sortingGroups.Length; i++)
                {
                    if (sortingGroups[i].gameObject != goSub)
                    {
                        int instanceID = sortingGroups[i].gameObject.GetInstanceID();
                        if (!m_UISubSortingMap.ContainsKey(instanceID))
                        {
                            m_UISubSortingMap[instanceID] = sortingGroups[i].sortingOrder;
                        }
                        int originSortingGroupOrder = m_UISubSortingMap[instanceID];
                        sortingGroups[i].sortingOrder = originSortingGroupOrder + canvasSub.sortingOrder;
                    }
                }
            }
        }

        public void CheckCanvasVisible(CameraType type, int depth) 
        {
            Canvas canvas = GetCanvas(type, depth);
            bool isVisible = false;
            foreach (Transform item in canvas.transform)
            {
                if (item.gameObject.activeSelf) 
                {
                    isVisible = true;
                    break;
                }
            }
            canvas.gameObject.SetActive(isVisible);
        }

        public void SetCamera3DPostprocessEnable(bool value) 
        {
            if (mCamera3DData) 
            {
                return;
            }
            mCamera3DData.renderPostProcessing = value;
        }

        public void Camera3DIgnoreLayer(int iLayerMask) 
        {
            m_UICamera3D.cullingMask &= ~iLayerMask;
        }

        public void Camera3DAddLayer(int iLayerMask) 
        {
            m_UICamera3D.cullingMask |= iLayerMask;
        }

        public Canvas AddCanvas(GameObject go, CameraType type)
        {
            Canvas canvas = go.GetComponent<Canvas>();
            if (canvas != null)
            {
                return canvas;
            }

            int layer = Layers.k_UILayer;
            if (type == CameraType.UICamera2)
            {
                layer = Layers.k_UI2Layer;
            }
            else if (type == CameraType.UICamera3D)
            {
                layer = Layers.k_UI3DLayer;
            }

            Camera camera = GetCameraByType(type);
            CommonUtility.SetLayer(go, layer);
            canvas = go.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceCamera;
            canvas.worldCamera = camera;
            canvas.overrideSorting = true;
            canvas.additionalShaderChannels = AdditionalCanvasShaderChannels.TexCoord1;
            go.AddComponent<GraphicRaycaster>();
            return canvas;
        }

        public static CanvasScaler AddCanvasScaler(GameObject go)
        {
            CanvasScaler canvasScaler = go.GetComponent<CanvasScaler>();
            if (canvasScaler != null)
            {
                return canvasScaler;
            }

            canvasScaler = go.AddComponent<CanvasScaler>();
            canvasScaler.uiScaleMode = Main.GameConfig.uiScaleMode;
            canvasScaler.referenceResolution = Main.GameConfig.referenceResolution;
            canvasScaler.screenMatchMode = Main.GameConfig.screenMatchMode;
            canvasScaler.matchWidthOrHeight = Main.GameConfig.matchWidthOrHeight;
            return canvasScaler;
        }

        /// <summary>
        /// 设置UI父节点
        /// </summary>
        /// <param name="type"></param>
        /// <param name="canvasDepth"></param>
        public void SetUIParent(GameObject go, CameraType type)
        {
            SetGroupParent(go, GetCameraByType(type).gameObject);
            m_UICamera.gameObject.SetActive(true);
            Canvas canvas = AddCanvas(go, type);
            canvas.gameObject.SetActive(true);
            AddCanvasScaler(go);

            CheckAllCameraVisible();
        }

        public void SetNormalUIParent(GameObject go, int canvasDepth) 
        {
            Canvas canvas = GetCanvas(CameraType.UICamera, canvasDepth);
            canvas.gameObject.SetActive(true);
            SetGroupParent(go, canvas.gameObject);
        }

        public void Set2DUIParent(GameObject go, int canvasDepth) 
        {
            CommonUtility.SetLayer(go, Layers.k_UI2Layer);
            Canvas canvas = GetCanvas(CameraType.UICamera2, canvasDepth);
            canvas.gameObject.SetActive(true);
            SetGroupParent(go, canvas.gameObject);
        }

        public void Set3DParent(GameObject go, Vector3 scale = new Vector3(), Vector3 pos = new Vector3(), Quaternion rot = new Quaternion())
        {
            go.transform.SetParent(m_UIGroup3D.transform);
            go.transform.localPosition = m_3DUIOriPos + pos;
            go.transform.localRotation = rot;
            go.transform.localScale = scale;
        }

        public void SetDamageParent(GameObject go) 
        {
            SetGroupParent(go, m_UIRoot);
        }

        public void set3DOriPos(GameObject go) 
        {
            go.transform.localPosition = m_3DUIOriPos;
            go.transform.localRotation = Quaternion.identity;
            go.transform.localScale = Vector3.one;
        }

        public int Register3DObj(GameObject go) 
        {
            m_UI3DModCount++;
            m_UI3DModMap.Add(m_UI3DModCount, go);
            return m_UI3DModCount;
        }

        public void Remove3DObj(int key) 
        {
            if (m_UI3DModMap.ContainsKey(key)) 
            {
                m_UI3DModMap.Remove(key);
            }
        }

        public void CheckCameraVisible(CameraType type)
        {
            Camera camera = GetCameraByType(type);
            bool isVisible = false;
            foreach (Transform child in camera.transform)
            {
                if (child.gameObject.activeSelf)
                {
                    isVisible = true;
                    break;
                }
            }
            camera.gameObject.SetActive(isVisible);
        }

        public void CheckUI3DCameraVisible() 
        {
            bool isVisible = false;
            foreach (Transform child in m_UIGroup3D.transform) 
            {
                if (child != m_UICamera3D.transform && child.gameObject.activeSelf) 
                {
                    isVisible = true;
                    break;
                }
            }
            m_UICamera3D.gameObject.SetActive(isVisible);
        }

        public void SetUICamera3DActive(bool bActive) 
        {
            m_UICamera3D.gameObject.SetActive(bActive);
        }

        public void CheckUICamera2Visible() 
        {
            bool isVisible = false;
            foreach (Transform child in m_UICamera2.transform)
            {
                if (child.gameObject.activeSelf) 
                {
                    foreach (Transform childChild in child.transform)
                    {
                        if (childChild.gameObject.activeSelf) 
                        {
                            isVisible = true;
                            break;
                        }
                    }
                }
            }
            m_UICamera2.gameObject.SetActive(isVisible);
        }

        public void CheckAllCameraVisible()
        {
            CheckCameraVisible(CameraType.UICamera);
            CheckCameraVisible(CameraType.UICamera2);
            CheckCameraVisible(CameraType.UICamera3D);
        }

        public void Set2DUIParent(GameObject go)
        {            
            CommonUtility.SetLayer(go, Layers.k_UI2Mask);
            Canvas canvas = AddCanvas(go, CameraType.UICamera2);
            canvas.gameObject.SetActive(true);
            SetGroupParent(go, canvas.gameObject);
        }

        
        public void Set3DParent(GameObject go, Vector3 scale = new Vector3(), Vector3 pos = new Vector3())
        {
            m_UICamera3D.gameObject.SetActive(true);
            if (go != null)
            {
                CommonUtility.SetLayer(go, Layers.k_UI3DLayer);
                go.transform.SetParent(m_UICamera3D.transform);
                go.transform.position = m_3DUIOriPos + pos;
                go.transform.localScale = scale;
            }
        }

        public void Set3DOriPos(GameObject go)
        {
            go.transform.localPosition = m_3DUIOriPos;
            go.transform.localRotation = Quaternion.identity;
            go.transform.localScale = Vector3.one;
        }


        /// <summary>
        /// 设置UI模型光照参数
        /// </summary>
        public bool SetUIModeLightSetting()
        {
            bool result = false;
            if (m_UIModLightCount == 0)
            {
                result = true;
            }
            m_UIModLightCount++;
            return result;
        }

        public void CloseUIModeLightSetting()
        {
            m_UIModLightCount--;
            if (m_UIModLightCount < 0)
            {
                m_UIModLightCount = 0;
                Debug.LogError("CloseUIModeLightSetting Count erro");
            }
        }

        public bool GetMouseClicked(bool bCleatState) 
        {
            if (m_bMouseClicked) 
            {
                if (bCleatState) 
                {
                    m_bMouseClicked = false;
                }
                return true;
            }
            return m_bMouseClicked;
        }

        /*
        public void PopHUD(Action<UGUIFollowTransform> callback)
        {
            if (m_HUDPool.Count <= 0)
            {
                SGResourceManager.InstantiateAsync(k_HUDKey, (go, ob) =>
                {
                    Transform transform = go.transform;
                    AddToHUDRoot(transform);

                    transform.localPosition = Vector3.zero;
                    transform.localRotation = Quaternion.identity;
                    transform.localScale = Vector3.one;

                    go.AddComponent<BillBoard3DUI>();
                    UGUIFollowTransform uGUIFollowTransform = go.AddComponent<UGUIFollowTransform>();
                    m_AllActiveHUD.Add(uGUIFollowTransform);

                    callback(uGUIFollowTransform);
                });
            }
            else
            {
                UGUIFollowTransform uGUIFollowTransform = m_HUDPool.Pop();
                m_AllActiveHUD.Add(uGUIFollowTransform);
                uGUIFollowTransform.gameObject.SetActive(true);
                callback(uGUIFollowTransform);
            }
        }

        public void PushHUD(UGUIFollowTransform uGUIFollowTransform)
        {
            if (m_AllActiveHUD.Contains(uGUIFollowTransform))
            {
                m_AllActiveHUD.Remove(uGUIFollowTransform);
                uGUIFollowTransform.gameObject.SetActive(false);
                m_HUDPool.Push(uGUIFollowTransform);
            }
        }
       
        public static GameObject CreateStencilPlane()
        {
            GameObject stencilPlane = new GameObject("StencilPlane", typeof(MeshFilter), typeof(MeshRenderer));
            MeshFilter meshFilter = stencilPlane.GetComponent<MeshFilter>();
            MeshRenderer meshRenderer = stencilPlane.GetComponent<MeshRenderer>();

            Mesh mesh = new Mesh();
            mesh.vertices = new Vector3[]
            {
                new Vector3(0, 0, 0),
                new Vector3(1, 0, 0),
                new Vector3(1, 1, 0),
                new Vector3(0, 1, 0),
            };

            mesh.uv = new Vector2[]
            {
                new Vector2(0, 0),
                new Vector2(0, 1),
                new Vector2(1, 1),
                new Vector2(1, 0),
            };
            mesh.triangles = new int[] { 0, 1, 2, 0, 2, 3 };
            meshFilter.mesh = mesh;
            mesh.RecalculateBounds();
            mesh.RecalculateNormals();

            Material material = new Material(ShaderManager.Instance.GetShader(k_ParticleShaderName));
            material.SetInt("_StencilRef", 255);
            material.SetInt("_StencilComp", 8);
            material.SetFloat("_AlphaFactor", 0);
            material.SetInt("_Cull", 0);
            material.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
            material.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.One);
            material.renderQueue = 2000;
            meshRenderer.material = material;
            return stencilPlane;
        }
         */
        /// <summary>
        /// 打开全屏UI
        /// </summary>
        public void OnOpenScreenUI()
        {
            //关闭相机特效
        }

        /// <summary>
        /// 关闭全屏UI
        /// </summary>
        public void OnCloseScreenUI()
        {
            //重新打开相机特效         
        }

        public EventSystem GetEventSystem()
        {
            if (m_EventSystem == null)
            {
                m_EventSystem = UnityEngine.Object.FindObjectOfType<EventSystem>();
                if (m_EventSystem == null) 
                {
                    GameObject eventSystem = new GameObject("EventSystem");
                    m_EventSystem = eventSystem.AddComponent<EventSystem>();
                    StandaloneInputModule standaloneInputModule = eventSystem.AddComponent<StandaloneInputModule>();
                    //standaloneInputModule.submitButton = "Fire1";
                    //standaloneInputModule.cancelButton = "Fire2";
                    GameObject.DontDestroyOnLoad(eventSystem);
                }   
            }
            return m_EventSystem;
        }

        [NoToLuaAttribute]
        public void Init()
        {
            m_UIRoot = new GameObject("UIRoot");
            SetGroupParent(m_UIRoot, Main.GlobalModule);

            GameObject group3d = new GameObject("UIGroup3D");
            m_UIGroup3D = group3d.transform;
            SetGroupParent(group3d, m_UIRoot);
            m_UICamera3D = SetGroupCamera(group3d, true, "UICamera3D");
            m_UICamera3D.cullingMask = Layers.k_UI3DMask;
            m_UICamera3D.transform.localPosition = m_3DUIOriPos;
            m_UICamera3D.fieldOfView = 30;
            m_UICamera3D.nearClipPlane = 0.3f;
            m_UICamera3D.farClipPlane = 20;
            var camera3DDate = m_UICamera3D.GetUniversalAdditionalCameraData();
            camera3DDate.volumeLayerMask = Layers.k_UI3DMask;


            GameObject group0 = new GameObject("UIGroup");
            SetGroupParent(group0, m_UIRoot);
            m_UICamera = SetGroupCamera(group0, false, "UICamera");
            m_UICamera.cullingMask = Layers.k_UIMask;
            m_UICamera.farClipPlane = 150;


            GameObject group1 = new GameObject("UIGroup2");
            SetGroupParent(group1, m_UIRoot);
            m_UICamera2 = SetGroupCamera(group1, false, "UICamera2");
            m_UICamera2.cullingMask = Layers.k_UI2Mask;
            m_UICamera2.gameObject.SetActive(false);

            //InitHUDRoot();

            EventSystem eventSystem = GetEventSystem();
            SetGroupParent(eventSystem.gameObject, m_UIRoot);

            /*
            SGResourceManager.InstantiateAsync(k_AnimationSettingKey, (go, obj) =>
            {
                 SetGroupParent(go, m_UIRoot);
            });
            */
            //InitConsole();
        }
        
        private void InitHUDRoot()
        {
            if (m_HUDRoot != null)
            {
                return;
            }
            m_HUDRoot = new GameObject("HUDRoot");
            m_HUDRoot.layer = LayerMask.NameToLayer("HUD");
            SetGroupParent(m_HUDRoot, m_UIRoot);
            m_HUDRoot.transform.localScale = new Vector3(0.015f, 0.015f, 0.015f);
            m_HUDRoot.SetActive(true);

            Canvas canvas = m_HUDRoot.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.WorldSpace;
            canvas.worldCamera = Camera.main;
            canvas.sortingOrder = 100;
            canvas.additionalShaderChannels = AdditionalCanvasShaderChannels.TexCoord1 | AdditionalCanvasShaderChannels.TexCoord2;
            CanvasScaler canvasScaler = m_HUDRoot.AddComponent<CanvasScaler>();
            canvasScaler.dynamicPixelsPerUnit = Main.GameConfig.hudDynamicPixelsPerUnit;
        }
        
        /*
        private void InitConsole()
        {
            SGResourceManager.InstantiateAsync(k_ConsoleKey, (go, obj) => 
            {
                Canvas canvas = go.GetComponent<Canvas>();
                Camera camera = GetCameraByType(CameraType.UICamera);

                canvas.renderMode = RenderMode.ScreenSpaceCamera;
                canvas.worldCamera = camera;
                canvas.sortingOrder = 9999;
                canvas.additionalShaderChannels = AdditionalCanvasShaderChannels.TexCoord1;
                CommonUtility.SetLayer(go, Layers.k_UILayer);
                SetGroupParent(go, camera.gameObject);
            });
        }
        */

        [NoToLuaAttribute]
        public void Update()
        {
            if (Input.GetMouseButtonUp(0)) 
            {

            }
        }

        [NoToLuaAttribute]
        public void LateUpdate()
        {
            /*
            if (m_HUDRoot.activeInHierarchy)
            {
                SortHUD();
                foreach (UGUIFollowTransform uguiFollowTransform in m_AllActiveHUD)
                {
                    uguiFollowTransform.transform.SetAsFirstSibling();
                }
            }
            */
        }

        [NoToLuaAttribute]
        public void FixedUpdate()
        {

        }

        [NoToLuaAttribute]
        public void Restart()
        {

        }

        [NoToLuaAttribute]
        public void Destroy()
        {
            /*
            for (int i = m_AllActiveHUD.Count - 1; i >= 0; i--)
            {
                PushHUD(m_AllActiveHUD[i]);
            }

            while (m_HUDPool.Count > 1)
            {
                SGResourceManager.ReleaseInstance(m_HUDPool.Pop().gameObject);
            }

            m_HUDPool.Clear();
            m_AllActiveHUD.Clear();
            */
            if (m_UIRoot != null)
            {
                GameObject.Destroy(m_UIRoot);
                m_UIRoot = null;
            }

            if (m_HUDRoot != null)
            {
                GameObject.Destroy(m_HUDRoot);
                m_HUDRoot = null;
            }

            if (m_EventSystem != null)
            {
                GameObject.Destroy(m_EventSystem.gameObject);
                m_EventSystem = null;
            }

            if (m_AllCanvas != null) 
            {
                m_AllCanvas.Clear();
            }
        }

        public void BeforeChangeScene(int prevSceneType, int nextSceneType)
        {
            
        }

        [NoToLuaAttribute]
        public void AfterChangeScene(int prevSceneType, int nextSceneType)
        {
        }

        [NoToLuaAttribute]
        public bool IsAutoUpdate()
        {
            return true;
        }
        #endregion
    }
}